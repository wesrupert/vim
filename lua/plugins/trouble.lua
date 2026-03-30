local util = require("util")
local lsp_util = require("util.lsp")

return {
  {
    "folke/trouble.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    ---@module "trouble"
    ---@type trouble.Config
    opts = {
      focus = true,
      open_no_results = true,
      modes = {
        ---@type trouble.Mode
        ---@diagnostic disable-next-line: missing-fields
        qflist = {
          ---@type trouble.Window.opts
          preview = { type = "split", relative = "win", position = "right", size = 0.4 },
        },
        ---@type trouble.Mode
        ---@diagnostic disable-next-line: missing-fields
        loclist = {
          ---@type trouble.Window.opts
          preview = { type = "split", relative = "win", position = "right", size = 0.4 },
        },
      },
    },
    config = function (_, opts)
      local trouble = require("trouble")
      trouble.setup(opts)

      local user_trouble_config_group = vim.api.nvim_create_augroup("UserTroubleConfig", { clear = true })
      local trouble_close_on_leave = util.use_setting("trouble_close_on_leave", false).get
      local trouble_quickfix_takeover = util.use_setting("trouble_quickfix_takeover", true).get

      local function trouble_toggle_sidebar(mode, sidebar_opts)
        trouble.toggle(util.merge({ mode = mode, focus = false, win = { position = "right" } }, sidebar_opts or {}))
      end

      util.keymap({
        { "<c-t>", desc = "[Trouble] Close", trouble.close },
        { "gro", desc = "[Trouble] Symbols",              function () trouble_toggle_sidebar("symbols", { flatten = true, format = "{kind_icon} {symbol.name} {pos}" }) end                },
        { "grO", desc = "[Trouble] Symbols List",         function () trouble.open({ mode = "symbols", focus = true, win = { position = "bottom" } }) end                                  },
        { "grq", desc = "[Trouble] Quickfix List",        function () trouble.toggle("qflist") end                                                                                         },
        { "grQ", desc = "[Trouble] Quickfix List (v)",    function () trouble.open({ mode = "qflist", win = { position = "right", size = 0.32 }, preview = { position = "bottom" } }) end  },
        { "grl", desc = "[Trouble] Location List",        function () trouble.toggle("loclist") end                                                                                        },
        { "grL", desc = "[Trouble] Location List (v)",    function () trouble.open({ mode = "loclist", win = { position = "right", size = 0.32 }, preview = { position = "bottom" } }) end },
        { "grD", desc = "[Trouble] Diagnostics",          function () trouble.open({ mode = "diagnostics", filter = { ['not'] = { severity = vim.diagnostic.severity.INFO } } }) end       },
        { "grd", desc = "[Trouble] Diagnostics (buffer)", function () trouble.open({ mode = "diagnostics", filter = { buf = 0 } }) end                                                     },
        ---@diagnostic disable-next-line: missing-fields
        { "<leader>t", desc = "[Trouble] Toggle (buffer)", function () trouble.toggle({ mode = "todo", filter = { buf = 0 } }) end                                                         },
        { "<leader>T", desc = "[Trouble] Toggle",          function () trouble.toggle("todo") end                                                                                          },
      })

      lsp_util.on_attach(function (bufnr)
        util.keymap({
          { "grR", desc = "[Trouble] References",      function () trouble_toggle_sidebar("lsp") end                 },
          { "grI", desc = "[Trouble] Implementations", function () trouble_toggle_sidebar("lsp_implementations") end },
        }, bufnr)
      end)

      vim.api.nvim_create_autocmd("BufLeave", {
        group = user_trouble_config_group,
        callback = function (ev)
          if vim.bo[ev.buf].filetype == "trouble" and trouble_close_on_leave(ev.buf) then
            trouble.close()
          end
        end,
      })

      vim.api.nvim_create_autocmd("BufRead", {
        group = user_trouble_config_group,
        callback = function (ev)
          if vim.bo[ev.buf].buftype == "quickfix" and trouble_quickfix_takeover(ev.buf) then
            vim.schedule(function ()
              vim.cmd([[cclose]])
              vim.cmd([[lclose]])
              trouble.open("qflist")
            end)
          end
        end,
      })

      vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        group = user_trouble_config_group,
        pattern = "l[^h]*",
        callback = function () trouble.open("loclist") end,
      })

      vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        group = user_trouble_config_group,
        pattern = "[^l]*",
        callback = function () trouble.open("qflist") end,
      })
    end,
  },
}

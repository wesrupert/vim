local util = require("util")
return {
  "folke/trouble.nvim",
  url = "https://github.com/wesrupert/trouble.nvim",
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

    util.keymap("grx", "[Trouble] Close",                trouble.close)
    util.keymap("gro", "[Trouble] Symbols",              function () trouble_toggle_sidebar("symbols", { flatten = true, format = "{kind_icon} {symbol.name} {pos}" }) end)
    util.keymap("grO", "[Trouble] Symbols List",         function () trouble.open({ mode = "symbols", focus = true, win = { position = "bottom" } }) end)
    util.keymap("grq", "[Trouble] Quickfix List",        function () trouble.toggle("qflist") end)
    util.keymap("grQ", "[Trouble] Location List",        function () trouble.toggle("loclist") end)
    util.keymap("grD", "[Trouble] Diagnostics",          function () trouble.open({ mode = "diagnostics", filter = { ['not'] = { severity = vim.diagnostic.severity.INFO } } }) end)
    util.keymap("grd", "[Trouble] Diagnostics (buffer)", function () trouble.open({ mode = "diagnostics", filter = { buf = 0 } }) end)

    vim.api.nvim_create_autocmd("LspAttach", {
      group = user_trouble_config_group,
      callback = function(ev)
        util.keymap("grR", "[Trouble] References",      function () trouble_toggle_sidebar("lsp") end)
        util.keymap("grI", "[Trouble] Implementations", function () trouble_toggle_sidebar("lsp_implementations") end)
      end,
    })

    vim.api.nvim_create_autocmd("BufLeave", {
      group = user_trouble_config_group,
      callback = function (ev)
        if vim.bo[ev.buf].filetype == "trouble" and trouble_close_on_leave() then
          trouble.close()
        end
      end,
    })

    vim.api.nvim_create_autocmd("BufRead", {
      group = user_trouble_config_group,
      callback = function (ev)
        if vim.bo[ev.buf].buftype == "quickfix" and trouble_quickfix_takeover() then
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
  specs = {
    "folke/snacks.nvim",
    optional = true,
    opts = function (_, opts)
      return util.merge(opts or {}, {
        picker = {
          actions = require("trouble.sources.snacks").actions,
          win = {
            input = {
              keys = {
                ["<c-q>"] = { "trouble_open", mode = { "n", "i" } },
              },
            },
          },
        },
      })
    end,
  },
}
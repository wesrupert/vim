local util = require("util")
return {
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

    util._keymap("<c-t>", "[Trouble] Close", trouble.close)

    util._keymap("gro", "[Trouble] Symbols",              function () trouble_toggle_sidebar("symbols", { flatten = true, format = "{kind_icon} {symbol.name} {pos}" }) end)
    util._keymap("grO", "[Trouble] Symbols List",         function () trouble.open({ mode = "symbols", focus = true, win = { position = "bottom" } }) end)
    util._keymap("grq", "[Trouble] Quickfix List",        function () trouble.toggle("qflist") end)
    util._keymap("grQ", "[Trouble] Quickfix List (v)",    function () trouble.open({ mode = "qflist", win = { position = "right", size = 0.32 }, preview = { position = "bottom" } }) end)
    util._keymap("grl", "[Trouble] Location List",        function () trouble.toggle("loclist") end)
    util._keymap("grL", "[Trouble] Location List (v)",    function () trouble.open({ mode = "loclist", win = { position = "right", size = 0.32 }, preview = { position = "bottom" } }) end)
    util._keymap("grD", "[Trouble] Diagnostics",          function () trouble.open({ mode = "diagnostics", filter = { ['not'] = { severity = vim.diagnostic.severity.INFO } } }) end)
    util._keymap("grd", "[Trouble] Diagnostics (buffer)", function () trouble.open({ mode = "diagnostics", filter = { buf = 0 } }) end)

    vim.api.nvim_create_autocmd("LspAttach", {
      group = user_trouble_config_group,
      callback = function(ev)
        util._keymap("grR", "[Trouble] References",      function () trouble_toggle_sidebar("lsp") end)
        util._keymap("grI", "[Trouble] Implementations", function () trouble_toggle_sidebar("lsp_implementations") end)
      end,
    })

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
}
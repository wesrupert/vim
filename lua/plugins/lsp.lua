local lsp_util = require("lsp")
local user_lsp_config_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = false })

return {
  {
    "neovim/nvim-lspconfig",
    init = function () lsp_util.setup_lsp_servers() end,
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1001, -- Must run before other lsp plugins!
    opts = {
      preset = "powerline",
      options = {
        show_all_diags_on_cursorline = true,
        show_source = { enabled = true },
        multilines = {
          enabled = true,
          always_show = false,
          tabstop = 2,
          severity = { vim.diagnostic.severity.ERROR },
        },
        overflow = { padding = 4 },
        experimental = {
          -- Make diagnostics not mirror across windows containing the same buffer
          -- See: https://github.com/rachartier/tiny-inline-diagnostic.nvim/issues/127
          use_window_local_extmarks = true,
        },
      },
    },
    config = function (_, opts)
      local tiny = require("tiny-inline-diagnostic")
      tiny.setup(opts or {})

      vim.diagnostic.config({ virtual_text = false })

      local was_enabled = false
      vim.api.nvim_create_autocmd("User", {
        desc = "[TinyInlineDiagnostic] Toggle on NES",
        group = user_lsp_config_group,
        pattern = "SidekickNesHide",
        callback = function()
          if was_enabled and not tiny.enabled then
            tiny.enable()
          end
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        desc = "[TinyInlineDiagnostic] Toggle on NES",
        group = user_lsp_config_group,
        pattern = "SidekickNesShow",
        callback = function()
          was_enabled = tiny.enabled
          tiny.disable()
        end,
      })
    end,
  },
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = {"nvim-lua/plenary.nvim"},
    event = "LspAttach",
    opts = {
      backend = "difftastic",
      picker = {
        "buffer",
        opts = {
          hotkeys = true,
          hotkeys_mode = "text_diff_based",
          custom_keys = {
            { key = "ff", pattern = "Fix this prettier/.* problem" },
            { key = "fa", pattern = "Fix this prettier/prettier problems" },
            { key = "zg", pattern = "Add '[^']*' to dictionary" },
            { key = "zG", pattern = "Add '[^']*' to global dictionary" },
            { key = "zi", pattern = "Add current file to ignore list" },
          },
          keymaps = {
            preview = "-",
            preview_close = { "-", "q", "<esc>" },
            close = { "q", "<esc>" },
          },
        },
      },
    },
    config = function (_, opts)
      local tiny_code_action = require("tiny-code-action")
      tiny_code_action.setup(opts)
      lsp_util.register_code_action_fun(tiny_code_action.code_action)
    end,
  },
  { "mason-org/mason.nvim", build = ":MasonUpdate", config = true },
  { "folke/lsp-colors.nvim" },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "pmizio/typescript-tools.nvim" },
    config = true,
  },
  { "yioneko/nvim-vtsls" },
}
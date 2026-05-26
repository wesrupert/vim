local util = require("util")
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
            { key = "f", pattern = "Fix all auto-fixable problems" },
            { key = "g", pattern = "Add '[^']*' to dictionary" },
            { key = "G", pattern = "Add '[^']*' to global dictionary" },
            { key = "i", pattern = "Add current file to ignore list" },
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

      ---@param lhs string
      ---@param desc string
      ---@param filter fun(action: lsp.CodeAction, client: vim.lsp.Client): boolean
      ---@return table
      local function gen_code_action(lhs, desc, apply, filter)
        return { lhs, desc = desc, function () tiny_code_action.code_action({ filter = filter, apply = apply }) end }
      end

      util.keymap({
        { "grf", desc = "[CodeAction] Fix all", function ()
          tiny_code_action.code_action({ filters = { title = "Fix all auto-fixable problems" }, apply = true })
        end },
        gen_code_action("z=", "[CodeAction] Fix typo", false, function (action, client)
          if not client or client.name ~= "codebook" then return false end
          if not action.title:match("Replace with '.*'") then return false end
          return true
        end),
        gen_code_action("zg", "[CodeAction] Add to dictionary", true, function (action, client)
          if not client or client.name ~= "codebook" then return false end
          if not action.title:match("Add '.*' to dictionary") then return false end
          return true
        end),
        gen_code_action("zG", "[CodeAction] Add to global dictionary", true, function (action, client)
          if not client or client.name ~= "codebook" then return false end
          if not action.title:match("Add '.*' to global dictionary") then return false end
          return true
        end),
      })
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
return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = {
      preset = "powerline",
      options = { show_source = { enabled = true } },
    },
    init = function ()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "mason-org/mason.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    build = ":MasonUpdate",
    config = true,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "pmizio/typescript-tools.nvim", "saghen/blink.cmp" },
    config = true,
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "mason.nvim",
      "nvimtools/none-ls-extras.nvim",
      "davidmh/cspell.nvim",
    },
    opts = {
      config_file_preferred_name = "cspell.json",
      cspell_config_dirs = { "~/.config/" },
    },
    config = function (_, opts)
      local none_ls = require("null-ls")
      local cspell = require("cspell")
      none_ls.setup({
        sources = {
          cspell.diagnostics.with({
            config = opts,
            diagnostics_postprocess = function (event)
              event.severity = vim.diagnostic.severity.INFO
            end,
          }),
          cspell.code_actions.with({ config = opts }),
        },
      })
    end,
  },
  {
    "folke/lsp-colors.nvim",
  },
  {
    "chaitanyabsprip/fastaction.nvim",
    opts = {
      dismiss_keys = { "q", "<esc>", "<c-c>" },
      popup = {
        title = false,
      },
      priority = {
        eslint = {
          { key = "f", order = 1, pattern = "fix this" },
          { key = "a", order = 2, pattern = "fix all" },
        },
        ["null-ls"] = {
          { key = "S", order = 4, pattern = "add.*to.*~/%.config/cspell%.json" },
          { key = "s", order = 3, pattern = "add.*to.*cspell%.json" },
        },
      },
    },
    config = function (_, opts)
      local util = require("util")
      local lsp_util = require("util.lsp")
      local fastaction = require("fastaction")
      fastaction.setup(opts)

      lsp_util.on_attach(function (client, bufnr)
        util.keymap("gra", "[LSP] Show code actions", fastaction.code_action, { "n", "x" }, bufnr)
        if client.name == 'null-ls' then
          util.keymap("zg",  "[LSP] Show code actions", fastaction.code_action, { "n", "x" }, bufnr)
          util.keymap("zG",  "[LSP] Show code actions", fastaction.code_action, { "n", "x" }, bufnr)
        end
      end)
    end,
  },
}
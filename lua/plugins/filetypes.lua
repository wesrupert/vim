local util = require("util")
return {
  { "herringtondarkholme/yats.vim" },
  { "aklt/plantuml-syntax" },
  { "cakebaker/scss-syntax.vim" },
  { "groenewege/vim-less" },
  { "sheerun/html5.vim" },
  { "pangloss/vim-javascript" },
  { "tpope/vim-git" },
  { "ipkiss42/xwiki.vim" },
  {
    "posva/vim-vue",
    init = function () vim.g.vue_pre_processors = "detect_on_enter" end,
  },
  {
    "maxmellon/vim-jsx-pretty",
    dependencies = { "yuezk/vim-js", "peitalin/vim-jsx-typescript" },
    init = function ()
      vim.g.vim_jsx_pretty_disable_tsx = 1 -- Handled by peitalin/vim-jsx-typescript
    end,
  },

  -- LSP Additions
  {
    "folke/lazydev.nvim",
    ft = "lua",
    config = true,
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        opts = function (_, opts)
          local sources_default = vim.tbl_get(opts or {}, "sources", "default") or {}
          local completion_menu_draw_treesitter = vim.tbl_get(opts or {}, "sources", "default") or {}
          table.insert(sources_default, 2, "lazydev")
          table.insert(completion_menu_draw_treesitter, 1, "lazydev")
          return util.merge(opts or {}, {
            completion = { menu = { draw = { treesitter = completion_menu_draw_treesitter } } },
            sources = {
              default = sources_default,
              providers = {
                lazydev = {
                  name = "NeoVim",
                  module = "lazydev.integrations.blink",
                  score_offset = 50,
                  fallbacks = { "lsp" },
                },
              },
            },
          })
        end,
      },
    },
  },
  {
    "ruicsh/tailwind-hover.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = { "TailwindHover" },
    keys = {
      { "<leader>K", desc = "[Tailwind] Hover", "<cmd>TailwindHover<cr>" },
    },
    opts = { title = "Tailwind Styles" },
    specs = {
      {
        "lewis6991/hover.nvim",
        optional = true,
        opts = function (_, opts)
          return util.merge(opts or {}, {
            providers = util.tbl_join({ "tailwind-hover.providers.hover" }, opts and opts.providers or {})
          })
        end,
      },
    },
  },
  {
    "nemanjamalesija/ts-expand-hover.nvim",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    opts = {
      keymaps = {
        hover = "goe",
        expand = "=",
      },
      float = { border = vim.o.winborder },
    },
  },
}
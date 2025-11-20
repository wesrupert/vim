local util = require("util")
return {
  { "herringtondarkholme/yats.vim" },
  { "aklt/plantuml-syntax" },
  { "cakebaker/scss-syntax.vim" },
  { "groenewege/vim-less" },
  { "othree/yajs.vim" },
  { "pangloss/vim-javascript" },
  { "sheerun/html5.vim" },
  { "tpope/vim-git" },
  { "ipkiss42/xwiki.vim" },
  {
    "posva/vim-vue",
    init = function () vim.g.vue_pre_processors = "detect_on_enter" end,
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
}
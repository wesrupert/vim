local util = require('util')
return {
  { 'herringtondarkholme/yats.vim' },
  { 'aklt/plantuml-syntax' },
  { 'cakebaker/scss-syntax.vim' },
  { 'groenewege/vim-less' },
  { 'ipkiss42/xwiki.vim' },
  { 'othree/yajs.vim' },
  { 'pangloss/vim-javascript' },
  { 'sheerun/html5.vim' },
  { 'tpope/vim-git' },
  {
    'posva/vim-vue',
    init = function () vim.g.vue_pre_processors = 'detect_on_enter' end,
  },
  { 'oxy2dev/markview.nvim' },

  -- LSP Additions
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    config = true,
  },
  {
    'catgoose/vue-goto-definition.nvim',
    event = 'BufReadPre',
    ft = { 'vue', 'typescript', 'typescriptreact' },
    config = true,
  },
  {
    'yioneko/nvim-vtsls',
  },
}
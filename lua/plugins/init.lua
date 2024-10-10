local notvscode = vim.g.vscode ~= 1

return {
  -- Colorschemes
  { 'edeneast/nightfox.nvim', priority = 1000, enabled = notvscode },
  { 'ellisonleao/gruvbox.nvim', priority = 1000, enabled = notvscode },
  { 'folke/tokyonight.nvim', priority = 1000, enabled = notvscode },
  { 'reedes/vim-colors-pencil', priority = 1000, enabled = notvscode },
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000, enabled = notvscode },

  -- Meta plugins
  { 'equalsraf/neovim-gui-shim' },
  { 'nvim-lua/plenary.nvim' },
  { 'folke/lsp-colors.nvim', enabled = notvscode },
  { 'tpope/vim-repeat' },

  -- Architecture plugins
  { 'airblade/vim-rooter' },
  { 'nvim-tree/nvim-web-devicons' },
  { 'conormcd/matchindent.vim' },
  {
    "luckasRanarison/nvim-devdocs",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },

  -- Action plugins
  { 'mbbill/undotree', enabled = notvscode },
  { 'junegunn/goyo.vim', enabled = notvscode },
  {
    'ggandor/leap.nvim',
    init = function()
      vim.keymap.set({'n'}, 'gl', '<plug>(leap)', { desc = 'Leap' })
      vim.keymap.set({'x', 'o'}, 'gL', '<plug>(leap-forward)', { desc = 'Leap forward' })
      vim.keymap.set({'n', 'x', 'o'}, 'gL', '<plug>(leap-backward)', { desc = 'Leap back' })
      vim.keymap.set({'x', 'o'}, 'gt', '<plug>(leap-forward-till)', { desc = 'Leap until' })
      vim.keymap.set({'x', 'o'}, 'gT', '<plug>(leap-backward-till)', { desc = 'Leap back until' })
      vim.keymap.set({'n', 'x', 'o'}, 'gol', '<plug>(leap-from-window)', { desc = 'Leap from window' })
      vim.keymap.set({'n', 'x', 'o'}, 'goL', '<plug>(leap-cross-window)', { desc = 'Leap cross window' })
    end,
  },

  -- Text object plugins
  { 'glts/vim-textobj-comment', dependencies = { 'kana/vim-textobj-user' } },
  { 'kana/vim-textobj-indent', dependencies = { 'kana/vim-textobj-user' } },
  { 'lucapette/vim-textobj-underscore', dependencies = { 'kana/vim-textobj-user' } },
  { 'sgur/vim-textobj-parameter', dependencies = { 'kana/vim-textobj-user' } },

  -- Command plugins
  {
    'chrisgrieser/nvim-spider',
    lazy = true,
    init = function()
      vim.keymap.set('n', 'w', '<cmd>lua require("spider").motion("w")<CR>', { desc = 'Spider-w' })
      vim.keymap.set('n', 'e', '<cmd>lua require("spider").motion("e")<CR>', { desc = 'Spider-e' })
      vim.keymap.set('n', 'b', '<cmd>lua require("spider").motion("b")<CR>', { desc = 'Spider-b' })
      vim.keymap.set({'o', 'x'}, 'o', '<cmd>lua require("spider").motion("w")<CR>', { desc = 'Spider-w' })
      vim.keymap.set({'o', 'x'}, 'e', '<cmd>lua require("spider").motion("e")<CR>', { desc = 'Spider-e' })
      vim.keymap.set({'o', 'x'}, 'u', '<cmd>lua require("spider").motion("b")<CR>', { desc = 'Spider-b' })
      vim.keymap.set({'n', 'o', 'x'}, 'ge', '<cmd>lua require("spider").motion("ge")<CR>', { desc = 'Spider-ge' })
    end,
  },
  { 'machakann/vim-sandwich' },
  { 'vim-scripts/bufonly.vim', enabled = notvscode },

  -- Filetype plugins
  { 'herringtondarkholme/yats.vim' },
  { 'aklt/plantuml-syntax' },
  { 'cakebaker/scss-syntax.vim' },
  { 'groenewege/vim-less' },
  { 'ipkiss42/xwiki.vim' },
  {
    'OXY2DEV/markview.nvim',
    enabled = notvscode,
    lazy = false,
    opts = {
      initial_state = false,
    },
  },
  { 'othree/yajs.vim' },
  { 'pangloss/vim-javascript' },
  {
    'posva/vim-vue',
    init = function ()
      vim.g.vue_pre_processors = 'detect_on_enter'
    end,
  },
  { 'sheerun/html5.vim' },
  { 'tpope/vim-git' },
}
local notvscode = vim.fn.has('vscode') ~= 1
print(notvscode)
return {
  -- Colorschemes
  { 'edeneast/nightfox.nvim', priority = 1000, enabled = notvscode },
  { 'ellisonleao/gruvbox.nvim', enabled = notvscode },
  { 'reedes/vim-colors-pencil', enabled = notvscode },

  -- Meta plugins
  { 'equalsraf/neovim-gui-shim' },
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-treesitter/nvim-treesitter' },
  { 'folke/lsp-colors.nvim', enabled = notvscode },
  { 'tpope/vim-repeat' },

  -- Architecture plugins
  { 'mhinz/vim-startify', enabled = notvscode },
  { 'airblade/vim-rooter' },
  { 'editorconfig/editorconfig-vim' },
  { 'conormcd/matchindent.vim' },
  { 'lewis6991/gitsigns.nvim' },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },

  -- Action plugins
  { 'mbbill/undotree', enabled = notvscode },
  { 'junegunn/goyo.vim', enabled = notvscode },
  { 'nvim-telescope/telescope.nvim', event = "VeryLazy", enabled = notvscode },
  { 'ggandor/leap.nvim' },

  -- Completion plugins
  { 'aduros/ai.vim' },
  {
    "jackMort/ChatGPT.nvim",
    enabled = notvscode,
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        keymaps = { submit = "<c-s>" },
        openai_params = {
          model = "gpt-3.5-turbo",
          frequency_penalty = 0,
          presence_penalty = 0,
          max_tokens = 256,
          temperature = 0.3,
          top_p = 1,
          n = 1,
        },
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    }
  },

  -- Text object plugins
  { 'glts/vim-textobj-comment',         dependencies = { 'kana/vim-textobj-user' } },
  { 'kana/vim-textobj-indent',          dependencies = { 'kana/vim-textobj-user' } },
  { 'lucapette/vim-textobj-underscore', dependencies = { 'kana/vim-textobj-user' } },
  { 'sgur/vim-textobj-parameter',       dependencies = { 'kana/vim-textobj-user' } },

  -- Command plugins
  { 'junegunn/vim-easy-align' },
  { 'machakann/vim-sandwich' },
  { 'scrooloose/nerdcommenter', enabled = notvscode },
  { 'tpope/vim-unimpaired', enabled = notvscode },
  { 'vim-scripts/bufonly.vim', enabled = notvscode },

  -- Filetype plugins
  { 'herringtondarkholme/yats.vim' },
  { 'aklt/plantuml-syntax' },
  { 'cakebaker/scss-syntax.vim' },
  { 'ipkiss42/xwiki.vim' },
  { 'othree/yajs.vim' },
  { 'pangloss/vim-javascript' },
  { 'posva/vim-vue' },
  { 'sheerun/html5.vim' },
  { 'tpope/vim-git' },
}
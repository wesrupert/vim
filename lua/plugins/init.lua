local notvscode = vim.g.vscode ~= 1

return {
  -- Colorschemes
  { 'edeneast/nightfox.nvim', priority = 1000, enabled = notvscode },
  { 'ellisonleao/gruvbox.nvim', enabled = notvscode },
  { 'reedes/vim-colors-pencil', enabled = notvscode },

  -- Meta plugins
  { 'equalsraf/neovim-gui-shim' },
  { 'nvim-lua/plenary.nvim' },
  { 'folke/lsp-colors.nvim', enabled = notvscode },
  { 'tpope/vim-repeat' },

  -- Architecture plugins
  { 'mhinz/vim-startify', enabled = notvscode },
  { 'airblade/vim-rooter' },
  { 'editorconfig/editorconfig-vim' },
  { 'conormcd/matchindent.vim' },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern='*',
        callback = function()
          vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { underline = true, sp = 'Grey' })
        end,
      })
    end,
  },

  -- Action plugins
  { 'mbbill/undotree', enabled = notvscode },
  { 'junegunn/goyo.vim', enabled = notvscode },
  { 'ggandor/leap.nvim' },

  -- Completion plugins
  { 'aduros/ai.vim' },
  {
    'jackmort/chatgpt.nvim',
    dependencies = {
      'muniftanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim'
    },
    enabled = notvscode,
    event = 'VeryLazy',
    opts = {
      keymaps = {
        submit = '<c-s>',
      },
      openai_params = {
        model = 'gpt-3.5-turbo',
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 256,
        temperature = 0.3,
        top_p = 1,
        n = 1,
      },
    }
  },

  -- Text object plugins
  { 'glts/vim-textobj-comment', dependencies = { 'kana/vim-textobj-user' } },
  { 'kana/vim-textobj-indent', dependencies = { 'kana/vim-textobj-user' } },
  { 'lucapette/vim-textobj-underscore', dependencies = { 'kana/vim-textobj-user' } },
  { 'sgur/vim-textobj-parameter', dependencies = { 'kana/vim-textobj-user' } },

  -- Command plugins
  { 'junegunn/vim-easy-align' },
  { 'machakann/vim-sandwich' },
  { 'scrooloose/nerdcommenter', enabled = notvscode },
  { 'tpope/vim-unimpaired', enabled = notvscode },
  { 'vim-scripts/bufonly.vim', enabled = notvscode },

  -- LSP plugins
  {
    'williamboman/mason.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    build = ':MasonUpdate',
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function(_, opts)
      require('mason-lspconfig').setup(opts)
      require('mason-lspconfig').setup_handlers({
        function (server_name)
          require('lspconfig')[server_name].setup({})
        end,
        ['lua_ls'] = function(server_name)
          require('lspconfig')[server_name].setup({
            settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
          })
        end
      })
    end,
  },

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
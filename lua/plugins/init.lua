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

  -- Mini plugins
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.splitjoin').setup()
      if notvscode then
        require('mini.sessions').setup()
        local starter = require('mini.starter')
        starter.setup({
          items = {
            starter.sections.sessions(5, true),
            { section = 'Telescope', name = 'Files',   action = 'Telescope find_files', },
            { section = 'Telescope', name = 'Tracked', action = 'Telescope git_files',  },
            { section = 'Telescope', name = 'Recent',  action = 'Telescope oldfiles',   },
            { section = 'Telescope', name = 'Grep',    action = 'Telescope live_grep',  },
            starter.sections.recent_files(10, false),
            starter.sections.recent_files(10, true),
          },
          content_hooks = {
            starter.gen_hook.adding_bullet(),
            starter.gen_hook.aligning('center', 'center'),
          },
        })
      end
    end,
    init = function ()
      vim.keymap.set('n', '<leader>ss', '<cmd>lua MiniSessions.select()<cr>', { desc = 'MiniSession-select' })
      vim.keymap.set('n', '<leader>sw', '<cmd>lua MiniSessions.write(vim.fn.input("Session Name > "))<cr>', { desc = 'MiniSession-write' })
    end
  },

  -- Architecture plugins
  { 'airblade/vim-rooter' },
  { 'editorconfig/editorconfig-vim' },
  { 'conormcd/matchindent.vim' },

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
  {
    'chrisgrieser/nvim-spider',
    lazy = true,
    init = function()
      vim.keymap.set('n', 'w', '<cmd>lua require("spider").motion("w")<CR>', { desc = 'Spider-w' })
      vim.keymap.set('n', 'e', '<cmd>lua require("spider").motion("e")<CR>', { desc = 'Spider-e' })
      vim.keymap.set('n', 'b', '<cmd>lua require("spider").motion("b")<CR>', { desc = 'Spider-b' })
      vim.keymap.set({'o', 'x'}, 'u', '<cmd>lua require("spider").motion("w")<CR>', { desc = 'Spider-w' })
      vim.keymap.set({'o', 'x'}, 'o', '<cmd>lua require("spider").motion("e")<CR>', { desc = 'Spider-e' })
      vim.keymap.set({'o', 'x'}, 'p', '<cmd>lua require("spider").motion("b")<CR>', { desc = 'Spider-b' })
      vim.keymap.set({'n', 'o', 'x'}, 'gw', '<cmd>lua require("spider").motion("gw")<CR>', { desc = 'Spider-gw' })
      vim.keymap.set({'n', 'o', 'x'}, 'ge', '<cmd>lua require("spider").motion("ge")<CR>', { desc = 'Spider-ge' })
      vim.keymap.set({'n', 'o', 'x'}, 'gb', '<cmd>lua require("spider").motion("gb")<CR>', { desc = 'Spider-gb' })
    end,
  },
  { 'junegunn/vim-easy-align' },
  { 'machakann/vim-sandwich' },
  { 'scrooloose/nerdcommenter', enabled = notvscode },
  { 'tpope/vim-unimpaired', enabled = notvscode },
  { 'vim-scripts/bufonly.vim', enabled = notvscode },

  -- Filetype plugins
  { 'herringtondarkholme/yats.vim' },
  { 'aklt/plantuml-syntax' },
  { 'cakebaker/scss-syntax.vim' },
  { 'groenewege/vim-less' },
  { 'ipkiss42/xwiki.vim' },
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
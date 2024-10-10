local notvscode = vim.g.vscode ~= 1

return {
  {
    'nvim-treesitter/nvim-treesitter',
    enabled = notvscode,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'joosepalviste/nvim-ts-context-commentstring',
      'andymass/vim-matchup',
      'windwp/nvim-ts-autotag',
    },
    cmd = {
      'TSBufDisable', 'TSBufEnable', 'TSBufToggle', 'TSDisable', 'TSEnable', 'TSToggle',
      'TSInstall', 'TSInstallInfo', 'TSInstallSync', 'TSModuleInfo', 'TSUninstall', 'TSUpdate', 'TSUpdateSync',
    },
    build = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
    opts = function()
      return {
        ensure_installed = {
          'css',
          'html',
          'javascript',
          'lua',
          'markdown',
          'python',
          'typescript',
          'vim',
          'vue',
        },
        compilers = { 'clang' },
        sync_install = false,
        auto_install = false,
        highlight = {
          enable = notvscode,
          additional_vim_regex_highlighting = { 'markdown' },
        },
        indent = {
          enable = true,
        },
        matchup = {
          enable = true,
        },
        autotag = {
          enable = true,
        },
        context_commentstring = {
          enable = true
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['if'] = '@function.inner',
              ['af'] = '@function.outer',
              ['ia'] = '@parameter.inner',
              ['aa'] = '@parameter.outer',
              ['ib'] = '@block.outer',
              ['ab'] = '@block.outer',
              ['ic'] = '@class.inner',
              ['ac'] = '@class.outer',
            },
            selection_modes = {
              ['@function.inner'] = 'V', -- linewise
              ['@function.outer'] = 'V', -- linewise
              ['@parameter.inner'] = 'v', -- charwise
              ['@parameter.outer'] = 'v', -- charwise
              ['@block.inner'] = 'V', -- blockwise
              ['@block.outer'] = 'V', -- blockwise
              ['@class.inner'] = 'V', -- blockwise
              ['@class.outer'] = 'V', -- blockwise
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']f'] = '@function.inner',
              [']a'] = '@parameter.outer',
              [']b'] = '@block.inner',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']F'] = '@function.outer',
              [']A'] = '@parameter.outer',
              [']B'] = '@block.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[f'] = '@function.inner',
              ['[a'] = '@parameter.outer',
              ['[b'] = '@block.inner',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[F'] = '@function.outer',
              ['[A'] = '@parameter.outer',
              ['[B'] = '@block.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>sf'] = '@function.outer',
              ['<leader>sa'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>sF'] = '@function.outer',
              ['<leader>sA'] = '@parameter.inner',
            },
          },
        },
      }
    end,
    init = function ()
      vim.o.foldlevelstart = 999
      vim.o.foldlevel = 999
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function ()
      vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { underline = true, sp = 'Grey' })
    end,
  },
  {
    'drybalka/tree-climber.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function ()
      local keyopts = { noremap = true, silent = true }
      vim.keymap.set({'n', 'v', 'o'}, ']t', require('tree-climber').goto_next, keyopts)
      vim.keymap.set({'n', 'v', 'o'}, '[t', require('tree-climber').goto_prev, keyopts)
      vim.keymap.set({'n', 'v', 'o'}, ']T', require('tree-climber').goto_child, keyopts)
      vim.keymap.set({'n', 'v', 'o'}, '[T', require('tree-climber').goto_parent, keyopts)
      vim.keymap.set({'v', 'o'}, 'an', require('tree-climber').select_node, keyopts)
      vim.keymap.set({'v', 'o'}, 'in', require('tree-climber').select_node, keyopts)
      vim.keymap.set('n', '<leader>sn', require('tree-climber').swap_next, keyopts)
      vim.keymap.set('n', '<leader>sN', require('tree-climber').swap_prev, keyopts)
    end,
  },
}
return {
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'andymass/vim-matchup',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    cmd = {
      'TSBufDisable', 'TSBufEnable', 'TSBufToggle', 'TSDisable', 'TSEnable', 'TSToggle',
      'TSInstall', 'TSInstallInfo', 'TSInstallSync', 'TSModuleInfo', 'TSUninstall', 'TSUpdate', 'TSUpdateSync',
    },
    build = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
    end,
    opts = function()
      return {
        ensure_installed = { 'vim', 'markdown', 'lua', 'php', 'css', 'javascript', 'typescript', 'vue' },
        sync_install = true,
        auto_install = true,
        highlight = {
          enable = vim.g.vscode ~= 1,
          additional_vim_regex_highlighting = { 'markdown' },
        },
        indent = {
          enable = true,
        },
        matchup = {
          enable = true,
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
  },
}
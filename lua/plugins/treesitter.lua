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
    config = function(_, opts) require('nvim-treesitter.configs').setup(opts) end,
    opts = function()
      local notvscode = vim.fn.has('vscode') ~= 1
      return {
        ensure_installed = { 'vim', 'markdown', 'lua', 'php', 'css', 'javascript', 'typescript', 'vue' },
        sync_install = true,
        auto_install = true,
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
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['ab'] = '@block.outer',
              ['ib'] = '@block.outer',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
            selection_modes = {
              ['@parameter.inner'] = 'v', -- charwise
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.inner'] = 'V', -- linewise
              ['@function.outer'] = 'V', -- linewise
              ['@block.inner'] = 'V', -- blockwise
              ['@block.outer'] = 'V', -- blockwise
              ['@class.inner'] = 'V', -- blockwise
              ['@class.outer'] = 'V', -- blockwise
            },
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']p'] = '@parameter.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']P'] = '@parameter.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[p'] = '@parameter.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[P'] = '@parameter.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>sp'] = '@parameter.inner',
              ['<leader>sf'] = '@function.outer',
            },
            swap_previous = {
              ['<leader>sP'] = '@parameter.inner',
              ['<leader>sF'] = '@function.outer',
            },
          },
        },
      }
    end,
  },
}
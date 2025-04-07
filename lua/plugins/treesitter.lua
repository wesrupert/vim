local util = require('util')

return {
  {
    'nvim-treesitter/nvim-treesitter',
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
          enable = util.not_vscode,
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
              ['@function.inner'] = 'V', -- line-wise
              ['@function.outer'] = 'V', -- line-wise
              ['@parameter.inner'] = 'v', -- char-wise
              ['@parameter.outer'] = 'v', -- char-wise
              ['@block.inner'] = 'V', -- block-wise
              ['@block.outer'] = 'V', -- block-wise
              ['@class.inner'] = 'V', -- block-wise
              ['@class.outer'] = 'V', -- block-wise
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
              ['<leader>sb'] = '@block.inner',
            },
            swap_previous = {
              ['<leader>sF'] = '@function.outer',
              ['<leader>sA'] = '@parameter.inner',
              ['<leader>sB'] = '@block.inner',
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
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    cond = util.not_vscode,
    opts = {
      on_attach = function ()
        -- Disable when lspsaga breadcrumb is enabled
        return not pcall(require, 'lspsaga.symbol.winbar')
      end
    },
    init = function ()
      vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { underline = true, sp = 'Grey' })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'LspAttach' }, {
        group = vim.api.nvim_create_augroup('UserTreesitterConfig', { clear = true }),
        callback = function()
          local ts_context = require('treesitter-context')
          local enabled = ts_context.enabled()
          local lspsaga_winbar_loaded, lspsaga_winbar = pcall(require, 'lspsaga.symbol.winbar')
          local should_enable = not lspsaga_winbar_loaded or lspsaga_winbar.get_bar() == nil
          if should_enable and not enabled then
            ts_context.enable()
          elseif not should_enable and enabled then
            ts_context.disable()
          end
        end,
      })
    end,
  },
  {
    'drybalka/tree-climber.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function ()
      local tree_climber = require('tree-climber')
      util.keymap(']T',         '[TreeSitter] Jump child',        tree_climber.goto_child,  { 'n', 'v', 'o' })
      util.keymap('[T',         '[TreeSitter] Jump parent',       tree_climber.goto_parent, { 'n', 'v', 'o' })
      util.keymap('an',         '[TreeSitter] Select node',       tree_climber.select_node, { 'v', 'o' })
      util.keymap('in',         '[TreeSitter] Select inner node', tree_climber.select_node, { 'v', 'o' })
      util.keymap('<leader>sn', '[TreeSitter] Swap next node',    tree_climber.swap_next)
      util.keymap('<leader>sN', '[TreeSitter] Swap prev node',    tree_climber.swap_prev)
    end,
  },
}
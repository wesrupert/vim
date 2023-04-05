let s:vimdir = has('win32') ? '$HOME/vimfiles' : '~/.vim'
let &rtp .= ','.expand(s:vimdir)
let s:vimrc = expand(s:vimdir.'/vimrc')
if filereadable(s:vimrc)
  execute 'source '.s:vimrc
endif

set inccommand=split
set wildoptions+=pum

" Lua config {{{
if has('nvim')
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

lua << EOF
local vscode = vim.fn.has('vscode')

require 'plugins/cmp'

require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    'vim', 'markdown', 'lua', 'php', 'css', 'javascript', 'typescript',
    -- Vue is failing with uv_dlopen errors in _ts_add_language. TODO: RC
    -- 'vue',
  },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = not vscode,
    additional_vim_regex_highlighting = { 'markdown' },
    },
  indent = {
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

if not vscode then
  local telescope_config = require('telescope.config')
  local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
  table.insert(vimgrep_arguments, '--hidden')
  table.insert(vimgrep_arguments, '--glob')
  table.insert(vimgrep_arguments, '!.git/*')
  require'telescope'.setup {
    defaults = {
      vimgrep_arguments = vimgrep_arguments,
      },
    pickers = {
      find_files = {
        find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' },
        },
      },
    }
end

require'gitsigns'.setup{
  current_line_blame = not vscode,
  signcolumn = not vscode,
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>')
    map({'n', 'v'}, '<leader>hr', '<cmd>Gitsigns reset_hunk<cr>')
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<c-U>Gitsigns select_hunk<cr>')
  end
}

EOF
endif
" }}}


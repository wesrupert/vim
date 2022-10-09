let s:vimdir = has('win32') ? '$HOME/vimfiles' : '~/.vim'
let &rtp .= ','.expand(s:vimdir)
let s:vimrc = expand(s:vimdir.'/vimrc')
if filereadable(s:vimrc)
  execute 'source '.s:vimrc
endif

set inccommand=split
set wildoptions+=pum

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

" Lua config {{{
if has('nvim')
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    'vim', 'lua', 'php', 'html', 'css', 'javascript', 'typescript', 'vue',
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
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
        [']]'] = '@class.outer',
        },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
        },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
        },
      goto_previous_end = {
        ['[M'] = '@function.outer',
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

local telescopeConfig = require("telescope.config")
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
table.insert(vimgrep_arguments, "--hidden")
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!.git/*")
require"telescope".setup {
  defaults = {
    vimgrep_arguments = vimgrep_arguments,
    },
  pickers = {
    find_files = {
      find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
      },
    },
  }

EOF
endif
" }}}


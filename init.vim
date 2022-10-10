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
    'vim', 'markdown', 'lua', 'php', 'css', 'javascript',
    'typescript', 'vue',
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
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

local cmp = require'cmp'
cmp.setup {
  window = { documentation = cmp.config.window.bordered() },
  mapping = cmp.mapping.preset.insert {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'omni' },
    { name = 'treesitter' },
    { name = 'rg' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'calc' },
    },
}

cmp.setup.filetype({ 'javascript', 'typescript', 'vue' }, {
  sources = {
    { name = 'npm', keyword_length = 3 },
  }
})

cmp.setup.filetype({ 'markdown', 'txt' }, {
  sources = {
    { name = 'spell' },
  }
})

cmp.setup.filetype({ 'conf', 'config', 'vim' }, {
  sources = {
    { name = 'fonts' },
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'cmdline' },
  })
})

EOF
endif
" }}}


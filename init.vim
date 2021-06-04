let s:vimdir = has('win32') ? '$HOME/vimfiles' : '~/.vim'
let &rtp .= ','.expand(s:vimdir)
let s:vimrc = expand(s:vimdir.'/vimrc')
if filereadable(s:vimrc)
    execute 'source '.s:vimrc
endif

lua << EOF
require'lspinstall'.setup()
local servers = require'lspinstall'.installed_servers()
for _, server in pairs(servers) do
      require'lspconfig'[server].setup{}
  end

EOF

set inccommand=split
set wildoptions+=pum
let g:markdown_preview_auto = 1

noremap <f11> :ToggleFullscreen<cr>

command! ToggleFullscreen call ToggleFullscreen()

function! ToggleFullscreen()
    call GuiWindowFullScreen(!get(g:, 'GuiWindowFullScreen', 0))
endfunction

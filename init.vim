let s:vimrc = expand(has('win32') ? '$HOME/vimfiles/vimrc' : '~/.vim/vimrc')
if filereadable(s:vimrc)
    execute 'source '.s:vimrc
endif

set inccommand=split
let g:markdown_preview_auto = 1

set termguicolors

let s:vimrc = expand(has('win32') ? '$HOME/vimfiles/vimrc' : '~/.vim/vimrc')
if filereadable(s:vimrc)
    execute 'source '.s:vimrc
endif

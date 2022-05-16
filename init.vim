let s:vimdir = has('win32') ? '$HOME/vimfiles' : '~/.vim'
let &rtp .= ','.expand(s:vimdir)
let s:vimrc = expand(s:vimdir.'/vimrc')
if filereadable(s:vimrc)
    execute 'source '.s:vimrc
endif

set inccommand=split
set wildoptions+=pum

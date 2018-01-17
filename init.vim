let s:vimdir = has('win32') ? '$HOME/vimfiles' : '~/.vim'
let &rtp .= ','.expand(s:vimdir)
let s:vimrc = expand(s:vimdir.'/vimrc')
if filereadable(s:vimrc)
    execute 'source '.s:vimrc
endif

set inccommand=split
let g:markdown_preview_auto = 1

noremap <f11> :ToggleFullscreen<cr>

command! ToggleFullscreen call ToggleFullscreen()

function! ToggleFullscreen()
    call GuiWindowFullScreen(!get(g:, 'GuiWindowFullScreen', 0))
endfunction

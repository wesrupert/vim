" Load RainbowParens whenever the filetype is changed to scheme.
RainbowParenthesesLoadRound

" Lazy remapping of shift parens.
inoremap <buffer> 9 (
inoremap <buffer> 0 )
inoremap <buffer> ( 9
inoremap <buffer> ) 0

" Press <f2> to launch racket with the script loaded.
noremap <buffer> <f2> :w<cr>:!racket -f % -i<cr>

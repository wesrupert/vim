" Script functions {{{ {{{

function! s:GenerateCAbbrev(orig, complStart, new) " {{{
    let l = len(a:orig)
    if a:complStart > l | let a:complStart = l | endif
    while l >= a:complStart
        let s = strpart(a:orig, 0, l)
        execute "cabbrev ".s." <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? '".a:new."' : '".s."')<CR>"
        let l = l - 1
    endwhile
endfunction " }}}

function! s:IsGui() " {{{
    return has('gui_running') || (has('nvim') && get(g:, 'GuiLoaded', 0) == 1)
endfunction " }}}

function! s:TryCreateDir(path) " {{{
    if !filereadable(a:path) && filewritable(a:path) != 2
        call mkdir(a:path, 'p')
    endif
endfunction " }}}

function! s:TrySourceFile(path, backup, assign) " {{{
    let l:path = filereadable(a:path) ? a:path : filereadable(a:backup) ? a:backup : ''
    if l:path != ''
        silent execute 'source '.l:path
        if a:assign != ''
            silent execute 'let '.a:assign.' = "'escape(l:path, '\').'"'
        endif
    endif
endfunction " }}}

" }}} }}}

let g:vimrc = expand(has('win32') ? '$HOME/vimfiles/vimrc' : '~/.vim/vimrc')
let g:vimplug = expand(has('win32') ? '$HOME/vimfiles/plug' : '~/.vim/plug')
call s:TrySourceFile(g:vimrc.'.leader', g:vimrc.'.before', 'g:vimrc_leader')

" Preferences and Settings {{{

" Application settings
syntax on
filetype plugin indent on
set autoread noautochdir hidden
set diffopt=filler,context:3
set encoding=utf-8 spelllang=en_us
set guioptions=gt guicursor+=n-v-c:blinkon0 mouse=a
set lazyredraw synmaxcol=300
set modeline modelines=1
set noerrorbells belloff=all visualbell t_vb=
set number norelativenumber
set scrolloff=3 sidescrolloff=1 sidescroll=1
set shortmess+=A
set splitbelow splitright
set switchbuf=usetab
set tabline=%!TermTabLabel() guitablabel=%{GuiTabLabel()} guitabtooltip=%{GuiTabToolTip()}
set termguicolors
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
set updatetime=500

" Command bar
set gdefault
set ignorecase smartcase infercase
set incsearch hlsearch
set laststatus=2 showcmd ruler noshowmode
set wildmenu completeopt=longest,menuone,preview
if executable('rg')
    set grepprg=rg\ -i\ --vimgrep
endif

" Text options
set autoindent smartindent
set backspace=indent,eol,start
set conceallevel=2
set cursorline
set expandtab smarttab
set foldmethod=syntax foldenable foldlevelstart=10
set formatoptions=cjnr
set linebreak breakindent
set list listchars=tab:»\ ,space:·,trail:-,precedes:…,extends:…
set nowrap
set tabstop=4 softtabstop=4 shiftwidth=4

" Custom settings
let g:diff_width = 50
let g:height_buffer = 3
let g:height_proportion = 75
let g:idemode = 0
let g:opensplit_on_right = 0
let g:opensplit_threshold = 60
let g:width_buffer = 3
let g:width_proportion = 66

" }}}

" Statusline {{{

let g:modemap={
            \ 'n'  : 'Norm',
            \ 'no' : 'OpPd',
            \ 'v'  : ' Vis',
            \ 'V'  : 'VLin',
            \ '^V' : 'VBlk',
            \ 's'  : 'Slct',
            \ 'S'  : 'SlLn',
            \ '^S' : 'SBlk',
            \ 'i'  : ' Ins',
            \ 'R'  : 'Rplc',
            \ 'Rv' : 'VRpl',
            \ 'c'  : ' Cmd',
            \ 'cv' : 'VmEx',
            \ 'ce' : ' Ex ',
            \ 'r'  : 'Prmt',
            \ 'rm' : 'More',
            \ 'r?' : 'Cnfm',
            \ '!'  : 'Shll',
            \ 't'  : 'Term'}
function! s:StatusLine()
    set statusline=%#StatusLine#                                       " Sub color
   " set statusline+=\ %n                                              " Buffer number
    set statusline+=\ %{SL_ModeCurrent()}\                             " Abbreviated current mode
    set statusline+=%#StatusLineNC#                                    " Main color
   " set statusline+=\ %{SL_FilePath(20)}                              " File full path with truncation
    set statusline+=%#PMenu#\ %t\ %#StatusLineNC#                      " Filename
    set statusline+=%(\ \[%{SL_FileType()}\]%)                         " Filetype if it doesn't match extension
    set statusline+=%(\ [%R%M]%)%w%q                                   " Buffer flags
    set statusline+=%=                                                 " Move to right side
    set statusline+=%{&fileencoding?&fileencoding:&encoding}           " Buffer encoding
    set statusline+=\[%{&fileformat}\]                                 " Buffer format
    set statusline+=\ %#PMenu#%(\ %{SL_GitBranch()}\ %)%#StatusLineNC# " Git branch
    set statusline+=%#StatusLine#                                      " Sub color
    set statusline+=\ %p%%\ [%l:%c]\                                   " Cursor location
endfunction
call s:StatusLine()

function! SL_ModeCurrent() abort
    let l:currentmode = mode()
    " use get() -> fails safely, since ^V doesn't seem to register
    " 3rd arg is used when return of mode() == 0, which is case with ^V
    " thus, ^V fails -> returns 0 -> replaced with 'V Block'
    let l:modelist = toupper(get(g:modemap, l:currentmode, 'VBlk'))
    let l:current_status_mode = l:modelist
    return l:current_status_mode
endfunction

function! SL_FilePath(len)
    let dirs = split(expand('%:p:h'), g:slash)
    let path = ''
    for dir in dirs
        if (strpart(dir, 1, 1) == ':')
            let path .= dir.g:slash
        else
            let path .= strpart(dir, 0, 1).g:slash
        endif
    endfor
    return strpart(path, 0, len(path)-1)
endfunction

function! SL_FileType()
    return expand('%:e') == &filetype ? '' : &filetype
endfunction

function! SL_GitBranch()
    return matchstr(fugitive#statusline(), '(\zs.*\ze)')
endfunction

function! SL_FileSize() abort
    let l:bytes = getfsize(expand('%p'))
    if (l:bytes >= 1024)
        let l:kbytes = l:bytes / 1025
    endif
    if (exists('kbytes') && l:kbytes >= 1000)
        let l:mbytes = l:kbytes / 1000
    endif
 
    if l:bytes <= 0
        return '0'
    endif
  
    if (exists('mbytes'))
        return l:mbytes . 'MB '
    elseif (exists('kbytes'))
        return l:kbytes . 'KB '
    else
        return l:bytes . 'B '
    endif
endfunction

" }}}

" Keybindings and Commands {{{

" Sort via :sort /.*\%18v/
 noremap          "             '
 noremap          '             "
 noremap          -             _
     map          /             <Plug>(incsearch-forward)
 noremap          :             ;
 noremap          ;             :
inoremap          <c-backspace> <c-w>
inoremap          <c-,>         <c-d>
inoremap          <c-.>         <c-t>
 noremap <silent> <a-o>         <c-i>
 noremap <silent> <a-p>         :History<cr>
 noremap <silent> <c-a>         <esc>ggVG
inoremap <silent> <c-a>         <esc>ggVG
 noremap <silent> <c-p>         :Files<cr>
 noremap <silent> <c-b>         :Buffers<cr>
    "map          <c-e>         {TAKEN: Open file explorer}
 noremap <silent> <c-f>         :Lines<cr>
 noremap <silent> <c-h>         <c-w>h
 noremap <silent> <c-j>         <c-w>j
 noremap <silent> <c-k>         <c-w>k
 noremap <silent> <c-l>         <c-w>l
 noremap          <c-q>         Q
 noremap          <c-w><c-w>    :tabclose<cr>
    imap <silent> <c-space>     <tab>
 noremap <silent> <c-t>         :tabnew<cr>
 noremap <silent> <expr> j      v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
 noremap <silent> <expr> k      v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
 noremap <silent> <leader>'     :if &go=~#'r'<bar>set go-=r<bar>else<bar>set go+=r<bar>endif<cr>
 noremap <silent> <leader>-     :execute 'Lexplore '.expand('%:p:h')<cr>
 noremap <silent> <leader>/     :nohlsearch<cr>
 noremap <silent> <leader>[     :setlocal wrap!<cr>:setlocal wrap?<cr>
 noremap <silent> <leader>]     :setlocal number!<cr>:setlocal number?<cr>
 noremap <silent> <leader>c,    :cd ..<cr>:echo ':cd '.getcwd()<cr>
 noremap <silent> <leader>cd    :execute 'cd '.expand('%:p:h')<cr>:echo ':cd '.getcwd()<cr>
 noremap          <leader>co    :Colors<cr>
 noremap <silent> <leader>d     <c-x>
 noremap <silent> <leader>f     <c-a>
 noremap <silent> <leader>i     :set foldmethod=indent<cr>
    "map          <leader>j     {TAKEN: Json tool}
 noremap <silent> <leader>l     :setlocal list!<cr>:setlocal list?<cr>
 noremap <silent> <leader>ro    :set winheight=1 winwidth=1<cr>
 noremap          <leader>s     :%s/\<<c-r><c-w>\>/
 noremap <silent> <leader>u     :UndotreeToggle<cr>:UndotreeFocus<cr>
 noremap <silent> <leader>va    :call OpenSplit(g:vimrc_custom, 50, 0)<cr>
 noremap <silent> <leader>vb    :call OpenSplit(g:vimrc_leader, 50, 0)<cr>
 noremap <silent> <leader>vp    :call OpenSplit(g:vimrc.'.plugins', 50, 0)<cr>
 noremap <silent> <leader>vc    :call OpenSplit(g:vimrc.'.plugins.custom', 50, 0)<cr>
 noremap <silent> <leader>vr    :call OpenSplit(g:vimrc, 50, 0)<cr>
 noremap <silent> <leader>vz    :execute 'source '.g:vimrc<cr>
 noremap <silent> <leader>w     :execute 'resize '.line('$')<cr>
nnoremap          <space>       za
nnoremap          <tab>         gt
 noremap <silent> <s-tab>       gT
vnoremap          <tab>         %
inoremap          <tab>         <c-r>=TabOrComplete()<cr>
     map          ?             <Plug>(incsearch-backward)
 noremap <silent> K             :Help <c-r><c-w><cr>
 noremap          Q             :q<cr>
 noremap          Y             y$
 noremap          [[            ^
 noremap <silent> []            /;<cr>:noh<cr>
 noremap <silent> ][            ?;<cr>:noh<cr>
 noremap          ]]            $
 noremap          _             -
     map          g/            <Plug>(incsearch-stay)
 noremap <silent> gO            m'O<esc>cc<esc><c-o>
 noremap <silent> gV            `[v`]
xnoremap          ga            <Plug>(EasyAlign)
 noremap          ga            <Plug>(EasyAlign)
 noremap <silent> go            m'o<esc>cc<esc><c-o>
 noremap          gs            :Scratch<cr>
 noremap <silent> gw            :silent !explorer <cWORD><cr>
inoremap          kj            <esc>
 noremap          ss            s
 noremap          zj            jzz
 noremap          zk            kzz
if has('python') | noremap <leader>j :%!python -m json.tool<cr>| endif
if (exists('g:mapleader')) | execute 'noremap \ '.g:mapleader | endif

command! -nargs=0 Light   set background=light
command! -nargs=0 Dark    set background=dark
command! -nargs=0 Scratch call OpenScratch()
command! -nargs=1 -complete=help Help call OpenHelp(<f-args>)
command! -nargs=1 -complete=help THelp tab help <args>
command! -nargs=+ -complete=file_in_path Grep  execute 'silent grep! <args>' | copen
command! -nargs=+ -complete=file_in_path LGrep execute 'silent lgrep! <args>' | lopen

call s:GenerateCAbbrev('help', 1, 'Help')
call s:GenerateCAbbrev('thelp', 2, 'THelp')
call s:GenerateCAbbrev('grep', 2, 'Grep')
call s:GenerateCAbbrev('rg', 2, 'Grep')
call s:GenerateCAbbrev('lgrep', 2, 'LGrep')

" }}}

" Platform-Specific Settings {{{ {{{

if has('win32')
    let g:slash = '\'
    if filewritable($TMP) == 2
        let g:temp = expand($TMP).'\Vim'
    elseif filewritable($TEMP) == 2
        let g:temp = expand($TEMP).'\Vim'
    elseif filewritable('C:\TMP') == 2
        let g:temp = 'C:\TMP\Vim'
    else
        let g:temp = 'C:\TEMP\Vim'
    endif
    call s:TryCreateDir(g:temp)

    source $VIMRUNTIME/mswin.vim
    set selectmode=
    noremap <c-a> <c-c>ggVG
    noremap <c-v> "+gP
    noremap <silent> <c-h> <c-w>h

    noremap <silent> <c-e> :execute "silent !explorer ".shellescape(expand('%:p:h'))<cr>
else
    let g:slash = '/'
    if filewritable($TMPDIR) == 2
        let g:temp = expand($TMPDIR).'/vim'
    elseif filewritable('/tmp') == 2
        let g:temp = '/tmp/vim'
    else
        let g:temp = expand('$HOME').'/.vim/temp'
    endif
    call s:TryCreateDir(g:temp)

    map  <silent> <c-e> :silent !open .<cr>
endif

" }}} }}}

" Backup and Undo {{{ {{{

set backup writebackup
let s:backupdir = expand(g:temp.g:slash.'backups')
let &directory = s:backupdir.g:slash.g:slash
if has('autocmd')
    augroup Backups
        autocmd BufRead * let &l:backupdir = s:backupdir.g:slash.expand("%:p:h:t") |
                    \ call s:TryCreateDir(&l:backupdir)
    augroup END
endif
call s:TryCreateDir(s:backupdir)
if has('persistent_undo')
    call s:TryCreateDir(g:temp.g:slash.'undo')
    set undofile
    let &undodir = expand(g:temp.g:slash.'undo')
endif

" }}} }}}

" Load plugins {{{ {{{

" Update packpath
let s:packpath = fnamemodify(g:vimrc, ':p:h')
if match(&packpath, substitute(s:packpath, '[\\/]', '[\\\\/]', 'g')) == -1
    let &packpath .= ','.s:packpath
endif

" Legacy plugins
if !has('nvim')
    packadd! matchit
endif

" Modern Plugins
try
    call plug#begin(g:vimplug)
    call s:TrySourceFile(g:vimrc.'.plugins', '', '')
    call s:TrySourceFile(g:vimrc.'.plugins.custom', '', '')
    call plug#end()
catch
    echohl ErrorMsg
    echom 'Vim plug not found. Please install to '.$VIMRUNTIME.g:slash.'autoload.'
    echohl None
endtry

" Post-plugin configuration
let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes) + [
      \   {'buns': ['{ ', ' }'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['{']},
      \   {'buns': ['[ ', ' ]'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['[']},
      \   {'buns': ['( ', ' )'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['(']},
      \   {'buns': ['{\s*', '\s*}'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['{']},
      \   {'buns': ['\[\s*', '\s*\]'], 'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['[']},
      \   {'buns': ['(\s*', '\s*)'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['(']},
      \ ]

" Filetype Settings {{{ {{{
if has('autocmd')
    augroup Filetypes
        autocmd!
        autocmd FileType c,cpp,cs,h,js,ts onoremap <buffer> ip i{| onoremap <buffer> ap a{|
                    \ vnoremap <buffer> ip i{| vnoremap <buffer> ap a{|
        autocmd FileType cs setlocal foldmethod=indent
            autocmd BufRead *.md setlocal wrap nonumber norelativenumber
        autocmd BufNew,BufReadPre *.xaml,*.targets setf xml
        autocmd BufNew,BufReadPre *.xml,*.html let b:match_words = '<.\{-}[^/]>:</[^>]*>'
        autocmd FileType xml,html setlocal matchpairs+=<:> nospell
        autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0]) |
                    \ setlocal textwidth=72 formatoptions+=t colorcolumn=50,+0 |
                    \ setlocal scrolloff=0 sidescrolloff=0 sidescroll=1
    augroup END

    augroup HelpFiles
        autocmd!
        autocmd BufWinEnter * if (&buftype == 'help') |
                        \     setlocal winwidth=80 sidescrolloff=0 |
                        \     vertical resize 80 |
                        \     noremap <buffer> q <c-w>c |
                        \ endif
        autocmd BufWinEnter * if (&buftype == 'quickfix' || &previewwindow) | noremap <buffer> q <c-w>c | endif
    augroup END
endif
" }}} }}}

" Auto Commands {{{ {{{
if has('autocmd')
    augroup RememberCursor
        autocmd!
        autocmd BufReadPost * if line("'\'") > 0 && line("'\'") <= line('$') | exe "normal g`\"" | endif
    augroup END

    augroup Spelling
        autocmd!
        autocmd ColorScheme * hi clear SpellRare | hi clear SpellLocal
        autocmd FileType markdown,txt setlocal spell nocursorline norelativenumber wrap
        autocmd BufReadPost * if &l:modifiable == 0 | setlocal nospell | endif
    augroup END

    augroup AutoChDir
        autocmd!
        autocmd BufEnter * silent! lcd %:p:h
        autocmd BufEnter * if s:IsEmptyFile() | set ft=markdown | end
        autocmd BufWritePre * if !isdirectory(expand('<afile>:p:h')) |
                    \ call mkdir(expand('<afile>:p:h'), 'p') |
                    \ endif
    augroup END

    highlight link MixedWhitespace Underlined
    highlight link BadBraces NONE
    augroup MixedWhitespace
        autocmd!
        autocmd InsertEnter * highlight! link BadBraces Error
        autocmd InsertLeave * highlight! link BadBraces NONE
        autocmd BufEnter * match MixedWhitespace /\s*\(\( \t\)\|\(\t \)\)\s*/
        autocmd BufEnter *.c,*.cpp,*.cs,*.js,*.ps1,*.ts 2match BadBraces /[^}]\s*\n\s*\n\s*\zs{\ze\|\s*\n\s*\n\s*\zs}\ze\|\zs}\ze\s*\n\s*\(else\>\|catch\>\|finally\>\|while\>\|}\|\s\|\n\)\@!\|\zs{\ze\s*\n\s*\n/
    augroup END

    augroup WinHeight
        autocmd!
        autocmd VimResized * if (&buftype != 'help') |
                      \     let &l:winheight = ((&lines * g:height_proportion) / 100) - g:height_buffer |
                      \     let &l:winwidth = ((&columns * g:width_proportion) / 100) - g:width_buffer |
                      \ endif
    augroup END
endif
" }}} }}}

" Diff Settings (NOTE: must be last group, as it clears some augroups!) {{{ {{{
augroup DiffLayout
    autocmd VimEnter * if &diff | call s:SetDiffLayout() | endif
augroup END

function! s:SetDiffLayout() " {{{
    if has('autocmd')
        augroup RememberCursor | autocmd! | augroup END " Clear cursor jump command
    endif

    " Set split and start at the top of the new file
    execute 'vertical resize '.((&columns * g:diff_width) / 100)
    wincmd l | call setpos('.', [0, 1, 1, 0])

    let g:ale_enabled = 0 " Don't lint a readonly diff
    let g:airline_left_sep=''
    let g:airline_right_sep=''
    set nohidden bufhidden=delete
    set guioptions+=lr
    noremap q :qa<cr>
endfunction " }}}
" }}} }}}

" Load help docs {{{ {{{
" Credit goes to Tim Pope (https://tpo.pe/) for these functions.

function! s:Helptags() abort "| Invoke :helptags on all non-$VIM doc directories in runtimepath. {{{
    for glob in s:Split(&rtp)
        for dir in map(split(glob(glob), "\n"), 'v:val.g:slash."/doc/".g:slash')
            if (dir)[0 : strlen($VIMRUNTIME)] !=# $VIMRUNTIME.g:slash &&
                        \ filewritable(dir) == 2 &&
                        \ !empty(split(glob(dir.'*.txt'))) &&
                        \ (!filereadable(dir.'tags') || filewritable(dir.'tags'))
                silent! execute 'helptags' fnameescape(dir)
            endif
        endfor
    endfor
endfunction " }}}

function! s:Split(path) abort "| Split a path into a list. {{{
    if type(a:path) == type([]) | return a:path | endif
    if empty(a:path) | return [] | endif
    let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
    return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction " }}}

call s:Helptags()
" }}} }}}

" Functions {{{ {{{
" Tabs {{{
function! TermTabLabel() " {{{
    let label = ''
    for i in range(tabpagenr('$'))
        " Select the highlighting
        if i + 1 == tabpagenr()
            let label .= '%#TabLineSel#'
        else
            let label .= '%#TabLine#'
        endif

        " Set the tab page number (for mouse clicks)
        let label .= '%'.(i+1).'T'

        " The label is made by MyTabLabel()
        let label .= ' %{MyTabLabel('.(i+1).')} '

        " Add divider
        let label .= '%#TabLine#|'
    endfor

    " After the last tab fill with TabLineFill and reset tab page nr
    let label .= '%#TabLineFill#%T'

    " Right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let label .= '%=%#TabLine#%999XX'
    endif

    return label
endfunction " }}}

function! GuiTabLabel() " {{{
    return MyTabLabel(v:lnum)
endfunction " }}}

function! MyTabLabel(lnum) " {{{
    " Buffer name
    let bufnrlist = tabpagebuflist(a:lnum)
    let bufnr = tabpagewinnr(a:lnum) - 1
    let name = bufname(bufnrlist[bufnr])
    let modified = getbufvar(bufnrlist[bufnr], '&modified')
    let readonly = getbufvar(bufnrlist[bufnr], '&readonly')
    let readonly = readonly || !getbufvar(bufnrlist[bufnr], '&modifiable')


    if name != '' && name !~ 'NERD_tree'
        " Get the name of the first real buffer
        let name = fnamemodify(name, ':t')
    else
        let bufnr = len(bufnrlist)
        while (name == '' || name =~ 'NERD_tree') && bufnr >= 0
            let bufnr -= 1
            let name = bufname(bufnrlist[bufnr])
            let modified = getbufvar(bufnrlist[bufnr], '&modified')
        endwhile
        if name == ''
            if (&buftype == 'quickfix')
                " Don't show other marks
                let modified = 0
                let readonly = 0
                let name = '[Quickfix]'
            else
                let name = '[No Name]'
            endif
        else
            " Get the name of the first real buffer
            let name = fnamemodify(name, ':t')
        endif
    endif
    if name == 'Scratch.md'
        let name = '[Scratch]'
    endif
    if getbufvar(bufnrlist[bufnr], '&buftype') == 'help'
        " Don't show other marks
        let modified = 0
        let readonly = 0
        let name = 'H['.fnamemodify(name, ':r').']'
    endif
    let label = a:lnum.' '.name

    " The number of windows in the tab page
    let uncounted = 0
    for bufnr in bufnrlist
        let tmpname = bufname(bufnr)
        if tmpname == '' || tmpname =~ 'NERD_tree' || getbufvar(bufnr, '&buftype') == 'help'
            " We don't care about auxiliary buffer count, so if it's not in
            " focus, don't count it
            if bufnr != bufnrlist[tabpagewinnr(a:lnum) - 1]
                let uncounted += 1
            endif
        endif
    endfor
    let wincount = tabpagewinnr(a:lnum, '$') - uncounted
    if wincount > 1
        let label .= ' (..'.wincount

        " Add '[+]' inside the others section if one of the other buffers in
        " the tab page is modified
        for bufnr in bufnrlist
            if (modified == 0 && getbufvar(bufnr, '&modified'))
                let label .= ' [+]'
                break
            endif
        endfor

        let label .= ')'
    endif

    " Add '[+]' at the end if this buffer is modified, and '[-]' if it is readonly
    if modified == 1 || readonly == 1
        let label .= ' ['
        if modified == 1
            let label .= '+'
            if readonly == 1
                let label .= '/'
            endif
        endif
        if readonly == 1
            let label .= '-'
        endif
        let label .= ']'
    endif

    return label
endfunction " }}}

function! GuiTabToolTip() " {{{
    let tooltip = ''
    let bufnrlist = tabpagebuflist(v:lnum)
    for bufnr in bufnrlist
        let name=bufname(bufnr)
        if (name =~ 'NERD_tree')
            continue
        endif

        " Separate buffer entries
        if tooltip!=''
            let tooltip .= "\n"
        endif

        " Add name of buffer
        if name == ''
            " Give a name to no name documents
            if getbufvar(bufnr,'&buftype')=='quickfix'
                let name = '[Quickfix List]'
            else
                let name = '[No Name]'
            endif
        elseif getbufvar(bufnr,'&buftype')=='help'
            let name = 'help: '.fnamemodify(name, ':p:t:r')
        else
            let name = fnamemodify(name, ':p:t')
        endif
        let tooltip .= name

        " add modified/modifiable flags
        if getbufvar(bufnr, '&modified')
            let tooltip .= ' [+]'
        endif
        if getbufvar(bufnr, '&modifiable') == 0 || getbufvar(bufnr, '&readonly') == 1
            let tooltip .= ' [-]'
        endif
    endfor
    return tooltip
endfunction " }}}
" }}}

function! OpenHelp(topic) " {{{
    try
        call OpenSplit('help '.a:topic, 80, 1)
    catch
        echohl ErrorMsg | echo 'Help:'.split(v:exception, ':')[-1] | echohl None
    endtry
endfunction " }}}

function! OpenScratch() " {{{
    call OpenSplit(expand('$HOME'.g:slash.'Scratch.md'), 50, 0)
    noremap <buffer> <silent> q :update<cr><bar><c-w>c
    autocmd CursorHold <buffer> silent update
    normal ggGG
endfunction " }}}

function! OpenSplit(input, threshold, iscommand) " {{{
    let splitright = get(g:, 'opensplit_on_right', &splitright)
    let open = !s:IsEmptyFile() ? &columns >= a:threshold + g:opensplit_threshold ? 
                \ (a:iscommand ? 'vert ' : 'vsplit ') :
                \ (a:iscommand ? 'tab '  : 'tabnew ') :
                \ (a:iscommand ? ''      : 'edit '  )
    execute l:open.a:input

    execute 'wincmd '.(l:splitright ? 'L' : 'H')
    execute 'vertical resize '.a:threshold
    noremap <buffer> <silent> q <c-w>c
    if l:open =~# 'v\(ert\|split\)'
        let &l:textwidth = a:threshold
        setlocal nonumber norelativenumber
        nmap <buffer> <silent> <esc> q
    endif
endfunction " }}}

function! SynStack() "{{{
    let list = ''
    if exists('*synstack')
        let list = join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), ',')
    endif
    return '['.l:list.']'
endfunction "}}}

function! s:IsEmptyFile() " {{{
    if @% != ''                            " Not-empty filename
        return 0
    elseif filereadable(@%) != 0           " File exists on disk
        return 0
    elseif line('$') != 1 || col('$') != 1 " Buffer has contents
        return 0
    endif
    return 1
endfunction " }}}

function! TabOrComplete() "{{{
    return col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w' ? "\<c-n>" : "\<tab>"
endfunction "}}}
" }}} }}}

call s:TrySourceFile(g:vimrc.'.custom', g:vimrc.'.after', 'g:vimrc_custom')

" vim: foldmethod=marker foldlevel=1

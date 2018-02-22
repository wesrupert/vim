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

function! s:IsGui() " {{{
    return has('gui_running') || (has('nvim') && get(g:, 'GuiLoaded', 0) == 1)
endfunction " }}}

function! s:TryCreateDir(path) " {{{
    if !filereadable(a:path) && filewritable(a:path) == 0
        try
            call mkdir(a:path, 'p')
            return 1
        catch /E739/ | endtry
    endif
    return 0
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
set hidden switchbuf=usetab splitbelow splitright
set noerrorbells belloff=all visualbell t_vb=
set nospell diffopt+=context:3
set scrolloff=3 sidescrolloff=1 sidescroll=1
set shortmess+=A
set tabline=%!TermTabLabel() guitablabel=%{MyTabLabel(v:lnum)} guitabtooltip=%{GuiTabToolTip()}
set termguicolors lazyredraw guioptions=gt guicursor+=n-v-c:blinkon0 mouse=a
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
set updatetime=500

" Command bar
set ignorecase smartcase infercase
set incsearch hlsearch gdefault
set laststatus=2 showcmd ruler noshowmode
set wildmenu completeopt=longest,menuone,preview
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" Text options
set autoindent smartindent linebreak breakindent formatoptions=cjnr
set backspace=indent,eol,start
set expandtab smarttab tabstop=4 softtabstop=4 shiftwidth=4
set foldmethod=syntax foldenable foldlevelstart=10
set listchars=tab:»\ ,space:·,trail:-,precedes:…,extends:…
set number cursorline nowrap conceallevel=2

" }}}

" Keybindings and Commands {{{
" Sort via :sort /.*\%18v/

 noremap          "             '
 noremap          '             "
 noremap          +             -
 noremap          -             _
     map          /             <Plug>(incsearch-forward)
 noremap          :             ;
 noremap          ;             :
 noremap <silent> <a-o>         <c-i>
 noremap <silent> <a-p>         :History<cr>
 noremap <silent> <c-a>         <esc>ggVG
 noremap <silent> <c-b>         :Buffers<cr>
"noremap          <c-e>         {TAKEN: Open file explorer}
 noremap <silent> <c-f>         :Lines<cr>
 noremap <silent> <c-h>         <c-w>h
 noremap <silent> <c-j>         <c-w>j
 noremap <silent> <c-k>         <c-w>k
 noremap <silent> <c-l>         <c-w>l
 noremap <silent> <c-p>         :Files<cr>
 noremap <silent> <c-t>         :tabnew<cr>
 noremap          <down>        }
 noremap <silent> <expr> j      v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
 noremap <silent> <expr> k      v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
 noremap          <leader>-     :execute 'edit '.expand('%:p:h')<cr>
 noremap <silent> <leader>/     :nohlsearch<cr>
 noremap <silent> <leader>O     :NERDTreeToggle<cr>
 noremap <silent> <leader>[     :setlocal wrap!<cr>:setlocal wrap?<cr>
 noremap <silent> <leader>]     :setlocal number!<cr>:setlocal number?<cr>
 noremap <silent> <leader>cd    :execute 'cd '.expand('%:p:h')<cr>:echo ':cd '.getcwd()<cr>
 noremap <silent> <leader>c,    :cd ..<cr>:echo ':cd '.getcwd()<cr>
 noremap <silent> <leader>d     <c-x>
 noremap <silent> <leader>f     <c-a>
"noremap          <leader>j     {TAKEN: Json tool}
 noremap <silent> <leader>l     :setlocal list!<cr>:setlocal list?<cr>
 noremap <silent> <leader>o     :execute 'NERDTreeToggle '.expand('%:p:h')<cr>
 noremap <silent> <leader>ro    :set winheight=1 winwidth=1<cr>
 noremap          <leader>s     :%s/\<<c-r><c-w>\>/
 noremap <silent> <leader>u     :UndotreeToggle<cr>:UndotreeFocus<cr>
 noremap <silent> <leader>va    :call OpenSplit(g:vimrc_custom, 50, 0)<cr>
 noremap <silent> <leader>vp    :call OpenSplit(g:vimrc.'.plugins.custom', 50, 0)<cr>
 noremap <silent> <leader>vr    :call OpenSplit(g:vimrc, 100, 0)<cr>
 noremap <silent> <leader>vz    :execute 'source '.g:vimrc<cr>
 noremap          <left>        g0
 noremap          <right>       g$
 noremap <silent> <s-tab>       gT
 noremap <silent> <tab>         gt
 noremap          <up>          {
     map          ?             <Plug>(incsearch-backward)
 noremap <silent> K             :Help <c-r><c-w><cr>
     map          Q             <c-q>
 noremap          Y             y$
 noremap          _             +
     map          g/            <Plug>(incsearch-stay)
 noremap <silent> gO            m'O<esc>cc<esc><c-o>
 noremap <silent> gV            `[v`]
 noremap <silent> go            m'o<esc>cc<esc><c-o>
 noremap <silent> gs            :Scratch<cr>
 noremap <silent> gw            :silent !explorer <cWORD><cr>
 noremap          s             <nop>
 noremap          ss            s

inoremap          <c-,>         <c-d>
inoremap          <c-.>         <c-t>
inoremap          <c-backspace> <c-w>
inoremap          <tab>         <c-r>=TabOrComplete()<cr>
inoremap          kj            <esc>
inoremap <silent> <c-a>         <esc>ggVG
inoremap <silent> <c-space>     <tab>

if has('python') | noremap <leader>j :%!python -m json.tool<cr>| endif
if (exists('g:mapleader')) | execute 'noremap \ '.g:mapleader | endif

command! -nargs=0                        Light   set background=light
command! -nargs=0                        Dark    set background=dark
command! -nargs=0                        Scratch call OpenScratch()
command! -nargs=1 -complete=help         Help    call OpenHelp(<f-args>)
command! -nargs=1 -complete=help         THelp   tab help <args>
command! -nargs=+ -complete=file_in_path Grep    silent grep! <args> | copen
command! -nargs=+ -complete=file_in_path LGrep   silent lgrep! <args> | lopen

call s:GenerateCAbbrev('grep',  2, 'Grep' )
call s:GenerateCAbbrev('help',  1, 'Help' )
call s:GenerateCAbbrev('lgrep', 2, 'LGrep')
call s:GenerateCAbbrev('rg',    2, 'Grep' )
call s:GenerateCAbbrev('thelp', 2, 'THelp')

" }}}

" Statusline {{{ {{{

let g:modemap={
            \ 'n'  : 'Normal', 'no' : 'OpPnd',
            \ 'v'  : 'Visual', 'V'  : 'VLine',
            \ '^V' : 'VBlock', 's'  : 'Select',
            \ 'S'  : 'SelLin', '^S' : 'SBlock',
            \ 'i'  : 'Insert', 'R'  : 'Rplace',
            \ 'Rv' : 'VRplc',  'c'  : 'Cmd',
            \ 'cv' : 'VmEx',   'ce' : 'Ex',
            \ 'r'  : 'Prmt',   'rm' : 'More',
            \ 'r?' : 'Cnfrm',  '!'  : 'Shell',
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
    return toupper(get(g:modemap, mode(), 'VBlk'))
endfunction

function! SL_FilePath(len) abort
    let dirs = split(expand('%:p:h'), g:slash)
    let path = ''
    for dir in dirs
        let path .= (strpart(dir, 1, 1) == ':') ? dir.g:slash : strpart(dir, 0, 1).g:slash
    endfor
    return strpart(path, 0, len(path)-1)
endfunction

function! SL_FileType() abort
    return expand('%:e') == &filetype ? '' : &filetype
endfunction

function! SL_GitBranch() abort
    try | let source = fugitive#statusline() | catch | return '' | endtry
    if !source | return '' | endif
    let parts = split(matchstr(source, '(\zs.*\ze)'), '/')
    let branch = ''
    for part in parts | let branch .= strpart(part, 0, 1).'/' | endfor
    return strpart(branch, 0, len(branch)-2).parts[len(parts)-1]
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
        return '0B '
    endif
    return exists('mbytes') ? l:mbytes.'MB ' : exists('kbytes') ? l:kbytes.'KB ' : l:bytes.'B '
endfunction

" }}} }}}

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
augroup Backups
    autocmd BufRead * let &l:backupdir = s:backupdir.g:slash.expand("%:p:h:t") |
                \ silent call s:TryCreateDir(&l:backupdir)
augroup END
silent call s:TryCreateDir(s:backupdir)
if has('persistent_undo') && s:TryCreateDir(g:temp.g:slash.'undo')
    set undofile
    let &undodir = expand(g:temp.g:slash.'undo')
endif

" }}} }}}

" Plugins {{{ {{{

" Load plugins

" Update packpath
let s:packpath = fnamemodify(g:vimrc, ':p:h')
if match(&packpath, substitute(s:packpath, '[\\/]', '[\\\\/]', 'g')) == -1
    let &packpath .= ','.s:packpath
endif

" Legacy plugins
if !has('nvim')
    packadd! matchit
endif

call plug#begin(g:vimplug)

" Colorschemes
Plug 'cesardeazevedo/Fx-ColorScheme'
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'iCyMind/NeoSolarized'
Plug 'jonathanfilip/vim-lucius'
Plug 'nightsense/forgotten'
Plug 'nightsense/vimspectr'
Plug 'nlknguyen/papercolor-theme'
Plug 'rakr/vim-one'
Plug 'reedes/vim-colors-pencil'
Plug 'tyrannicaltoucan/vim-deep-space'
Plug 'zcodes/vim-colors-basic'

" UI plugins
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'kshenoy/vim-signature'
Plug 'mbbill/undotree'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'w0rp/ale'
Plug 'wesrupert/vim-hoverhl'

if has('python3')
    Plug 'shougo/deoplete.nvim', { 'do': ':silent UpdateRemotePlugins' }
    Plug 'mhartington/deoplete-typescript'
    Plug 'robzz/deoplete-omnisharp'
    Plug 'shougo/context_filetype.vim'
    Plug 'shougo/echodoc.vim'
    Plug 'shougo/neco-vim'
    Plug 'shougo/neoinclude.vim'
    Plug 'shougo/neopairs.vim'
    Plug 'shougo/neosnippet-snippets'
    Plug 'shougo/neosnippet.vim'
else
    Plug 'ervandew/supertab'
endif

" Command plugins
Plug 'machakann/vim-sandwich'
Plug 'scrooloose/nerdcommenter'

" Filetype plugins
Plug 'elzr/vim-json'
Plug 'leafgarland/typescript-vim'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'oranget/vim-csharp'
Plug 'plasticboy/vim-markdown'
Plug 'pprovost/vim-ps1'

" Architecture plugins
Plug 'tpope/vim-repeat'
Plug 'haya14busa/incsearch.vim'
Plug 'conormcd/matchindent.vim'
if has('nvim')
    Plug 'equalsraf/neovim-gui-shim'
else
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
    Plug 'tpope/vim-dispatch'
endif

call s:TrySourceFile(g:vimrc.'.plugins.custom', '', '')
call plug#end()

" Configuration
let g:NERDTreeCaseSensitiveSort = !(has('win32') && (&ignorecase || &smartcase))
let g:NERDTreeNaturalSort = 1
let g:NERDTreeShowBookmarks = 1
let g:deoplete#enable_at_startup = 1
let g:hoverhl#enabled_filetypes = [ 'cs', 'cpp', 'c', 'ps1', 'typescript', 'javascript', 'json', 'sh', 'dosbatch', 'vim' ]
let g:markdown_fenced_languages = g:hoverhl#enabled_filetypes
let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes) + [
      \   {'buns': ['{ ', ' }'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['{']},
      \   {'buns': ['[ ', ' ]'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['[']},
      \   {'buns': ['( ', ' )'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['(']},
      \   {'buns': ['{\s*', '\s*}'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['{']},
      \   {'buns': ['\[\s*', '\s*\]'], 'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['[']},
      \   {'buns': ['(\s*', '\s*)'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['(']},
      \ ]

" }}} }}}

" Auto Commands {{{ {{{
augroup RememberCursor | autocmd!
    autocmd BufReadPost * if line("'\"")>0 && line("'\"")<=line('$') | exe "normal g`\"" | endif
augroup END

augroup Filetypes | autocmd!
    autocmd BufEnter *                         if s:IsEmptyFile() | set ft=markdown | end
    autocmd BufNew,BufReadPre *.xaml,*.targets setf xml
    autocmd BufWritePre *                      silent call s:TryCreateDir(expand('<afile>:p:h'))
    autocmd FileType c,cpp,cs,h,js,ts          noremap <buffer> ip i{| noremap <buffer> ap a{| " }}
    autocmd FileType gitcommit                 call setpos('.', [0, 1, 1, 0]) | setlocal tw=72 fo+=t cc=50,+0
    autocmd FileType markdown,txt              setlocal wrap nonumber norelativenumber nocursorline
augroup END

augroup HelpFiles | autocmd!
    autocmd BufWinEnter * if (&buftype == 'help') |
                    \     setlocal winwidth=80 sidescrolloff=0 |
                    \     vertical resize 80 |
                    \     noremap <buffer> q <c-w>c |
                    \ endif
    autocmd BufWinEnter * if (&buftype == 'quickfix' || &previewwindow) | noremap <buffer> q <c-w>c | endif
augroup END

augroup Spelling | autocmd!
    autocmd ColorScheme * hi clear SpellRare | hi clear SpellLocal
    autocmd BufRead * if &l:modifiable == 0 | setlocal nospell | endif
augroup END

augroup AutoChDir | autocmd!
    autocmd BufEnter * silent! lcd %:p:h
augroup END

highlight link MixedWhitespace Underlined
highlight link BadBraces NONE
augroup MixedWhitespace | autocmd!
    autocmd InsertEnter * highlight! link BadBraces Error
    autocmd InsertLeave * highlight! link BadBraces NONE
    autocmd BufEnter * match MixedWhitespace /\s*\(\( \t\)\|\(\t \)\)\s*/
    autocmd BufEnter *.c,*.cpp,*.cs,*.js,*.ps1,*.ts 2match BadBraces /[^}]\s*\n\s*\n\s*\zs{\ze\|\s*\n\s*\n\s*\zs}\ze\|\zs}\ze\s*\n\s*\(else\>\|catch\>\|finally\>\|while\>\|}\|\s\|\n\)\@!\|\zs{\ze\s*\n\s*\n/
augroup END

" }}} }}}

" Diff Settings (NOTE: must be last group, as it clears some augroups!) {{{ {{{
augroup DiffLayout | autocmd!
    autocmd VimEnter * if &diff | call s:SetDiffLayout() | endif
augroup END

function! s:SetDiffLayout()
    if has('autocmd')
        augroup RememberCursor | autocmd! | augroup END " Clear cursor jump command
    endif
    execute 'vertical resize '.((&columns * get(g:, 'diff_width', 50)) / 100)
    wincmd l | call setpos('.', [0, 1, 1, 0])

    let g:ale_enabled = 0
    set nohidden bufhidden=delete guioptions+=lr
    noremap q :qa<cr>
endfunction
" }}} }}}

" Load help docs {{{ {{{
" Credit goes to Tim Pope (https://tpo.pe/) for these functions.

function! s:Helptags() abort " Invoke :helptags on all non-$VIM doc directories in runtimepath. {{{
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
        let label .= (i+1 == tabpagenr()) ? '%#TabLineSel#' : '%#TabLine#' " Select the highlighting
        let label .= '%'.(i+1).'T'                                         " Set the tab page number (for mouse clicks)
        let label .= ' %{MyTabLabel('.(i+1).')} '                          " The label is made by MyTabLabel()
        let label .= '%#TabLine#|'                                         " Add divider
    endfor
    let label .= '%#TabLineFill#%T'                                        " Fill with TabLineFill and reset tab page nr
    if tabpagenr('$') > 1 | let label .= '%=%#TabLine#%999XX' | endif      " Right-align close tab label

    return label
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
    autocmd CursorHold <buffer> silent update
    nmap <buffer> <silent> <esc> q
    normal ggGG
endfunction " }}}

function! OpenSplit(input, threshold, iscommand) " {{{
    let splitright = get(g:, 'opensplit_on_right', &splitright)
    let open = !s:IsEmptyFile() ? &columns >= a:threshold+get(g:,'opensplit_threshold',50) ? 
                \ (a:iscommand ? 'vert ' : 'vsplit ') :
                \ (a:iscommand ? 'tab '  : 'tabnew ') :
                \ (a:iscommand ? ''      : 'edit '  )
    execute l:open.a:input

    execute 'wincmd '.(l:splitright ? 'L' : 'H')
    execute 'vertical resize '.a:threshold
    noremap <buffer> <silent> q :update<cr><bar><c-w>c
    if l:open =~# 'v\(ert\|split\)'
        let &l:textwidth = a:threshold
        setlocal nonumber norelativenumber
    endif
endfunction " }}}

function! SynStack() "{{{
    let list = ''
    if exists('*synstack')
        let list = join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), ',')
    endif
    return '['.l:list.']'
endfunction "}}}

function! TabOrComplete() "{{{
    return col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w' ? "\<c-n>" : "\<tab>"
endfunction "}}}

" }}} }}}

call s:TrySourceFile(g:vimrc.'.custom', g:vimrc.'.after', 'g:vimrc_custom')

" vim: foldmethod=marker foldlevel=1

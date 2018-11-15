" Script functions {{{ {{{

function! Mkdir(path) " {{{
    let l:path = expand(a:path)
    if !filereadable(l:path) && filewritable(l:path) != 1
        try
            call mkdir(l:path, 'p')
            return 1
        catch /E739/ | endtry
    endif
    return 0
endfunction " }}}

function! s:GenerateCAbbrev(orig, complStart, new) " {{{
    let len = len(a:orig) | if a:complStart > len | let a:complStart = len | endif
    while len >= a:complStart
        let s = strpart(a:orig, 0, len) | let len = len - 1
        execute "cabbrev ".s." <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? '".a:new."' : '".s."')<CR>"
    endwhile
endfunction " }}}

function! s:IsEmptyFile() " {{{
    return !(@%!='' || filereadable(@%)!=0 || line('$')!=1 || col('$')!=1)
endfunction " }}}

function! s:TrySourceFile(path, backup) " {{{
    let l:path = filereadable(a:path) ? a:path : filereadable(a:backup) ? a:backup : ''
    if l:path != '' | silent execute 'source '.l:path | endif
    return escape(l:path, '\')
endfunction " }}}

" }}} }}}

let g:vimhome = expand(has('win32') ? '$HOME/vimfiles' : '~/.vim')
let g:vimrc = expand(g:vimhome.'/vimrc')
let g:vimplug = expand(g:vimhome.'/plug')

let g:mapleader = ','
let g:vimrc_leader = s:TrySourceFile(g:vimrc.'.leader', g:vimrc.'.before')

let g:slash = has('win32') ? '\' : '/'
let g:temp = expand(((filewritable($TMP) == 2)     ? expand($TMP) :
            \        (filewritable($TEMP) == 2)    ? expand($TEMP) :
            \        (filewritable($TMPDIR) == 2)  ? expand($TMPDIR) :
            \        (filewritable('C:\TMP') == 2) ? 'C:\TMP\' :
            \        (filewritable('/tmp') == 2)   ? '/tmp/' : g:vimhome.g:slash).'/vimtemp/')
let g:temp = substitute(g:temp, '[\\/]\+', g:slash, 'g')
call Mkdir(g:temp)

" Preferences and Settings {{{

" Application settings
syntax on
filetype plugin indent on
set shortmess+=A hidden switchbuf=usetab splitbelow splitright
set noerrorbells belloff=all visualbell t_vb=
set scrolloff=3 sidescroll=1
set tabline=%!TermTabLabel() guitablabel=%{MyTabLabel(v:lnum)} guitabtooltip=%{GuiTabToolTip()}
set termguicolors lazyredraw guioptions=!egkt
set updatetime=500
set mouse=a

" Command bar
set ignorecase smartcase infercase incsearch hlsearch gdefault
set laststatus=2 showcmd ruler noshowmode
set wildmenu completeopt=longest,menuone,preview
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" Text options
set autoindent smartindent linebreak breakindent formatoptions=cjnr
set backspace=indent,eol,start
set expandtab smarttab tabstop=4 softtabstop=4 shiftwidth=4
set number cursorline nowrap conceallevel=2 foldmethod=syntax
if !has('nvim')
    set listchars=tab:»\ ,space:·,trail:-,precedes:>,extends:<
endif
if has('gui_running')
    set guifont=Hack:h9,Source_Code_Pro:h11,Consolas:h10
    set guicursor+=n-v-c:blinkwait500-blinkon500-blinkoff500
endif

" Platform-specific settings
if has('win32')
    source $VIMRUNTIME/mswin.vim
    set selectmode=
endif

" }}}

" Plugins {{{

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
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'fenetikm/falcon'
Plug 'iCyMind/NeoSolarized'
Plug 'nightsense/forgotten'
Plug 'nightsense/vimspectr'
Plug 'nlknguyen/papercolor-theme'
Plug 'rakr/vim-one'
Plug 'reedes/vim-colors-pencil'
Plug 'zcodes/vim-colors-basic'

" Command plugins
Plug 'ervandew/supertab'
Plug 'machakann/vim-sandwich'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-fugitive'

" Filetype plugins
Plug 'elzr/vim-json'
Plug 'leafgarland/typescript-vim'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'oranget/vim-csharp'
Plug 'plasticboy/vim-markdown'
Plug 'pprovost/vim-ps1'
Plug 'udalov/kotlin-vim'

" Architecture plugins
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'conormcd/matchindent.vim'
Plug 'haya14busa/incsearch.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-repeat'
Plug 'wesrupert/vim-hoverhl'

if has('nvim')
    Plug 'equalsraf/neovim-gui-shim'
else
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
    Plug 'tpope/vim-dispatch'
endif

call s:TrySourceFile(g:vimrc.'.plugins.custom', '')
call plug#end()

" Configuration
let g:gitgutter_sign_added              = has('nvim') ? 'â€¢' : '*'
let g:gitgutter_sign_modified           = g:gitgutter_sign_added
let g:gitgutter_sign_removed            = g:gitgutter_sign_added
let g:gitgutter_sign_removed_first_line = g:gitgutter_sign_added
let g:gitgutter_sign_modified_removed   = g:gitgutter_sign_added

augroup Fzf | autocmd!
    autocmd FileType fzf set laststatus=0 noshowmode noruler |
                \ autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup END

let g:incsearch#auto_nohlsearch = 1
let g:hoverhl#enabled_filetypes = [ 'cs', 'cpp', 'c', 'ps1', 'typescript', 'javascript', 'json', 'sh', 'dosbatch', 'vim' ]
let g:markdown_fenced_languages = g:hoverhl#enabled_filetypes

let g:rooter_silent_chdir = 1
augroup RooterPost | autocmd!
    autocmd User RooterChDir try | cd src | catch | endtry
augroup END

let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes) + [
      \   {'buns': ['{ ', ' }'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['{']},
      \   {'buns': ['[ ', ' ]'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['[']},
      \   {'buns': ['( ', ' )'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['(']},
      \   {'buns': ['{\s*', '\s*}'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['{']},
      \   {'buns': ['\[\s*', '\s*\]'], 'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['[']},
      \   {'buns': ['(\s*', '\s*)'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['(']},
      \ ]

call s:TrySourceFile(g:vimrc.'.plugins.settings.custom', '')

function! s:Helptags() abort " Invoke :helptags on all non-$VIM doc directories in runtimepath. {{{
    " Credit goes to Tim Pope (https://tpo.pe/) for this function.
    for glob in map(split(&rtp,'\\\@<!\%(\\\\\)*\zs,'),'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
        for dir in map(split(glob(glob), "\n"), 'v:val.g:slash."doc".g:slash')
            if (dir)[0 : strlen($VIMRUNTIME)] !=# $VIMRUNTIME.g:slash &&
                        \ filewritable(dir) == 2 && !empty(split(glob(dir.'*.txt'))) &&
                        \ (!filereadable(dir.'tags') || filewritable(dir.'tags'))
                silent! execute 'helptags' fnameescape(dir)
            endif
        endfor
    endfor
endfunction " }}}
call s:Helptags()

" }}}

" Keybindings and Commands {{{
" Sort via :sort /.*\%18v/

 noremap          +             -
 noremap          -             _
     map          /             <Plug>(incsearch-forward)
 noremap          :             ;
 noremap          ;             :
 noremap <silent> <c-a>         <c-c>ggVG
 noremap <silent> <c-b>         :Buffers<cr>
 noremap <silent> <c-e>         :execute 'silent !'.(has('win32')?'explorer':'open').' '.shellescape(expand('%:p:h'))<cr>
 noremap <silent> <c-f>         :Lines<cr>
 noremap <silent> <c-h>         <c-w>h
 noremap <silent> <c-j>         <c-w>j
 noremap <silent> <c-k>         <c-w>k
 noremap <silent> <c-l>         <c-w>l
 noremap <silent> <c-n>         :Files<cr>
 noremap <silent> <c-p>         :History<cr>
 noremap <silent> <c-t>         :tabnew<cr>
 noremap          <c-v>         "+gP
 noremap <silent> <expr> j      v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
 noremap <silent> <expr> k      v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
 noremap          <leader>-     :execute 'edit '.expand('%:p:h')<cr>
 noremap <silent> <leader>/     :nohlsearch<cr>
 noremap <silent> <leader>[     :setlocal wrap!<cr>:setlocal wrap?<cr>
 noremap <silent> <leader>c,    :cd ..<cr>:echo ':cd '.getcwd()<cr>
 noremap <silent> <leader>cd    :execute 'cd '.expand('%:p:h')<cr>:echo ':cd '.getcwd()<cr>
 noremap <silent> <leader>d     <c-x>
 noremap <silent> <leader>f     <c-a>
 noremap <silent> <leader>l     :setlocal list!<cr>:setlocal list?<cr>
 noremap <silent> <leader>o     :execute 'NERDTreeToggle '.expand('%:p:h')<cr>
 noremap <silent> <leader>ro    :set winheight=1 winwidth=1<cr>
 noremap          <leader>s     :%s/\<<c-r><c-w>\>/
 noremap <silent> <leader>va    :call OpenAuxFile(g:vimrc_custom, 50, 0)<cr>
 noremap <silent> <leader>vp    :call OpenAuxFile(g:vimrc.'.plugins.custom', 50, 0)<cr>
 noremap <silent> <leader>vr    :call OpenAuxFile(g:vimrc, 100, 0)<cr>
 noremap <silent> <leader>vz    :execute 'source '.g:vimrc<cr>
 noremap <silent> <s-tab>       gT
 noremap <silent> <tab>         gt
     map          ?             <Plug>(incsearch-backward)
 noremap          Q             <c-q>
 noremap          Y             y$
 noremap          _             +
     map          g/            <Plug>(incsearch-stay)
 noremap <silent> gV            `[v`]
 noremap <silent> gs            :Scratch<cr>
 noremap <silent> gw            :silent !explorer <cWORD><cr>
 noremap          s             <nop>
 noremap          ss            s

inoremap          <c-backspace> <c-w>
inoremap <silent> <c-a>         <esc>ggVG
inoremap kj                     <esc>

if (exists('g:mapleader')) | execute 'noremap \ '.g:mapleader | endif

command! -nargs=0                        Scratch call OpenScratch()
command! -nargs=1 -complete=help         Help    call OpenHelp(<f-args>)
command! -nargs=1 -complete=help         THelp   tab help <args>
command! -nargs=+ -complete=file_in_path Grep    silent grep! <args> | copen
command! -nargs=+ -complete=file_in_path LGrep   silent lgrep! <args> | lopen

call s:GenerateCAbbrev('grep',  2, 'Grep' )
call s:GenerateCAbbrev('rg',    2, 'Grep' )
call s:GenerateCAbbrev('help',  1, 'Help' )
call s:GenerateCAbbrev('lgrep', 2, 'LGrep')
call s:GenerateCAbbrev('thelp', 2, 'THelp')

" }}}

" Statusline {{{ {{{

function! s:StatusLine()
    set statusline=%#StatusLine#\ %{SL_ModeCurrent()}\ %#StatusLineNC# " Abbreviated current mode
    set statusline+=%#PMenu#\ %{SL_FilePath(20)}\ %t\ %#StatusLineNC#  " File full path with truncation + Filename
    set statusline+=%(\ \[%{SL_FileType()}\]%)%(\ [%R%M]%)%w%q         " Filetype if it doesn't match extension + Buffer flags
    set statusline+=%=                                                 " Move to right side
    set statusline+=%{&fileencoding?&fileencoding:&encoding}           " Buffer encoding
    set statusline+=\[%{&fileformat}\]\ %#PMenu#\ #%n\ %#StatusLine#   " Buffer format + Buffer number
    set statusline+=\ %p%%\ [%l/%L\ %c]\                               " Cursor location
endfunction
call s:StatusLine()

let g:modemap={ 'n'  : 'Normal', 'no' : 'OpPend', 'v'  : 'Visual', 'V'  : 'VsLine',
              \ '^V' : 'VBlock', 's'  : 'Select', 'S'  : 'SelLin', '^S' : 'SBlock',
              \ 'i'  : 'Insert', 'R'  : 'Rplace', 'Rv' : 'VReplc', 'c'  : 'Commnd',
              \ 'cv' : 'Vim Ex', 'ce' : 'ExMode', 'r'  : 'Prompt', 'rm' : '  More',
              \ 'r?' : 'Confrm', '!'  : ' Shell', 't'  : '  Term'}

function! SL_ModeCurrent() abort
    return toupper(get(g:modemap, mode(), 'VBlk'))
endfunction

function! SL_FilePath(len) abort
    let path = '' | let dirs = split(expand('%:p:h'), g:slash)
    for dir in dirs | let path .= (strpart(dir, 1, 1) == ':') ? dir.g:slash : strpart(dir, 0, 1).g:slash | endfor
    return strpart(path, 0, len(path)-1)
endfunction

function! SL_FileType() abort
    return expand('%:e') == &filetype ? '' : &filetype
endfunction

" }}} }}}

" Backup and Undo {{{ {{{

set backup writebackup
let s:backupdir = expand(g:temp.'backups')
silent call Mkdir(s:backupdir)
let &directory = s:backupdir.g:slash.g:slash
augroup Backups | autocmd!
    autocmd BufRead * let &l:backupdir = s:backupdir.g:slash.expand("%:p:h:t") | silent call Mkdir(&l:backupdir)
augroup END

if has('persistent_undo') && Mkdir(g:temp.'undo')
    set undofile
    let &undodir = expand(g:temp.'undo')
endif

" }}} }}}

" Auto Commands {{{ {{{

augroup RememberCursor | autocmd!
    autocmd BufReadPost * if line("'\"")>0 && line("'\"")<=line('$') | exe "normal g`\"" | endif
augroup END

augroup MkdirOnWrite | autocmd!
    autocmd BufWritePre * silent call Mkdir('<afile>:p:h')
augroup END

augroup Filetypes | autocmd!
    autocmd BufNew,BufReadPre *.xaml,*.targets,*.props  setf xml
    autocmd FileType  c,cpp,cs,h,js,ts  noremap <buffer> ip i{| noremap <buffer> ap a{| " }}
    autocmd FileType  gitcommit  call setpos('.', [0, 1, 1, 0]) | setlocal tw=72 fo+=t cc=50,+0
    autocmd FileType  markdown,txt  setlocal wrap nonumber norelativenumber nocursorline
    autocmd FileType  vim  noremap <buffer> K :Help <c-r><c-w><cr>
augroup END

augroup QuickExit | autocmd!
    autocmd BufWinEnter * if (&buftype =~ 'help\|quickfix' || &previewwindow) | noremap <buffer> q <c-w>c | endif
augroup END

augroup Spelling | autocmd!
    autocmd ColorScheme * hi clear SpellRare | hi clear SpellLocal
    autocmd BufRead * if &l:modifiable == 0 | setlocal nospell | endif
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

" Diff Settings {{{ {{{

augroup DiffLayout | autocmd!
    autocmd VimEnter * if &diff | call s:SetDiffLayout() | endif
augroup END

function! s:SetDiffLayout()
    augroup RememberCursor | autocmd! | augroup END " Clear cursor jump command
    execute 'vertical resize '.((&columns * get(g:, 'diff_width', 50)) / 100)
    wincmd l | call setpos('.', [0, 1, 1, 0])
    set nohidden bufhidden=delete guioptions+=lr
    noremap q :qa<cr>
endfunction

" }}} }}}

" Functions {{{ {{{

" Tabs {{{

function! TermTabLabel() " {{{
    let label = ''
    for i in range(tabpagenr('$'))
        let label .= (i+1 == tabpagenr()) ? '%#TabLineSel#' : '%#TabLine#' " Select the highlighting
        let label .= '%'.(i+1).'T %{MyTabLabel('.(i+1).')} %#TabLine#|'    " The label is made by MyTabLabel()
    endfor
    let label .= '%#TabLineFill#%T'                                        " Fill with TabLineFill and reset tab page nr
    return label
endfunction " }}}

function! MyTabLabel(lnum) " {{{
    let bufnrlist = tabpagebuflist(a:lnum)
    let bufnr = tabpagewinnr(a:lnum) - 1
    let name = bufname(bufnrlist[bufnr])
    let modified = getbufvar(bufnrlist[bufnr], '&modified')
    let readonly = getbufvar(bufnrlist[bufnr], '&readonly') || !getbufvar(bufnrlist[bufnr], '&modifiable')

    if name != '' && name !~ 'NERD_tree'
        let name = fnamemodify(name, ':t')
    else
        let bufnr = len(bufnrlist)
        while (name == '' || name =~ 'NERD_tree') && bufnr >= 0
            let bufnr -= 1
            let name = bufname(bufnrlist[bufnr])
            let modified = getbufvar(bufnrlist[bufnr], '&modified')
        endwhile
        let name = name=='' ? &buftype=='quickfix' ? '[Quickfix]' : '[No Name]' : fnamemodify(name, ':t')
    endif
    if name == '.scratch.md' | let name = '[Scratch]' | endif
    if getbufvar(bufnrlist[bufnr], '&buftype') == 'help'
        let modified = 0 | let readonly = 0
        let name = 'H['.fnamemodify(name, ':r').']'
    endif
    let label = a:lnum.' '.name

    let uncounted = 0
    for bufnr in bufnrlist
        let tmpname = bufname(bufnr)
        if tmpname == '' || tmpname =~ 'NERD_tree' || getbufvar(bufnr, '&buftype') == 'help'
            if bufnr != bufnrlist[tabpagewinnr(a:lnum) - 1]
                let uncounted += 1
            endif
        endif
    endfor
    let wincount = tabpagewinnr(a:lnum, '$') - uncounted
    if wincount > 1
        let label .= ' (..'.wincount
        for bufnr in bufnrlist
            if (modified == 0 && getbufvar(bufnr, '&modified'))
                let label .= ' [+]'
                break
            endif
        endfor
        let label .= ')'
    endif
    let label .= modified ? readonly ? '[+/-]' : '[+]' : readonly ? '[-]' : ''

    return label
endfunction " }}}

function! GuiTabToolTip() " {{{
    let tooltip = ''
    let bufnrlist = tabpagebuflist(v:lnum)
    for bufnr in bufnrlist
        let name=bufname(bufnr)
        if (name =~ 'NERD_tree') | continue | endif
        if tooltip!='' | let tooltip .= "\n" | endif
        if name == ''
            let name = getbufvar(bufnr,'&buftype')=='quickfix' ? '[Quickfix List]' : '[No Name]'
        elseif getbufvar(bufnr,'&buftype')=='help'
            let name = 'help: '.fnamemodify(name, ':p:t:r')
        else
            let name = fnamemodify(name, ':p:t')
        endif
        let tooltip .= name

        " add modified/modifiable flags
        let modified = 0 | let readonly = 0
        if getbufvar(bufnr, '&modified') | let modified = 1 | endif
        if getbufvar(bufnr, '&modifiable') == 0 || getbufvar(bufnr, '&readonly') == 1 | let readonly = 1 | endif
        let tooltip .= modified ? readonly ? ' [+/-]' : ' [+]' : readonly ? ' [-]' : ''
    endfor
    return tooltip
endfunction " }}}

" }}}

function! OpenHelp(topic) " {{{
    try
        call OpenAuxFile('help '.a:topic, 80, 1)
    catch
        echohl ErrorMsg | echo 'Help:'.split(v:exception, ':')[-1] | echohl None
    endtry
endfunction " }}}

function! OpenScratch() " {{{
    call OpenAuxFile(expand('$HOME'.g:slash.'.scratch.md'), 50, 0)
    autocmd CursorHold <buffer> silent update
    noremap <buffer> <silent> q :update<cr><bar><c-w>c
    nmap <buffer> <silent> <esc> q
    nnoremap Q q
    normal ggGG
endfunction " }}}

function! OpenAuxFile(input, threshold, iscommand) " {{{
    let canopensplit = &columns >= a:threshold + get(g:, 'opensplit_threshold', 50)
    let open = !s:IsEmptyFile() ? canopensplit ? 
                \ (a:iscommand ? 'vert ' : 'vsplit ') :
                \ (a:iscommand ? 'tab '  : 'tabnew ') :
                \ (a:iscommand ? ''      : 'edit '  )

    if canopensplit && exists('t:opensplit_current_buffer')
        execute 'bdelete! '.t:opensplit_current_buffer
        execute l:open.a:input
        let t:opensplit_current_buffer = bufnr('%')
    else
        execute l:open.a:input
    endif

    execute 'wincmd '.(get(g:, 'openaux_splitright', !&splitright) ? 'L' : 'H')
    execute 'vertical resize '.a:threshold
    if l:open =~# 'v\(ert\|split\)'
        let &l:textwidth = a:threshold
        setlocal nonumber norelativenumber
    endif
endfunction " }}}

function! SynStack() "{{{
    return exists('*synstack') ? '['.join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), ',').']' : ''
endfunction "}}}

function! TabOrComplete() "{{{
    return col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w' ? "\<c-n>" : "\<tab>"
endfunction "}}}

" }}} }}}

let g:vimrc_custom = s:TrySourceFile(g:vimrc.'.custom', g:vimrc.'.after')

" vim: foldmethod=marker foldlevel=1

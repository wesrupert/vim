set nocompatible

" Load vimrc.before {{{
if filereadable($MYVIMRC.'.before')
    source $MYVIMRC.before
endif
" }}}

" Load pathogen {{{
filetype off
" Don't load pathogen more than once if the default paths were overriden
" in vimrc.before.
if !exists("g:plugins_loaded")
    let g:plugins_loaded = 1
    execute pathogen#infect('plugins/{}', 'colorschemes/{}', 'custom/{}')
    execute pathogen#helptags()
endif
" }}}

" Functions {{{
function! GuiTabLabel() " {{{
    " Tab number
    let label = '['.v:lnum.'] '

    " Buffer name
    let bufnrlist = tabpagebuflist(v:lnum)
    let bufnr = tabpagewinnr(v:lnum) - 1
    let name = bufname(bufnrlist[bufnr])
    let modified = getbufvar(bufnrlist[bufnr], '&modified')
    if (name != '' && name !~ 'NERD_tree')
        " Get the name of the first real buffer
        let name = fnamemodify(name, ':t')
    else
        let bufnr = len(bufnrlist)
        while ((name == '' || name =~ 'NERD_tree') && bufnr >= 0)
            let bufnr -= 1
            let name = bufname(bufnrlist[bufnr])
            let modified = getbufvar(bufnrlist[bufnr], '&modified')
        endwhile
        if (name == '')
            let name = '[No Name]'
            if (&buftype == 'quickfix')
                let name = '[Quickfix List]'
                let modified = 0
            endif
        else
            " Get the name of the first real buffer
            let name = fnamemodify(name, ':t')
        endif
    endif
    if (getbufvar(bufnrlist[bufnr], '&buftype') == 'help')
        let name = 'help: '.fnamemodify(name, ':r')
        let modified = 0
    endif
    let label .= name

    " The number of windows in the tab page
    let uncounted = 0
    for bufnr in bufnrlist
        let tmpname = bufname(bufnr)
        if tmpname == '' || tmpname =~ 'NERD_tree' || getbufvar(bufnr, '&buftype') == 'help'
            let uncounted += 1
        endif
    endfor
    let wincount = tabpagewinnr(v:lnum, '$') - uncounted
    if (wincount > 1)
        let label .= '... ('.wincount

        " Add '[+]' if one of the buffers in the tab page is modified
        for bufnr in bufnrlist
            if (modified == 0 && getbufvar(bufnr, '&modified'))
                let label .= ' [+]'
                break
            endif
        endfor

        let label .= ')'
    endif

    " Add '[+]' if one of the buffers in the tab page is modified
    if (modified == 1)
        let label .= ' [+]'
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
        if getbufvar(bufnr, "&modified")
            let tooltip .= ' [+]'
        endif
        if getbufvar(bufnr, "&modifiable")==0
            let tooltip .= ' [-]'
        endif
    endfor
    return tooltip
endfunction " }}}

function! IsEmptyFile() " {{{
    if @% == ""
        " No filename for current buffer
        return 1
    elseif filereadable(@%) == 0
        " File doesn't exist yet
        return 1
    elseif line('$') == 1 && col('$') == 1
        " File is empty
        return 1
    endif
    return 0
endfunction " }}}

function! SetHoverHlColor() " {{{
    if !exists('s:interestingWordsGUIColors')
        let s:interestingWordsGUIColors = g:interestingWordsGUIColors
        if has("autocmd")
            au ColorScheme * call SetHoverHlColor()
        endif
    endif
    let hlcolor = printf("%s", synIDattr(hlID('Search'), 'bg#'))
    if (hlcolor != '')
        let g:interestingWordsGUIColors = [ hlcolor ] + s:interestingWordsGUIColors
        if exists('*ClearWordColorCache')
            call ClearWordColorCache()
        endif
    endif
endfunction " }}}

function! TabOrComplete() " {{{
    if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
        return "\<C-N>"
    else
        return "\<Tab>"
    endif
endfunction " }}}

function! ToggleIdeMode() " {{{
    execute 'NERDTreeTabsToggle'
    if (g:idemode == 0)
        set guioptions+=mr
        let g:idemode = 1
    else
        set guioptions-=mr
        let g:idemode = 0
    endif
endfunction " }}}

function! TryCreateDir(path) " {{{
    if !filereadable(a:path) && filewritable(a:path) != 2
        call mkdir(a:path)
    endif
endfunction " }}}
" }}}

" Preferences and Settings {{{
syntax on
filetype plugin indent on
set mouse=a
set encoding=utf-8
set formatoptions=

" Visual aesthetics
set noerrorbells visualbell t_vb=
set number norelativenumber
set laststatus=2 showcmd ruler noshowmode
set scrolloff=3 sidescrolloff=15 sidescroll=1
set wildmenu
set lazyredraw
let g:idemode = 0

" Search
set updatetime=500
set incsearch hlsearch
set ignorecase smartcase

" Whitespace and comments
set tabstop=4 softtabstop=4 shiftwidth=4
set expandtab smarttab
set autoindent smartindent
set formatoptions+=jr

" Word wrap
set backspace=indent,eol,start
set nowrap
set linebreak
set formatoptions+=cn

" File organization
set autoread
set shortmess+=A
set hidden
set switchbuf=usetab
set noautochdir
set foldmethod=syntax foldenable foldlevelstart=10
set modeline modelines=1
" }}}

" Keybindings and Commands {{{
nnoremap <silent> <c-a>      <esc>ggVG
inoremap <silent> <c-a>      <esc>ggVG
    "map <silent> <c-e>      {TAKEN: Open file explorer}
nnoremap <silent> <c-h>      <c-w>h
nnoremap <silent> <c-j>      <c-w>j
nnoremap <silent> <c-k>      <c-w>k
nnoremap <silent> <c-l>      <c-w>l
    "map <silent> <c-p>      {TAKEN: Fuzzy file search}
nnoremap          <c-q>      Q
nnoremap <silent> <c-t>      :tabnew<cr>:Startify<cr>
    "map <silent> <c-tab>    {TAKEN: Switch tab}
    "map <silent> <c-f11>    {TAKEN: Fullscreen}
    "map <silent> <leader>\  {TAKEN: Easymotion}
nnoremap <silent> <leader>'  :if &go=~#'r'<bar>set go-=r<bar>else<bar>set go+=r<bar>endif<cr>
nnoremap <silent> <leader>[  :setlocal wrap!<cr>:setlocal wrap?<cr>
nnoremap <silent> <leader>/  :nohlsearch<cr>:let g:hoverhl=1<cr>
nnoremap <silent> <leader>?  :nohlsearch<cr>:call UncolorAllWords()<cr>:let g:hoverhl=0<cr>
nnoremap <silent> <leader>b  :call ToggleIdeMode()<cr>
    "map <silent> <leader>c  {TAKEN: NERDCommenter}
    "map <silent> <leader>f  {TAKEN: Findstr}
nnoremap <silent> <leader>g  :GitGutterToggle<cr>
    "map <silent> <leader>h  {TAKEN: GitGutter previews}
nnoremap <silent> <leader>i  :set foldmethod=indent<cr>
    nmap <silent> <leader>k  <plug>InterestingWords
    vmap <silent> <leader>k  <plug>InterestingWords
    nmap <silent> <leader>K  <plug>InterestingWordsClear
    "map <silent> <leader>K  {TAKEN: Clear all important words}
    "map <silent> <leader>m  {TAKEN: Toggle GUI menu}
    nmap <silent> <leader>n  <plug>InterestingWordsForeward
    nmap <silent> <leader>N  <plug>InterestingWordsBackward
nnoremap <silent> <leader>rs :set columns=60 lines=20<cr>
nnoremap <silent> <leader>rm :set columns=120 lines=40<cr>
nnoremap <silent> <leader>rl :set columns=180 lines=60<cr>
nnoremap <silent> <leader>s  :Startify<cr>
nnoremap          <leader>t  <plug>TaskList
nnoremap <silent> <leader>v  :source $MYVIMRC<cr>
nnoremap <silent> <leader>w  :execute "resize ".line("$")<cr>
nnoremap <silent> <leader>z  :tabnew<bar>args $MYVIMRC*<bar>all<bar>wincmd J<bar>wincmd t<cr>
nnoremap <silent> cd         :execute 'cd '.expand("%:p:h")<cr>
nnoremap <silent> gV         `[v`]
nnoremap <silent> j          gj
inoremap          jk         <esc>
nnoremap <silent> k          gk
nnoremap <silent> K          :tab h <c-r><c-w><cr>
inoremap          kj         <esc>
nnoremap          ZT         :tabclose<cr>
nnoremap          Q          :q
nnoremap          Y          y$
inoremap <silent> <tab>      <c-r>=TabOrComplete()<cr>
nnoremap          <tab>      %
nnoremap          <space>    za
nnoremap <silent> [[         ^
nnoremap <silent> ]]         $
    "map <silent> (          {TAKEN: Prev code line}
    "map <silent> )          {TAKEN: Next code line}

cabbrev h    <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'h')<CR>
cabbrev he   <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab he' : 'he')<CR>
cabbrev hel  <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab hel' : 'hel')<CR>
cabbrev help <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab help' : 'help')<CR>
" }}}

" Platform-Specific Settings {{{
let g:slash = pathogen#slash()
if has("win32")
    if filewritable($TMP) == 2
        let g:temp = expand($TMP).'\Vim'
    elseif filewritable($TEMP) == 2
        let g:temp = expand($TEMP).'\Vim'
    elseif filewritable('C:\TMP') == 2
        let g:temp = 'C:\TMP\Vim'
    else
        let g:temp = 'C:\TEMP\Vim'
    endif
    call TryCreateDir(g:temp)

    source $VIMRUNTIME/mswin.vim
    behave mswin

    map <silent> <c-e> :silent !explorer .<cr>
    map <silent> <leader>f :Findstring
    nnoremap <silent> <leader>f :Findstring<cr>
else
    if filewritable($TMPDIR) == 2
        let g:temp = expand($TMPDIR).'/vim'
    elseif filewritable('/tmp') == 2
        let g:temp = '/tmp/vim'
    else
        let g:temp = expand('$HOME').'/.vim/temp'
    endif
    call TryCreateDir(g:temp)

    map  <silent> <c-e> :silent !open .<cr>

    if has("mac")
        noremap <silent> <c-t> :tabnew<cr>:Startify<cr>
    endif
endif
" }}}

" Backup and Undo {{{
set backup writebackup
let s:backupdir = expand(g:temp.g:slash.'backups')
let &directory = s:backupdir.g:slash.g:slash
if has("autocmd")
    augroup Backups
        au BufRead * let &l:backupdir = s:backupdir.g:slash.expand("%:p:h:t") |
                    \ call TryCreateDir(&l:backupdir)
    augroup END
endif
call TryCreateDir(s:backupdir)
if has("persistent_undo")
    call TryCreateDir(g:temp.g:slash.'undo')
    set undofile
    let &undodir = expand(g:temp.g:slash.'undo')
endif
" }}}

" Plugin Settings {{{
" Airline plugin configuration
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_inactive_collapse=1
let g:airline#extensions#branch#format = 2
let g:airline#extensions#whitespace#enabled=1
let g:airline#extensions#whitespace#trailing_format = 't[%s]'
let g:airline#extensions#whitespace#mixed_indent_format = 'm[%s]'
let g:airline#extensions#whitespace#long_format = 'l[%s]'
let g:airline#extensions#whitespace#mixed_indent_file_format = 'mf[%s]'


" Colorscheme switcher plugin configuration
let g:colorscheme_switcher_define_mappings = 0
let g:colorscheme_switcher_keep_background = 1
let g:colorscheme_switcher_exclude = [ 'default' ]

" Ctrlp plugin configuration
let g:ctrlp_clear_cache_on_exit = 0
" Disable ctrlp checking for source control, it
" makes it unusable on large repositories
let g:ctrlp_working_path_mode = 'a'

" Findstr plugin configuration
let Findstr_Default_Options = "/sinp"
let Findstr_Default_FileList = $SEARCHROOT

" InterestingWords plugin configuration
if has("autocmd")
    let g:hoverhl=0
    augroup HoverHighlight
        au BufEnter * call SetHoverHlColor()
        au CursorHold * if (g:hoverhl == 1) |
                    \     call UncolorAllWords() |
                    \     call InterestingWords('n') |
                    \ endif
    augroup END
endif

" NERDTree plugin configuration
let NERDTreeShowHidden = 1

" NERDTreeTabs plugin configuration
let g:nerdtree_tabs_open_on_gui_startup = 0
let g:nerdtree_tabs_smart_startup_focus = 2

" Pencil colorscheme configuration
let g:pencil_gutter_color = 1

" Startify plugin configuration
let g:startify_custom_header = [ '   Vim - Vi IMproved' ]
let g:startify_session_persistence = 1
let g:startify_files_number = 8
let g:startify_change_to_dir = 1
let g:startify_enable_unsafe = 1
let g:startify_bookmarks = [{'gc': $HOME.g:slash.'.gitconfig'}]
if filereadable($MYVIMRC.'.after')
    let g:startify_bookmarks = [{'va': $MYVIMRC.'.after'}] + g:startify_bookmarks
endif
let g:startify_bookmarks = [{'vr': $MYVIMRC}] + g:startify_bookmarks
if filereadable($MYVIMRC.'.before')
    let g:startify_bookmarks = [{'vb': $MYVIMRC.'.before'}] + g:startify_bookmarks
endif
if has('gui_running')
    let &lines = 17 + len(g:startify_custom_header) + (2 * g:startify_files_number) + len(g:startify_bookmarks) + 3
endif
" }}}

" GUI Settings {{{
if has("gui_running")
    " GVim window style.
    set guitablabel=%{GuiTabLabel()}
    set guitabtooltip=%{GuiTabToolTip()}
    set guioptions=aegt
    set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
    set selectmode=
    set cursorline
    colorscheme github

    " Custom keybindings
    map  <silent> <leader>m :if &go=~#'m'<bar>set go-=m<bar>else<bar>set go+=m<bar>endif<cr>
endif
" }}}

" Diff Settings {{{
if &diff
    set diffopt=filler,context:3
    if has("autocmd")
        augroup DiffResize
            au GUIEnter * simalt ~x
            au VimEnter * call SetDiffLayout()
        augroup END
    elseif has("gui_running")
        set lines=50
        set columns=200
    endif
endif

function! SetDiffLayout()
    set guifont=consolas
    colorscheme github
    execute 'vertical resize '.((&columns*75)/100)
    call setpos('.', [0, 1, 1, 0])
    set guioptions-=m
    set guioptions+=lr
    noremap q :qa<cr>
endfu
" }}}

" Auto Commands {{{
if has("autocmd")
    augroup Startup
        au GUIEnter * set visualbell t_vb=

        " Jump to line cursor was on when last closed, if available
        au BufReadPost * if line("'\'") > 0 && line("'\'") <= line("$") |
                    \    exe "normal g`\"" |
                    \ endif
    augroup END

    augroup AutoChDir
        au BufEnter * silent! lcd %:p:h
        au BufEnter * if IsEmptyFile() | set ft=markdown | end
    augroup END

    augroup Filetypes
        au FileType cs setlocal foldmethod=indent
        au FileType c,cpp,cs,js,ts let g:hoverhl = 1 |
                    \ noremap <buffer> <silent> ( 0?;<cr>0^:noh<cr>|
                    \ noremap <buffer> <silent> ) $/;<cr>0^:noh<cr>
        au FileType gitcommit call setpos('.', [0, 1, 1, 0])
    augroup END

    augroup HelpShortcuts
        au BufEnter *.txt if (&buftype == 'help') | noremap q <c-w>c | endif
    augroup END

    highlight ExtraWhitespace guifg=red
    augroup ExtraWhitespace
        au InsertEnter * highlight! link ExtraWhitespace Error
        au InsertLeave * highlight! link ExtraWhitespace NONE
        au BufEnter * match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\zs \+\ze/
    augroup END

    augroup WinHeight
        au VimResized * let &winheight = (&lines * 70) / 100
    augroup END
endif
" }}}

" Load vimrc.after {{{
if filereadable($MYVIMRC.'.after')
    source $MYVIMRC.after
endif
" }}}

" vim: foldmethod=marker foldlevel=0

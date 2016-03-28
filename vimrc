" Load plugins
    filetype off
    execute pathogen#infect('plugins/{}', 'colorschemes/{}', 'custom/{}')
    execute pathogen#helptags()

" Top-level settings
    set nocompatible
    syntax on
    set mouse=a
    filetype plugin indent on
    set noerrorbells visualbell t_vb=

" Custom keybindings
    inoremap          jk        <esc>
    inoremap          kj        <esc>
    inoremap <silent> <tab>     <c-r>=Tab_Or_Complete()<cr>
    inoremap <silent> <c-a>     <esc>ggVG
    noremap  <silent> <c-a>     <esc>ggVG
   "noremap  <silent> <c-e>     {TAKEN: Open file explorer}
    noremap  <silent> <c-h>     <c-w>h
    noremap  <silent> <c-j>     <c-w>j
    noremap  <silent> <c-k>     <c-w>k
    noremap  <silent> <c-l>     <c-w>l
   "noremap  <silent> <c-p>     {TAKEN: Fuzzy file search}
    noremap           <c-q>     Q
    noremap  <silent> <c-t>     :tabnew<cr>:Startify<cr>
    noremap  <silent> <c-w>     :tabclose<cr>
   "noremap  <silent> <c-tab>   {TAKEN: Switch tab}
   "noremap  <silent> <c-f11>   {TAKEN: Fullscreen}
   "noremap  <silent> <leader>\ {TAKEN: Easymotion}
    noremap  <silent> <leader>' :call ToggleScrollbar()<cr>
    noremap  <silent> <leader>[ :setlocal wrap!<cr>:setlocal wrap?<cr>
    noremap  <silent> <leader>] :noh<cr>
    noremap  <silent> <leader>b :NERDTreeTabsToggle<cr>
   "noremap  <silent> <leader>c {TAKEN: NERDCommenter}
   "noremap  <silent> <leader>f {TAKEN: Findstr}
   "noremap  <silent> <leader>h {TAKEN: GitGutter previews}
    noremap  <silent> <leader>i :set foldmethod=indent<cr>
   "noremap  <silent> <leader>m {TAKEN: Toggle GUI menu}
    noremap  <silent> <leader>M :NextColorScheme<cr>
    noremap  <silent> <leader>n :setlocal relativenumber!<cr>
    noremap  <silent> <leader>N :setlocal number!<cr>
    noremap  <silent> <leader>r :source $MYVIMRC<cr>
    noremap  <silent> <leader>s :Startify<cr>
    noremap  <silent> <leader>t <plug>TaskList
    noremap  <silent> <leader>v "*p
    noremap  <silent> <leader>y "*y
    noremap  <silent> <leader>z :tabnew $MYVIMRC.custom<cr>
    noremap  <silent> <leader>Z :tabnew $MYVIMRC<cr>
    noremap  <silent> j         gj
    noremap  <silent> k         gk
    noremap           Q         :q
    noremap  <silent> [[        ^
    noremap  <silent> ]]        $

" Custom commands
    cabbrev h    <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'h')<CR>
    cabbrev he   <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'he')<CR>
    cabbrev hel  <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'hel')<CR>
    cabbrev help <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'help')<CR>

" Visual aesthetics
    set nowrap
    set number
    set showcmd
    set ruler
    set equalalways

" Whitespace settings
    set tabstop=4
    set shiftwidth=4
    set expandtab
    set autoindent

" Search settings
    set incsearch
    set ignorecase
    set smartcase
    set hlsearch

" Wrap settings
    set backspace=indent,eol,start
    set lbr

" File organization
    set foldmethod=syntax
    set foldenable
    set foldlevelstart=10

" Keep your directories free of clutter
    set nobackup writebackup
    if has("persistent_undo")
        if has("win32")
            call system('mkdir '.$TEMP.'\Vim')
            call system('mkdir '.$TEMP.'\Vim\undo')
            let &undodir = expand($TEMP.'/Vim/undo')
        else
            call system('mkdir '.'/.vim/undo')
            let &undodir = expand($HOME.'/.vim/undo')
        endif
        set undofile
    endif

" Platform-specific settings
if has("win32")
    let s:slash = '\'
    source $VIMRUNTIME/mswin.vim
    behave mswin
    set formatoptions=lrocj

    map <silent> <c-e> :silent !explorer .<cr>
    map <silent> <leader>f :Findstring
    nnoremap <silent> <leader>f :Findstring<cr>
else
    let s:slash = '/'
    set formatoptions=lroc
    map  <silent> <c-e> :silent !open .<cr>
endif

" Plugin settings
    " Airline plugin configuration
    set encoding=utf-8
    set laststatus=2
    set noshowmode
    let g:airline_left_sep=''
    let g:airline_right_sep=''
    let g:airline_inactive_collapse=1
    let g:airline#extensions#whitespace#enabled=1

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

    " NERDTreeTabs plugin configuration
    let g:nerdtree_tabs_open_on_gui_startup = 0

    " Pencil colorscheme configuration
    let g:pencil_gutter_color = 1

    " Startify plugin configuration
    let g:startify_custom_header = [ '   Vim - Vi IMproved' ]
    let g:startify_session_persistence = 1
    let g:startify_files_number = 8
    let g:startify_change_to_dir = 1
    let g:startify_enable_unsafe = 1
    let g:startify_bookmarks = [
        \ {'vc': $MYVIMRC.'.custom'},
        \ {'vr': $MYVIMRC},
        \ {'gc': $HOME.s:slash.'.gitconfig'}
    \ ]

" GUI configuration
    if has("gui_running")
        " GVim window style.
        set guitablabel=%t
        set guioptions=agt
        set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
        set selectmode=
        colorscheme github

        " Custom keybindings
        map  <silent> <leader>m :if &go=~#'m'<bar>set go-=m<bar>else<bar>set go+=m<bar>endif<cr>
    endif

" Diff configuration
if &diff
    set diffopt=filler,context:3
    if has("autocmd")
        augroup DiffResize
            au GUIEnter * simalt ~x
            au VimEnter * vertical resize -80
            au VimEnter * execute 2 . "wincmd w"
        augroup END
    elseif has("gui_running")
        set lines=50
        set columns=200
    endif
elseif has("gui_running")
    set lines=40
    set columns=120
endif

" Autocommands
if has("autocmd")
    augroup Startup
        au GUIEnter * set visualbell t_vb=
        au VimEnter * set autochdir
        au BufEnter * if @% == '__startify__' | execute 'Startify' | endif

        " Jump to line cursor was on when last closed, if available
        au BufReadPost *
            \ if line("'\'") > 0 && line("'\'") <= line("$") |
            \  exe "normal g`\"" |
            \ endif
    augroup END

    augroup Filetypes
        au FileType cs set foldmethod=indent
    augroup END

    augroup HelpShortcuts
        au BufEnter *.txt if (&buftype == 'help') | noremap q <c-w>c | endif
    augroup END

    if v:version >= 704
        " Toggle relative numbers when typing, if enabled
        augroup RelativeNumber
            au InsertEnter * let g:relativenumber = &relativenumber | setlocal norelativenumber
            au InsertLeave * if (g:relativenumber) | setlocal relativenumber | endif
        augroup END
    endif

    " Highlight trailing whitespace
    highlight ExtraWhitespace guifg=red
    augroup ExtraWhitespace
        au InsertEnter * highlight! link ExtraWhitespace Error
        au InsertLeave * highlight! link ExtraWhitespace NONE
        au BufEnter * match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\zs \+\ze/
        au BufLeave * if (v:version >= 702) | call clearmatches() | endif
    augroup END
endif

" Load local customizations and overrides
if filereadable($MYVIMRC.'.custom')
    source $MYVIMRC.custom
endif

" Functions
    function! Tab_Or_Complete()
        if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
            return "\<C-N>"
        else
            return "\<Tab>"
        endif
    endfunction

    let s:scrollbar = 0
    function! ToggleScrollbar()
        if s:scrollbar
            set guioptions-=r
            let s:scrollbar = 0
        else
            set guioptions+=r
            let s:scrollbar = 1
        endif
    endfunction

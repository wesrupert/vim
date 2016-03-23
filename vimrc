" Load plugins
    filetype off
    execute pathogen#infect('bundle/{}', 'colorschemes/{}')
    execute pathogen#helptags()

" Top-level settings
    set nocompatible
    syntax on
    set mouse=a

" Custom keybindings
    imap          jk        <esc>
    imap          kj        <esc>
    imap <silent> <tab>     <c-r>=Tab_Or_Complete()<cr>
    imap <silent> <c-a>     <esc>ggVG
    map  <silent> <c-a>     <esc>ggVG
   "map  <silent> <c-e>     {TAKEN: Open file explorer}
    map  <silent> <c-h>     <c-w>h
    map  <silent> <c-j>     <c-w>j
    map  <silent> <c-k>     <c-w>k
    map  <silent> <c-l>     <c-w>l
   "map  <silent> <c-p>     {TAKEN: Fuzzy file search}
    map  <silent> <c-t>     :tabnew<cr>:Startify<cr>
    map  <silent> <c-x>     :tabclose<cr>
   "map  <silent> <c-tab>   {TAKEN: Switch tab}
   "map  <silent> <c-f11>   {TAKEN: Fullscreen}
   "map  <silent> <leader>\ {TAKEN: Easymotion}
    map  <silent> <leader>' :call ToggleScrollbar()<cr>
    map  <silent> <leader>[ :setlocal wrap!<cr>:setlocal wrap?<cr>
    map  <silent> <leader>] :noh<cr>
    map  <silent> <leader>b :NERDTreeTabsToggle<cr>
   "map  <silent> <leader>c {TAKEN: NERDCommenter}
   "map  <silent> <leader>f {TAKEN: Findstr}
   "map  <silent> <leader>h {TAKEN: GitGutter previews}
    map  <silent> <leader>i :set foldmethod=indent<cr>
   "map  <silent> <leader>m {TAKEN: Toggle GUI menu}
    map  <silent> <leader>M :NextColorScheme<cr>
    map  <silent> <leader>n :setlocal relativenumber!<cr>
    map  <silent> <leader>N :setlocal number!<cr>
    map  <silent> <leader>r :set columns=80 lines=20<cr>
    map  <silent> <leader>s :Startify<cr>
    map  <silent> <leader>t <plug>TaskList
    map  <silent> <leader>v "*p
    map  <silent> <leader>y "*y
    map  <silent> <leader>z :tabnew $MYVIMRC<cr>
    map  <silent> j         gj
    map  <silent> k         gk

" Custom commands
    cabbrev h    <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'h')<CR>
    cabbrev he   <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'he')<CR>
    cabbrev hel  <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'hel')<CR>
    cabbrev help <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'help')<CR>

" Tabs should be 4 spaces
    set tabstop=4
    set shiftwidth=4
    set expandtab
    set autoindent

" Search options
    set incsearch
    set ignorecase
    set smartcase
    set hlsearch

" Wrap settings
    set backspace=indent,eol,start
    set lbr

" File organization
    set foldmethod=syntax
    set nofoldenable

" Keep your directories free of clutter
    set nobackup
    set nowritebackup

" Visual aesthetics
    set nowrap
    set number
    set showcmd
    set ruler
    set equalalways

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
    let g:startify_custom_header = [
        \ '   Vim - Vi IMproved',
    \ ]
    let g:startify_session_persistence = 1
    let g:startify_files_number = 8
    let g:startify_change_to_dir = 1
    let g:startify_enable_unsafe = 1
    let g:startify_bookmarks = [ {'vr': $MYVIMRC}, {'gc': $HOME.s:slash.'.gitconfig'} ]

" Visual configuration
    " Automatically load background type
    if exists("$VIMBACKGROUND")
        let &background = $VIMBACKGROUND
    endif

    " GUI configuration
    if has("gui_running")
        " GVim window style.
        set guitablabel=%t
        set guioptions=agt
        set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

        " Custom keybindings
        map  <silent> <leader>m :if &go=~#'m'<bar>set go-=m<bar>else<bar>set go+=m<bar>endif<cr>

        set selectmode=

        " Automatically load font
        if exists("$VIMFONT")
            let &guifont = $VIMFONT
        endif

        " Automatically load colorscheme
        if exists("$VIMCOLORSCHEME")
            " The 'lucius' color scheme has a ton of variants defined by
            " commands. Intercept these variants and assign them properly.
            if ($VIMCOLORSCHEME =~? 'lucius')
                colorscheme lucius
                execute $VIMCOLORSCHEME
            else
                colorscheme $VIMCOLORSCHEME
            endif
        else
            " Default GUI colorscheme
            colorscheme github
        endif
    else
        " Automatically load colorscheme
        if exists("$VIMTERMCOLORS")
            " The 'lucius' color scheme has a ton of variants defined by
            " commands. Intercept these variants and assign them properly.
            if ($VIMTERMCOLORS =~? 'lucius')
                colorscheme lucius
                execute $VIMTERMCOLORS
            else
                colorscheme $VIMTERMCOLORS
            endif
        else
            " Default term colorscheme
            colorscheme default
        endif
    endif

" Diff configuration
if &diff
    set diffopt=filler,context:3
    if has("autocmd")
        augroup DiffResize
            autocmd GUIEnter * simalt ~x
            autocmd VimEnter * vertical resize -80
            autocmd VimEnter * execute 2 . "wincmd w"
        augroup end
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
    filetype plugin indent on

    " Silence the editor
    set noerrorbells visualbell t_vb=
    augroup Startup
        autocmd GUIEnter * set visualbell t_vb=

    autocmd VimEnter * set autochdir
    autocmd BufEnter * if @% == '__startify__' | execute 'Startify' | endif

    " Jump to line cursor was on when last closed, if available
    autocmd BufReadPost *
        \ if line("'\'") > 0 && line("'\'") <= line("$") |
        \  exe "normal g`\"" |
        \ endif
    augroup end

    if v:version >= 704
        " Toggle relative numbers when typing, if enabled
        augroup RelativeNumber
            autocmd InsertEnter * let g:relativenumber = &relativenumber | setlocal norelativenumber
            autocmd InsertLeave * if (g:relativenumber) | setlocal relativenumber | endif
        augroup end
    endif

    " Highlight trailing whitespace
    highlight ExtraWhitespace guifg=red
    augroup ExtraWhitespace
        autocmd InsertEnter * highlight! link ExtraWhitespace Error
        autocmd InsertLeave * highlight! link ExtraWhitespace NONE
        autocmd BufEnter * match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\zs \+\ze/
    augroup end
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

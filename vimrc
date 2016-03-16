" Load plugins
    execute pathogen#infect()
    Helptags

" Colorscheme
if has("gui_running")
    if exists("$VIMCOLORSCHEME")
        colorscheme $VIMCOLORSCHEME
    else
        colorscheme solarized
    endif
    if exists("$VIMBACKGROUND")
        let &background = $VIMBACKGROUND
    endif
else
    colorscheme default
endif

" Font
if has("gui_running")
    if exists("$VIMFONT")
        let &guifont = $VIMFONT
    else
        set guifont = Source_Code_Pro_Medium:h10
    endif
endif

" Top-level settings
    set nocompatible
    syntax on

" Custom keybindings
    imap           jk       <esc>
    imap           kj       <esc>
    imap <silent> <Tab>     <c-r>=Tab_Or_Complete()<cr>
    imap <silent> <c-a>     <esc>ggVG
    map  <silent> <c-a>     <esc>ggVG
   "map  <silent> <c-e>     {TAKEN}
    map  <silent> <c-t>     :tabnew<cr>
    map  <silent> <c-x>     :tabclose<cr>
    map  <silent> <leader>' :call ToggleScrollbar()<cr>
    map  <silent> <leader>[ :setlocal wrap!<cr>:setlocal wrap?<cr>
    map  <silent> <leader>] :noh<cr>
    map  <silent> <leader>b :NERDTreeToggle<cr>
   "map  <silent> <leader>f {TAKEN}
    map  <silent> <leader>i :set foldmethod=indent<cr>
   "map  <silent> <leader>m {TAKEN}
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
    map  <silent> <c-j>     <c-w>j
    map  <silent> <c-k>     <c-w>k
    map  <silent> <c-l>     <c-w>l
    map  <silent> <c-h>     <c-w>h
    map           zq        ZQ

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
    set number relativenumber
    set showcmd
    set ruler
    set equalalways

" Platform-specific settings
if has("win32")
    source $VIMRUNTIME/mswin.vim
    behave mswin
    set formatoptions=lrocj

    map  <silent> <c-e> :silent !explorer .<cr>
    map  <silent> <leader>f :Findstring 
    nnoremap <silent> <leader>f :Findstring<cr>

    "Plugin settings
    let Findstr_Default_Options = "/sinp"
    let Findstr_Default_FileList = $SEARCHROOT
else
    set formatoptions=lroc
    map  <silent> <c-e> :silent !open .<cr>
endif

" Plugin settings
    set encoding=utf-8
    set laststatus=2
    set noshowmode

    " Disable ctrlp checking for source control - makes it unusable on large
    " repositories
    let g:ctrlp_working_path_mode = 'a'
    let g:ctrlp_clear_cache_on_exit = 0

    " Startify customization for windows
    let g:startify_bookmarks = [ $MYVIMRC, $HOMEDRIVE.$HOMEPATH."\\.gitconfig" ]
    let g:startify_session_persistence = 1
    let g:startify_files_number = 4
    let g:startify_change_to_dir = 1

    " Airline plugin configuration
    let g:airline_left_sep=''
    let g:airline_right_sep=''
    let g:airline_inactive_collapse=1
    let g:airline#extensions#whitespace#enabled=0

    " Colorscheme switcher configuration
    let g:colorscheme_switcher_define_mappings = 0
    let g:colorscheme_switcher_keep_background = 1
    let g:colorscheme_switcher_exclude = [ 'default' ]

" GUI configuration
if has("gui_running")
	" GVim window style.
    set guitablabel=%t
	set guioptions=agtLR
	set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

    " Custom keybindings
    map  <silent> <leader>m :if &go=~#'m'<bar>set go-=m<bar>else<bar>set go+=m<bar>endif<cr>

    " GUI mouse management.
	set mouse=a
	set selectmode=
else
    let g:airline_theme = "molokai"
endif

" Diff configuration
if &diff
    set diffopt=filler,context:3
    if has("autocmd")
        autocmd GUIEnter * simalt ~x
        autocmd VimEnter * vertical resize -80
        autocmd VimEnter * execute 2 . "wincmd w"
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

    " Stop dinging, dangit!
    set noerrorbells visualbell t_vb=
    autocmd GUIEnter * set visualbell t_vb=

    autocmd VimEnter * set autochdir
    autocmd BufEnter *
        \ if @% == '__startify__' |
        \   execute 'Startify' |
        \ endif

    " Jump to line cursor was on when last closed, if available
    autocmd BufReadPost *
        \ if line("'\'") > 0 && line("'\'") <= line("$") |
        \  exe "normal g`\"" |
        \ endif

    if v:version >= 704
        " Toggle relative numbers when typing
        autocmd InsertEnter * setlocal norelativenumber
        autocmd InsertLeave * setlocal relativenumber
    endif

    " Highlight trailing whitespace
    highlight ExtraWhitespace guifg=red guibg=red
    autocmd ColorScheme * highlight ExtraWhitespace guifg=red guibg=red
    match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\zs \+\ze/

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
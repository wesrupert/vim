" Load plugins
    runtime bundle/pathogen/autoload/pathogen.vim
    let $VIMRUNTIME = "C:/Vim/vim73"
    call pathogen#infect()
    Helptags

" Top level settings
    set nocompatible
    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim
    behave mswin
    cd \%HOMEDRIVE\%\\%HOMEPATH\%\Documents

" Choose a colorscheme
    " colorscheme jellybeans
    " colorscheme lucius
    colorscheme molokai

" Custom keybindings
    imap            jk          <esc>
    imap            kj          <esc>
    imap            <c-a>       <esc>ggVG
    map             <c-a>       <esc>ggVG
    map  <silent>   <c-e>       :silent !explorer .<cr>
    map  <silent>   <c-t>       :tabnew<cr>
    map  <silent>   <c-x>       :tabclose<cr>
    map  <silent>   <c-z>       :tabnew C:\Vim\_vimrc<cr>
    map             <leader>[   :setlocal wrap!<cr>:setlocal wrap?<cr>
    map  <silent>   <leader>]   :noh<cr>
    map  <silent>   <leader>e   :Errors<cr>
    map  <silent>   <leader>i   :set foldmethod=indent<cr>
    map  <silent>   <leader>m   :NumbersToggle<cr>
    map  <silent>   <leader>M   :setlocal number!<cr>
    map  <silent>   <leader>r   :RainbowParenthesesLoadRound<cr>
    map             <leader>t   <Plug>TaskList
    map  <silent>   <leader>u   :UndotreeToggle<cr>
    map             <leader>v   "+p
    map             <leader>y   "+y
    map  <silent>   j           gj
    map  <silent>   k           gk
    map             <c-j>       <c-w>j
    map             <c-k>       <c-w>k
    map             <c-l>       <c-w>l
    map             <c-h>       <c-w>h
    map             zq          ZQ

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
    set formatoptions=l
    set lbr

" File organization
    set autochdir
    set foldmethod=syntax

" Keep your files free of .*~ backups
    set nobackup
    set nowritebackup

" Visual aesthetics
    set autoindent
    set nowrap
    set number
    set showcmd
    set ruler

" Plugin settings
    set encoding=utf-8
    set guifont=Consolas\ for\ Powerline\ FixedD:h12
    set laststatus=2
    set noshowmode
    let g:syntastic_check_on_open=1

" GUI configuration
if has("gui")
	" GVim window style.
    set guitablabel=%t
	set guioptions=grLt
	set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
	set lines=20
	set columns=80
    let g:Powerline_symbols="fancy"

    " Spellcheck settings.
    let g:spchkdialect = "usa"
    let g:spchkacronym = 1

    " GUI mouse management.
	set mouse=a
	set selectmode=

	" Mappings for toggling fullscreen.
	map <f11> <esc>:call ToggleFullscreen()<cr>
    imap <f11> <esc>:call ToggleFullscreen()<cr>a
endif

" Autocommands
if has("autocmd")
	filetype plugin indent on

	" Stop dinging, dangit!
	set noerrorbells visualbell t_vb=
	autocmd GUIEnter * set visualbell t_vb=

    " Start NERDTree when vim is started empty.
	" autocmd vimenter * if !argc() | NERDTree | endif

    " Jump to line cursor was on on last close if available.
	autocmd BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\  exe "normal g`\"" |
		\ endif

    autocmd VimEnter * call ChangeColor()

    autocmd VimEnter * RainbowParenthesesToggle
    autocmd BufEnter * RainbowParenthesesLoadRound
    "autocmd BufEnter * RainbowParenthesesLoadSquare
    "autocmd BufEnter * RainbowParenthesesLoadBraces
endif

" Variables
    " Colors for rainbow parens
    let g:rbpt_colorpairs = [
        \ ['darkblue',    '#00ffff'],
        \ ['darkgreen',   '#00ff00'],
        \ ['darkcyan',    '#ffff00'],
        \ ['darkred',     '#ff8800'],
        \ ['red',         '#ff0000'],
        \ ['brown',       '#ff00ff'],
        \ ['gray',        '#8800ff'],
        \ ['black',       '#0000ff'],
        \ ['darkmagenta', '#0088ff'],
        \ ]
    let g:rbpt_max = 50

" Function to save size and location on fullscreen, and restore after.
function! ToggleFullscreen()
	if !exists('g:full')
		let g:full = 0 
		let g:windowlines = &lines
		let g:windowcols = &columns
		let g:winposx = getwinposx()
		let g:winposy = getwinposy()
		call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)
	else
		call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)
		unlet g:full
		let &lines = g:windowlines
		let &columns = g:windowcols
		execute "winpos ".g:winposx." ".g:winposy
	endif
endfunction

" Function to change the colorscheme based on the time of day.
function ChangeColor()
    let l:time = strftime("%H")
    if (l:time > 13)
        colorscheme molokai
    else
        colorscheme jellybeans
    endif
endfunction

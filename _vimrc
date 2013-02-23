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
    cd C:\Users\ora\Documents

" Choose a colorscheme
    colorscheme jellybeans

" Custom keybindings
    inoremap jk <esc>
    inoremap kj <esc>
    inoremap <c-a> <esc>ggVG
    noremap <c-a> <esc>ggVG
    noremap <leader>v "+p
    noremap <leader>y "+y
    noremap <leader>l :setlocal number!<CR>
    noremap <leader>[ :setlocal wrap!<CR>:setlocal wrap?<CR>
    map <leader>] :noh<CR>
    map <leader>e :Errors<CR>
    map <leader>t <Plug>TaskList
    map <leader>u :UndotreeToggle<CR>
    map <silent> j gj
    map <silent> k gk
    map <c-j> <c-w>j
    map <c-k> <c-w>k
    map <c-l> <c-w>l
    map <c-h> <c-w>h

" Allow backspacing over everything in insert mode
    set backspace=indent,eol,start

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

" Wrap on word
    set formatoptions=l
    set lbr

" File organization
    set autochdir
    set foldmethod=indent

" Keep your files free of .*~ backups
    set nobackup
    set nowritebackup

" Visual aesthetics
    set autoindent
    set nowrap
    set number
    set showcmd
    set ruler

" Powerline settings
    set encoding=utf-8
    set guifont=Consolas\ for\ Powerline\ FixedD:h9
    set laststatus=2

" GUI configuration
if has("gui")
	" GVim window style
    set guitablabel=%t
	set guioptions="gmLt"
	set lines=20
	set columns=80
    let g:Powerline_symbols="fancy"

	set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
	set mouse=a
	set selectmode=

	" Mapping for toggling fullscreen
	map <F11> <esc>:call ToggleFullscreen()<CR>
endif

" Autocommands
if has("autocmd")
	filetype plugin indent on

	" Stop dinging, dangit!
	set noerrorbells visualbell t_vb=
	autocmd GUIEnter * set visualbell t_vb=

	autocmd vimenter * if !argc() | NERDTree | endif

	autocmd BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\  exe "normal g`\"" |
		\ endif

    autocmd BufEnter * SyntasticCheck

	autocmd BufNewFile,BufEnter *.c,*.h,*.java,*.jsp set formatoptions-=t tw=79
endif

" Functions
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

" Load plugins
call pathogen#infect()

set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin
cd C:\Users\ora\SkyDrive\

inoremap jk <ESC>
inoremap kj <ESC>
inoremap <C-a> <ESC>ggVG
noremap <C-a> <ESC>ggVG
noremap <leader>] :noh<CR>
noremap <leader>p "+p
noremap <leader>y "+Y
noremap <leader>l :setlocal number!<CR>
noremap <leader>w :setlocal wrap!<CR>:setlocal wrap?<CR>
map <leader>t <Plug>TaskList
map <leader>u :UndotreeToggle<CR>
map j gj
map k gk
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
map <a-j> <c-w>J
map <a-k> <c-w>K
map <a-l> <c-w>L
map <a-h> <c-w>H

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
"set textwidth=80

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

" Status line
set laststatus=2
set statusline=%t\ %{fugitive#statusline()}%y%=%l\ \|\ %P

" Powerline settings
set encoding=utf-8
set guifont=Consolas\ for\ Powerline\ FixedD:h9

if has("gui")
	" GVim window style
    set guitablabel=%t
	colorscheme lucius
	LuciusBlackHighContrast
	set guioptions="gmLt"
	set lines=20
	set columns=80
    let g:Powerline_symbols="fancy"

	set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
	set mouse=a
	set selectmode=

	" Mapping for toggling fullscreen
	map <F11> <ESC>:call ToggleFullscreen()<CR>
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

function ToggleFullscreenOld()
	if !exists('g:full')
		let g:full = 0 
		call libcallnr("vimtweak.dll", "SetAlpha", 200)
		call libcallnr("vimtweak.dll", "EnableMaximize", 1)
		call libcallnr("vimtweak.dll", "EnableTopMost", 1)
	else
		unlet g:full
		call libcallnr("vimtweak.dll", "SetAlpha", 255)
		call libcallnr("vimtweak.dll", "EnableMaximize", 0)
		call libcallnr("vimtweak.dll", "EnableTopMost", 0)
	endif
endfunction

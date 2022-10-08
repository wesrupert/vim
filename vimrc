" Functions {{{

function! Autosave(enabled) " {{{
  augroup Autosave | au! * <buffer>
      if a:enabled
          setlocal autowrite
          autocmd InsertLeave,CursorHold <buffer> update
      endif
  augroup end
endfunction " }}}

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

function! Grep(local, ...) " {{{
    let search = get(a:000, len(a:000)-1, '')
    let @/ = search
    silent execute (a:local ? 'l' : '').'grep! '.join(a:000, ' ')
    execute (a:local ? 'l' : 'c').'open'
endfunction " }}}

function! NormFile(path) " {{{
    let expanded = expand(substitute(a:path, '[\\/]\+', g:slash, 'g'))
    return expanded
endfunction " }}}

function! NormPath(path, ...) " {{{
    let useslash = get(a:, 1, 1)
    let expanded = NormFile(a:path)
    if useslash && expanded[strlen(expanded)-1] != g:slash
        let expanded .= g:slash
    elseif !useslash && expanded[strlen(expanded)-1] == g:slash
        let expanded = strpart(expanded, 0, strlen(expanded)-1)
    endif
    return expanded
endfunction " }}}

function! Paste() " {{{
    let paste=&l:paste
    setl paste
    execute 'normal! "*gp'
    let &l:paste=paste
endfunction " }}}

function! ToggleCopyMode() " {{{
    if !exists('b:copymode_enabled')
        let b:copymode_enabled = 1
        let b:copymode_number = &l:number
        let b:copymode_relativenumber = &l:relativenumber
        let b:copymode_mouse = &l:mouse
        let b:copymode_signs = &l:signcolumn
        setlocal nonumber norelativenumber mouse= signcolumn=no
        echo '[copymode] enabled'
    else
        unlet b:copymode_enabled
        let &l:number = b:copymode_number
        let &l:relativenumber = b:copymode_relativenumber
        let &l:mouse = b:copymode_mouse
        let &l:signcolumn = b:copymode_signs
        echo '[copymode] disabled'
    endif
endfunction " }}}

function! s:GenerateCAbbrev(orig, complStart, new) " {{{
    let len = len(a:orig) | if a:complStart > len | let a:complStart = len | endif
    while len >= a:complStart
        let s = strpart(a:orig, 0, len) | let len = len - 1
        execute "cabbrev ".s." <C-R>=(getcmdtype()==':' && getcmdpos()==1 ? '".a:new."' : '".s."')<CR>"
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

" }}}

let g:mapleader    = ','
let g:slash        = has('win32') ? '\' : '/'
let g:vimhome      = NormPath('$HOME/'.(has('win32') ? 'vimfiles' : '.vim'))
let g:temp         = NormPath(g:vimhome.'/tmp')
let g:scratch      = NormFile('$HOME/.scratch.md')
let g:vimrc        = NormFile(g:vimhome.'/vimrc')
let g:vimrc_leader = s:TrySourceFile(g:vimrc.'.leader', g:vimrc.'.before')
call Mkdir(g:temp)

" Preferences and Settings {{{

" Application settings
syntax on
filetype plugin indent on
set guioptions=!egkt
set mouse=a
set scrolloff=2 sidescroll=1
set splitbelow splitright
set switchbuf=usetab
set updatetime=500
if exists('&termguicolors')
    set termguicolors
endif

" Command bar
set completeopt=menuone,preview,noinsert,noselect
set gdefault
set ignorecase infercase smartcase
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.class
set wildignore+=*.pyc,*.class,*.sln,*.Master,*.csproj,*.csproj.user,*.cache,*.dll,*.pdb,*.min.*
set wildignore+=*.tar.*,*.swp,*.bak
set wildignore+=*/.git/**/*,*/.hg/**/*,*/.svn/**/*
set wildignore+=*/build/**,*/bin/**,*/dist/**,*/node_modules/**
set wildignore+=tags
set wildignorecase
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" Text options
set breakindent smartindent
set conceallevel=2
set cursorline
set expandtab shiftwidth=4 tabstop=4 softtabstop=-1
set foldmethod=syntax
set number
let &thesaurus = NormFile(g:vimhome.'/moby-thesaurus/words.txt')

" Platform-specific settings
if has('win32')
    source $VIMRUNTIME/mswin.vim
    set selectmode=
endif

" Languages for other settings
let g:ui_languages = [ 'css', 'sass', 'scss', 'html', 'vue' ]
let g:programming_languages = g:ui_languages +
            \ [ 'c', 'cpp', 'cs', 'dosbatch', 'go', 'java',
            \ 'javascript', 'jsp', 'jsx', 'objc', 'ruby', 'sh',
            \ 'typescript', 'tsx', 'vim', 'zsh' ]

" }}}

" Plugins {{{

" From https://github.com/vscode-neovim/vscode-neovim/issues/415#issuecomment-715533865
function! LoadIf(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction


" Update packpath
if exists('&packpath')
    let s:packpath = fnamemodify(g:vimrc, ':p:h')
    if match(&packpath, substitute(s:packpath, '[\\/]', '[\\\\/]', 'g')) == -1
        let &packpath .= ','.s:packpath
    endif
endif

" Legacy plugins
if !has('nvim') && exists(':packadd')
    packadd! matchit
endif

call plug#begin(NormPath(g:vimhome.'/plug'))

" Polyfills
Plug 'equalsraf/neovim-gui-shim', LoadIf(has('nvim'))
Plug 'roxma/nvim-yarp', LoadIf(!has('nvim'))
Plug 'roxma/vim-hug-neovim-rpc', LoadIf(!has('nvim'))
Plug 'tpope/vim-dispatch', LoadIf(!has('nvim'))

" Colorschemes
Plug 'folke/lsp-colors.nvim', LoadIf(has('nvim'), { 'branch': 'main' })
Plug 'EdenEast/nightfox.nvim', LoadIf(has('nvim'), { 'branch': 'main' })
Plug 'reedes/vim-colors-pencil'

" Command plugins
Plug 'junegunn/fzf', { 'dir': NormPath('~/.fzf'), 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'machakann/vim-sandwich'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-unimpaired'
Plug 'vim-scripts/bufonly.vim'

" Text object plugins
Plug 'glts/vim-textobj-comment'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-user'
Plug 'lucapette/vim-textobj-underscore'
Plug 'sgur/vim-textobj-parameter'

" Architecture plugins
Plug 'nvim-treesitter/nvim-treesitter', LoadIf(has('nvim'), {'do': ':TSUpdate'})
Plug 'airblade/vim-rooter'
Plug 'conormcd/matchindent.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/goyo.vim'
Plug 'mbbill/undotree'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-repeat'

" Filetype plugins
Plug 'sheerun/vim-polyglot'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'aklt/plantuml-syntax'
Plug 'cakebaker/scss-syntax.vim'
Plug 'ipkiss42/xwiki.vim'
Plug 'othree/yajs.vim'
Plug 'pangloss/vim-javascript'
Plug 'posva/vim-vue'
Plug 'sheerun/html5.vim'
Plug 'tpope/vim-git'

call s:TrySourceFile(g:vimrc.'.plugins.custom', '')
call plug#end()

" Configuration

if exists("*nvim_create_buf") && exists("*nvim_open_win")
    let $FZF_DEFAULT_OPTS = '--reverse --border --height 100%'
    if has('windows')
        let $FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
    else
        let $FZF_DEFAULT_COMMAND='rg --files --hidden --follow 2>/dev/null'
    endif
    let g:fzf_layout = { 'window': 'call FloatingFZF()' }
    function! FloatingFZF()
        let buf = nvim_create_buf(v:false, v:true)
        call setbufvar(buf, '&signcolumn', 'no')

        let width = float2nr(&columns * 6 / 10)
        let height = min([max([float2nr(&lines/2), 20]), &lines-4])
        let x = float2nr((&columns - width) / 2)
        let y = (tabpagenr('$') > 1 && !exists('&guitabline')) ? 1 : 0

        let opts = { 'relative': 'editor', 'row': y, 'col': x, 'width': width, 'height': height }
        call nvim_open_win(buf, v:true, opts)
    endfunction
endif

let g:markdown_fenced_languages = g:programming_languages

let g:rooter_cd_cmd = 'lcd'
let g:rooter_silent_chdir = 1
augroup RooterPost | autocmd!
    autocmd User RooterChDir try | cd src | catch | endtry
augroup end

let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes) + [
      \   {'buns': ['{ ', ' }'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['{']},
      \   {'buns': ['[ ', ' ]'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['[']},
      \   {'buns': ['( ', ' )'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['(']},
      \   {'buns': ['{\s*', '\s*}'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['{']},
      \   {'buns': ['\[\s*', '\s*\]'], 'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['[']},
      \   {'buns': ['(\s*', '\s*)'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['(']},
      \ ]

call s:TrySourceFile(g:vimrc.'.plugins.settings.custom', '')

" }}}

" Keybindings and Commands {{{
" Sort via :sort /.*\%17v/
noremap          ;             :
noremap          :             ;

noremap <silent> <C-H>         <C-W>h
noremap <silent> <C-J>         <C-W>j
noremap <silent> <C-K>         <C-W>k
noremap <silent> <C-L>         <C-W>l
noremap <silent> <leader>/     :nohlsearch<cr>
noremap <silent> <leader>[     :setlocal wrap!<cr>:setlocal wrap?<cr>
noremap          <leader>c     :CopyMode<cr>
noremap <silent> <leader>c,    :cd ..<cr>:echo ':cd '.getcwd()<cr>
noremap <silent> <leader>cd    :execute 'cd '.expand('%:p:h')<cr>:echo ':cd '.getcwd()<cr>
noremap <silent> <leader>va    :execute 'tab drop '.g:vimrc_custom<cr>
noremap <silent> <leader>vb    :execute 'tab drop '.g:vimrc_leader<cr>
noremap <silent> <leader>vp    :execute 'tab drop '.g:vimrc.'.plugins.custom'<cr>
noremap <silent> <leader>vr    :execute 'tab drop '.g:vimrc<cr>
noremap <silent> <leader>vz    :execute 'source '.g:vimrc<cr>

noremap          Q             <C-Q>
noremap <silent> g/            :Rg<cr>
noremap <silent> gV            `[v`]
map              ga            <plug>(EasyAlign)
noremap <silent> gb            :Buffers<cr>
noremap <silent> gc            :BCommits<cr>
noremap <silent> go            :GFiles?<cr>
noremap <silent> gp            :Files<cr>
noremap <silent> gs            :execute 'tab drop '.g:scratch<cr>:Autosave<cr>
noremap <silent> gz            :Goyo<cr>
noremap <silent> z/            :History/<cr>
noremap <silent> z;            :History:<cr>
noremap <silent> zp            :History<cr>

inoremap <silent> <C-Backspace> <C-W>
inoremap <silent> <D-Backspace> <C-U>
inoremap <silent><expr> <tab>   pumvisible() ? "\<C-N>" : "\<tab>"
inoremap <silent><expr> <s-tab> pumvisible() ? "\<C-P>" : "\<s-tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-Y>" : "\<C-G>u\<cr>"

" System (Ctrl- / Cmd-) commands
noremap  <silent> \a  <C-C>ggVG
inoremap <silent> \a  <esc>ggVG
noremap  <silent> \s  :update<cr>
noremap  <silent> \t  :tabnew<cr>
noremap  <silent> <C-S> :update<cr>
noremap  <silent> <D-S> :update<cr>

let explorer = has('win32') ? 'explorer' : 'open'
execute "noremap  <silent> \\e  :execute 'silent !".explorer." '.shellescape(expand('%:p:h'))<cr>"

if has("clipboard")
    noremap  \c "+yy
    noremap  \x "+x
    noremap  \y "+y
    noremap  \v :Paste<cr>
    noremap! \v <C-O>:Paste<cr>
endif

" Sandwich mappings
runtime macros/sandwich/keymap/surround.vim

" Commands
command! -nargs=0 CopyMode call ToggleCopyMode()
command! -nargs=0 Autosave call Autosave(1)
command! -nargs=0 NoAutosave call Autosave(0)
command! -nargs=0 Paste call Paste()
command! -nargs=+ -complete=file_in_path Grep call Grep(0, <f-args>)
command! -nargs=+ -complete=file_in_path LGrep call Grep(1, <f-args>)
call s:GenerateCAbbrev('grep', 2, 'Grep' )
call s:GenerateCAbbrev('lgrep', 2, 'LGrep')
call s:GenerateCAbbrev('rg', 2, 'Grep' )

" }}}

" Auto Commands {{{

augroup RememberCursor | autocmd!
    autocmd BufReadPost * if &filetype!='gitcommit' && line("'\"")>0 && line("'\"")<=line('$') |
                \ execute "normal! g`\"" | else | call setpos('.', [0, 1, 1, 0]) | endif
augroup end

augroup MkdirOnWrite | autocmd!
    autocmd BufWritePre * silent call Mkdir('<afile>:p:h')
augroup end

augroup Filetypes | autocmd!
    autocmd BufNew,BufReadPre  *.xaml,*.targets,*.props setf xml
    autocmd BufNew,BufReadPost keymap.c syn match QmkKcAux /_\{7}\|X\{7}\|__MIS__/ | hi! link QmkKcAux LineNr
    autocmd FileType gitcommit    setlocal tw=72 fo+=t cc=50,+0
augroup end

augroup QuickExit | autocmd!
    autocmd BufWinEnter * if (&buftype =~ 'help\|quickfix' || &previewwindow) | noremap <buffer> q <C-W>c | endif
augroup end

augroup Spelling | autocmd!
    autocmd ColorScheme * hi clear SpellRare | hi clear SpellLocal
    autocmd BufRead * if &l:modifiable == 0 | setlocal nospell | endif
augroup end

augroup FiletypeMarks | autocmd!
    let g:filetype_mark_map = { 
                \ 'java':       'A',
                \ 'css':        'C',
                \ 'html':       'H',
                \ 'js':         'J',
                \ 'jsp':        'K',
                \ 'markdown':   'M',
                \ 'python':     'P',
                \ 'ruby':       'R',
                \ 'sh':         'S',
                \ 'typescript': 'T',
                \ 'vue':        'V',
                \ 'zsh':        'Z',
                \ }
    function! s:SetFtMark()
        if exists("g:filetype_mark_map['".&filetype."']")
            execute 'normal! m'.toupper(g:filetype_mark_map[&filetype])
        endif
    endfunction
    autocmd BufLeave * call s:SetFtMark()
augroup end

" }}}

" Statusline {{{

function! s:StatusLine()
    set statusline=%#StatusLine#\ %{SL_ModeCurrent()}\ %#StatusLineNC#           " Abbreviated current mode
    set statusline+=%#PMenu#\ %{SL_FilePath(20)}\ %t\ %#StatusLineNC#            " File full path with truncation + Filename
    set statusline+=%(\ \[%{SL_FileType()}\]%)%(\ [%R%M]%)%w%q                   " Filetype if it doesn't match extension + Buffer flags
    set statusline+=%=                                                           " Move to right side
    set statusline+=%#PMenu#\ %p%%\ [%l/%L\ %c]\%#StatusLine#                    " Cursor location
endfunction
call s:StatusLine()

let g:modemap={ 'n'  : 'Normal', 'no' : 'OpPend', 'v'  : 'Visual', 'V'  : 'VsLine', '^V' : 'VBlock', 's'  : 'Select', 'S'  : 'SelLin',
              \ '^S' : 'SBlock', 'i'  : 'Insert', 'R'  : 'Rplace', 'Rv' : 'VReplc', 'c'  : 'Commnd', 'cv' : 'Vim Ex', 'ce' : 'ExMode',
              \ 'r'  : 'Prompt', 'rm' : '  More', 'r?' : 'Confrm', '!'  : ' Shell', 't'  : '  Term'}

function! SL_ModeCurrent() abort
    return toupper(get(g:modemap, mode(), 'VBlock'))
endfunction

function! SL_FilePath(len) abort
    let path = '' | let dirs = split(expand('%:p:h'), g:slash)
    for dir in dirs | let path .= (strpart(dir, 1, 1) == ':') ? dir.g:slash : strpart(dir, 0, 1).g:slash | endfor
    return strpart(path, 0, len(path)-1).strpart(dirs[len(dirs)-1], 1, 50)
endfunction

function! SL_FileType() abort
    return expand('%:e') == &filetype ? 'new' : &filetype
endfunction

" }}}

" Backup and Undo {{{

set backup writebackup
let g:backupdir = get(g:, 'backupdir', NormPath(g:temp.'backups'))
let &directory = g:backupdir.g:slash " Add extra slash to avoid filename collisions
silent call Mkdir(g:backupdir)

augroup Backups | autocmd!
    autocmd BufRead * let &l:backupdir = NormPath(g:backupdir.g:slash.expand("%:p:h:t")) | silent call Mkdir(&l:backupdir)
augroup end

if has('persistent_undo') && Mkdir(g:temp.'undo')
    set undofile
    let &undodir = fnamemodify(g:backupdir, ':h:h').g:slash.'undo'
endif

let g:fzf_history_dir = fnamemodify(g:backupdir, ':h:h').g:slash.'fzf'.g:slash.'history'
silent call Mkdir(g:fzf_history_dir)

" }}}

" Diff Settings {{{
set diffopt=filler,internal,algorithm:histogram,indent-heuristic

augroup DiffLayout | autocmd!
    autocmd VimEnter * if &diff | call s:SetDiffLayout() | endif
augroup end

function! s:SetDiffLayout()
    augroup RememberCursor | autocmd! | augroup end " Clear cursor jump command
    execute 'vertical resize '.((&columns * get(g:, 'diff_width', 50)) / 100)
    wincmd l | call setpos('.', [0, 1, 1, 0])
    set equalalways nohidden bufhidden=delete guioptions+=lr
    noremap q :qa<cr>
endfunction

" }}}

if 7 < strftime("%H") && strftime("%H") < 18
    set background=light
    execute 'colorscheme  '.get(g:, 'daytheme', 'pencil')
else
    set background=dark
    execute 'colorscheme  '.get(g:, 'nighttheme', 'pencil')
endif

let g:vimrc_custom = s:TrySourceFile(g:vimrc.'.custom', g:vimrc.'.after')
" vim: foldmethod=marker

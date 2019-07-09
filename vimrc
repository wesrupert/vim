" Functions {{{

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
    if a:local
        silent execute 'lgrep! '.join(a:000, ' ')
        lopen
    else
        silent execute 'grep! '.join(a:000, ' ')
        copen
    endif
endfunction " }}}

function! NormFile(path) " {{{
    let expanded = expand(substitute(a:path, '[\\/]\+', g:slash, 'g'))
    return expanded
endfunction " }}}

function! NormPath(path) " {{{
    let expanded = NormFile(a:path)
    if expanded[len(expanded)-1] != g:slash
        let expanded .= g:slash
    endif
    return expanded
endfunction " }}}

function! ShowTodos() " {{{
    silent execute 'grep! -i'
        \ .' "\b(todo\|hack\|fixme\|xxx)\b:? "'
        \ .' '.shellescape(get(b:, 'rootDir', getcwd()))
    copen
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

function! s:CheckBackspace() abort " {{{
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
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
colorscheme default
syntax on
filetype plugin indent on
set belloff=all
set display+=lastline
set guioptions=!egkt
set guitablabel=%{MyTabLabel(v:lnum)}
set guitabtooltip=%{GuiTabToolTip()}
set hidden
set lazyredraw
set mouse=a
set noequalalways
set noerrorbells
set scrolloff=3
set shortmess+=A
set sidescroll=1
set splitbelow
set splitright
set switchbuf=usetab
set t_vb=
set tabline=%!TermTabLabel()
set updatetime=500
set visualbell
if exists('&termguicolors')
    set termguicolors
endif

" Command bar
set completeopt=menuone,preview
set gdefault
set hlsearch
set ignorecase
set incsearch
set infercase
set laststatus=2
set noshowmode
set ruler
set showcmd
set smartcase
set wildignore+=*.pyc,*.class,*.sln,*.Master,*.csproj,*.csproj.user,*.cache,*.dll,*.pdb,*.min.*
set wildignore+=*.tar.*
set wildignore+=*/.git/**/*,*/.hg/**/*,*/.svn/**/*
set wildignore+=tags
set wildignore=*.swp,*.bak
set wildignorecase
set wildmenu
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" Text options
set autoindent
set backspace=indent,eol,start
set breakindent
set concealcursor=
set conceallevel=2
set cursorline
set expandtab
set fdc=0
set foldmethod=syntax
set linebreak
set nowrap
set number
set shiftwidth=4
set smartindent
set smarttab
set softtabstop=4
set spell
set tabstop=4
let &thesaurus = NormFile(g:vimhome.'/moby-thesaurus/words.txt')
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


" Languages for other settings
let g:programming_languages = [ 'c', 'cfg', 'conf', 'cpp', 'cs', 'dosbatch', 'go', 'java',
            \ 'javascript', 'json', 'jsp', 'objc', 'ruby', 'sh', 'vim', 'vue', 'zsh', ]

" }}}

" Plugins {{{

" Load plugins

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

" Colorschemes
Plug 'aonemd/kuroi.vim'
Plug 'fenetikm/falcon'
Plug 'nightsense/vimspectr'
Plug 'reedes/vim-colors-pencil'
Plug 'jaredgorski/spacecamp'

" Command plugins
Plug 'junegunn/vim-easy-align'
Plug 'machakann/vim-sandwich'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'vim-scripts/bufonly.vim'

" Filetype plugins
Plug 'peitalin/vim-jsx-typescript'
Plug 'sheerun/vim-polyglot'

" Completion plugins
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install() } }
Plug 'honza/vim-snippets'
Plug 'alvan/vim-closetag'

" Architecture plugins
Plug 'airblade/vim-rooter'
Plug 'conormcd/matchindent.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'mbbill/undotree'
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

function! s:ShowDoc() " {{{
  if &filetype == 'vim'
    execute 'Help '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction " }}}

augroup Coc | autocmd!
    autocmd CursorHold * silent call CocActionAsync('highlight')
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

let g:gitgutter_sign_added              = has('nvim') ? '┃' : '|'
let g:gitgutter_sign_modified           = g:gitgutter_sign_added
let g:gitgutter_sign_removed            = g:gitgutter_sign_added
let g:gitgutter_sign_removed_first_line = g:gitgutter_sign_added
let g:gitgutter_sign_modified_removed   = g:gitgutter_sign_added

let g:closetag_filetypes = 'html,xhtml,phtml,vue'

call coc#add_extension('coc-calc'      )
call coc#add_extension('coc-css'       )
call coc#add_extension('coc-dictionary')
call coc#add_extension('coc-eslint'    )
call coc#add_extension('coc-git'       )
call coc#add_extension('coc-highlight' )
call coc#add_extension('coc-html'      )
call coc#add_extension('coc-java'      )
call coc#add_extension('coc-jest'      )
call coc#add_extension('coc-json'      )
call coc#add_extension('coc-lists'     )
call coc#add_extension('coc-neosnippet')
call coc#add_extension('coc-pairs'     )
call coc#add_extension('coc-prettier'  )
call coc#add_extension('coc-pyls'      )
call coc#add_extension('coc-solargraph')
call coc#add_extension('coc-tsserver'  )
call coc#add_extension('coc-vetur'     )
call coc#add_extension('coc-vimlsp'    )
call coc#add_extension('coc-yaml'      )

let g:hoverhl#match_group = 'Pmenu'
let g:hoverhl#custom_guidc = ''
let g:hoverhl#case_sensitive = 1
let g:hoverhl#enabled_filetypes = g:programming_languages

let g:markdown_fenced_languages = g:programming_languages

let g:pencil_gutter_color = 1

let g:rooter_use_lcd = 1
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
 noremap          :             ;
 noremap          ;             :
 noremap <silent> <c-a>         <c-c>ggVG
 noremap <silent> <c-b>         <c-^>
 noremap <silent> <c-e>         :execute 'silent !'.(has('win32')?'explorer ':'open ').shellescape(expand('%:p:h'))<cr>
 noremap <silent> <c-h>         <c-w>h
 noremap <silent> <c-j>         <c-w>j
 noremap <silent> <c-k>         <c-w>k
 noremap <silent> <c-l>         <c-w>l
 noremap <silent> <c-t>         :tabnew<cr>
 noremap          <c-v>         "+gP
 noremap <silent> <expr> j      v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
 noremap <silent> <expr> k      v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
 noremap          <leader>-     :execute 'edit '.expand('%:p:h')<cr>
 noremap <silent> <leader>/     :nohlsearch<cr>
 noremap          <leader>;/    :%s/\<<c-r><c-w>\>/
 noremap <silent> <leader>[     :setlocal wrap!<cr>:setlocal wrap?<cr>
 noremap <silent> <leader>c,    :cd ..<cr>:echo ':cd '.getcwd()<cr>
 noremap <silent> <leader>cd    :execute 'cd '.expand('%:p:h')<cr>:echo ':cd '.getcwd()<cr>
 noremap <silent> <leader>d     <c-x>
 noremap <silent> <leader>f     <c-a>
 noremap          <leader>r     :cfdo %s/<c-r>/// <bar> update<left><left><left><left><left><left><left><left><left><left>
 noremap          <leader>s     :%s/<c-r>//
 noremap <silent> <leader>t     :Todos<cr>
 noremap <silent> <leader>va    :call OpenSidePanel(g:vimrc_custom)<cr>
 noremap <silent> <leader>vb    :call OpenSidePanel(g:vimrc_leader)<cr>
 noremap <silent> <leader>vp    :call OpenSidePanel(g:vimrc.'.plugins.custom')<cr>
 noremap <silent> <leader>vr    :call OpenSidePanel(g:vimrc)<cr>
 noremap <silent> <leader>vz    :execute 'source '.g:vimrc<cr>
 noremap          Q             <c-q>
 noremap          Y             y$
 noremap          _             +
 noremap <silent> gV            `[v`]
 noremap <silent> gs            :call OpenSidePanel(g:scratch)<cr>

inoremap          <c-backspace> <c-w>
inoremap <silent> <c-a>         <esc>ggVG
inoremap kj                     <esc>

if exists('g:mapleader') | execute 'noremap \ '.g:mapleader | endif

" Coc mappings
nmap [c   <plug>(coc-git-prevchunk)
nmap ]c   <plug>(coc-git-nextchunk)
nmap cog  <plug>(coc-git-chunkinfo)
map  [l   <plug>(coc-diagnostic-prev)
map  ]l   <plug>(coc-diagnostic-next)
map  co=  <plug>(coc-format-selected)
map  coa  <plug>(coc-codeaction-selected)
map  coaa <plug>(coc-codeaction)
map  cod  <plug>(coc-definition)
map  cof  <plug>(coc-fix-current)
map  coh  <plug>(coc-action-doHover)
map  coi  <plug>(coc-implementation)
map  col  <plug>(coc-diagnostic-list)
map  coo  <plug>(coc-references)
map  cor  <plug>(coc-rename)
map  cot  <plug>(coc-type-definition)
nnoremap cou :CocCommand git.chunkUndo<cr>
noremap K :call <SID>ShowDoc()<cr>
inoremap <silent><expr> <tab>   pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <silent><expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
inoremap <expr> <cr> pumvisible() ? "\<c-y>" : "\<c-g>u\<cr>"

augroup Coc " Don't clear, defined above
    autocmd FileType typescript,javascript,vue,java,python,ruby
                \ map <buffer> gd <plug>(coc-definition)
augroup end

" EasyAlign mappings
map ga <plug>(EasyAlign)

" HoverHL mappings
map <silent> <leader>// <plug>(hoverhl-toggle)
map <silent> <leader>/d <plug>(hoverhl-disable)
map <silent> <leader>/e <plug>(hoverhl-enable)
map <silent> <leader>/l <plug>(hoverhl-lock)
map <silent> <leader>N  <plug>(hoverhl-backward)
map <silent> <leader>n  <plug>(hoverhl-forward)

" Fzf mappings
noremap fzz fz
noremap <silent> fz'        :Marks<cr>
noremap <silent> fz/        :History/<cr>
noremap <silent> fz;        :History:<cr>
noremap <silent> fz<space>  :History<cr>
noremap <silent> fzb        :Buffers<cr>
noremap <silent> fzc        :BCommits<cr>
noremap <silent> fzd        :Commits<cr>
noremap <silent> fzf        :Files<cr>
noremap <silent> fzh        :Helptags<cr>
noremap <silent> fzl        :Lines<cr>
noremap <silent> fzm        :Maps<cr>
noremap <silent> fzp        :GFiles?<cr>
noremap <silent> fzr        :Rg<cr>
noremap <silent> fzs        :Snippets<cr>
noremap <silent> fzt        :Tags<cr>
noremap <silent> <leader>co :Colors<cr>

" Sandwich mappings
runtime macros/sandwich/keymap/surround.vim

" Commands
command! -nargs=0 Todos call ShowTodos()
command! -nargs=0 GotoCompanionFile call GotoCompanionFile()
command! -nargs=+ OpenSidePanel     call OpenSidePanel(<f-args>)
command! -nargs=1 -complete=help         Help  call OpenHelp(<f-args>)
command! -nargs=1 -complete=help         THelp tab help <args>
command! -nargs=+ -complete=file_in_path Grep  call Grep(0, <f-args>)
command! -nargs=+ -complete=file_in_path LGrep call Grep(1, <f-args>)
call s:GenerateCAbbrev('grep',  2, 'Grep' )
call s:GenerateCAbbrev('rg',    2, 'Grep' )
call s:GenerateCAbbrev('help',  1, 'Help' )
call s:GenerateCAbbrev('lgrep', 2, 'LGrep')
call s:GenerateCAbbrev('thelp', 2, 'THelp')

" }}}

" Auto Commands {{{

augroup RememberCursor | autocmd!
    autocmd BufReadPost * if &filetype!='gitcommit' && line("'\"")>0 && line("'\"")<=line('$') |
                \     execute "normal g`\"" |
                \   else |
                \     call setpos('.', [0, 1, 1, 0]) |
                \   endif
augroup end

augroup MkdirOnWrite | autocmd!
    autocmd BufWritePre * silent call Mkdir('<afile>:p:h')
augroup end

augroup Filetypes | autocmd!
    autocmd FileType notes                             set fo-=c | call SetAutosave(1)
    autocmd BufNew,BufReadPost *                       set formatoptions=cjrqn1
    autocmd BufNew,BufReadPre *.xaml,*.targets,*.props setf xml
    autocmd FileType gitcommit                         setlocal tw=72 fo+=t cc=50,+0
    autocmd FileType markdown,txt                      setlocal wrap nonumber norelativenumber nocursorline fo-=t
    autocmd FileType crontab                           setlocal nobackup nowritebackup
augroup end

augroup QuickExit | autocmd!
    autocmd BufWinEnter * if (&buftype =~ 'help\|quickfix' || &previewwindow) | noremap <buffer> q <c-w>c | endif
augroup end

augroup Spelling | autocmd!
    autocmd ColorScheme * hi clear SpellRare | hi clear SpellLocal
    autocmd BufRead * if &l:modifiable == 0 | setlocal nospell | endif
augroup end

highlight link MixedWhitespace Underlined
highlight link BadBraces NONE
augroup MixedWhitespace | autocmd!
    autocmd InsertEnter * highlight! link BadBraces Error
    autocmd InsertLeave * highlight! link BadBraces NONE
    autocmd BufEnter * match MixedWhitespace /\s*\(\( \t\)\|\(\t \)\)\s*/
    autocmd BufEnter *.c,*.cpp,*.cs,*.js,*.ps1,*.ts 2match BadBraces /[^}]\s*\n\s*\n\s*\zs{\ze\|\s*\n\s*\n\s*\zs}\ze\|\zs}\ze\s*\n\s*\(else\>\|catch\>\|finally\>\|while\>\|}\|\s\|\n\)\@!\|\zs{\ze\s*\n\s*\n/
augroup end

augroup FiletypeMarks | autocmd!
    let g:filetype_mark_map = { 
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
    set statusline+=%{get(g:,'coc_git_status','')}%{get(b:,'coc_git_status','')} " Git status
    set statusline+=%#PMenu#\ b%n\ %#StatusLine#                                 " Buffer number
    set statusline+=\ %p%%\ [%l/%L\ %c]\                                         " Cursor location
endfunction
call s:StatusLine()

let g:modemap={ 'n'  : 'Normal', 'no' : 'OpPend', 'v'  : 'Visual', 'V'  : 'VsLine',
              \ '^V' : 'VBlock', 's'  : 'Select', 'S'  : 'SelLin', '^S' : 'SBlock',
              \ 'i'  : 'Insert', 'R'  : 'Rplace', 'Rv' : 'VReplc', 'c'  : 'Commnd',
              \ 'cv' : 'Vim Ex', 'ce' : 'ExMode', 'r'  : 'Prompt', 'rm' : '  More',
              \ 'r?' : 'Confrm', '!'  : ' Shell', 't'  : '  Term'}

function! SL_ModeCurrent() abort
    return toupper(get(g:modemap, mode(), 'VBlock'))
endfunction

function! SL_FilePath(len) abort
    let path = '' | let dirs = split(expand('%:p:h'), g:slash)
    for dir in dirs | let path .= (strpart(dir, 1, 1) == ':') ? dir.g:slash : strpart(dir, 0, 1).g:slash | endfor
    return strpart(path, 0, len(path)-1)
endfunction

function! SL_FileType() abort
    return expand('%:e') == &filetype ? '' : &filetype
endfunction

" }}}

" Backup and Undo {{{

set backup writebackup

let g:backupdir = get(g:, 'backupdir', NormPath(g:temp.'backups'))
silent call Mkdir(g:backupdir)
let &directory = g:backupdir.g:slash " Add extra slash to avoid filename collisions
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

augroup DiffLayout | autocmd!
    autocmd VimEnter * if &diff | call s:SetDiffLayout() | endif
augroup end

function! s:SetDiffLayout()
    augroup RememberCursor | autocmd! | augroup end " Clear cursor jump command
    execute 'vertical resize '.((&columns * get(g:, 'diff_width', 50)) / 100)
    wincmd l | call setpos('.', [0, 1, 1, 0])
    set nohidden bufhidden=delete guioptions+=lr
    noremap q :qa<cr>
endfunction

" }}}

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
    if name == '.scratch.md' || name =~ 'Scratch' | let name = '[Scratch]' | endif
    if name =~ '^vimrc' | let name = '['.name.']' | endif
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

function! OpenHelp(topic) " {{{
    try
        call OpenSidePanel('help '.a:topic, 1)
    catch
        echohl ErrorMsg | echo 'Help:'.split(v:exception, ':')[-1] | echohl None
    endtry
endfunction " }}}

function! OpenSidePanel(input, ...) " {{{
    let iscommand  = get(a:, 1, 0)
    let splitwidth = get(g:, 'opensplit_splitwidth', 80)
    let canopensplit = &columns >= splitwidth + get(g:, 'opensplit_mainwidth', 100)
    let splitting = !s:IsEmptyFile() && l:canopensplit

    if l:splitting && exists('t:auxfile_bufnr')
        let winnr = bufwinnr(t:auxfile_bufnr)
        if l:winnr >= 0
            execute l:winnr.'close!'
        endif
    endif

    let open = s:IsEmptyFile()   ? (l:iscommand ? ''      : 'drop '    ) :
                \ l:canopensplit ? (l:iscommand ? 'vert ' : 'vsplit '  ) :
                \ (l:iscommand   ? 'tab '  : 'tab drop ')
    let opencmd = l:open.a:input

    execute l:opencmd

    let t:auxfile_bufnr = bufnr("%")
    execute 'wincmd '.(get(g:, 'auxfile_splitright', !&splitright) ? 'L' : 'H')
    execute 'vertical resize '.l:splitwidth
    let &l:textwidth = l:splitwidth
    call SetAutosave(1)
endfunction " }}}

function! SetAutosave(enabled) " {{{
    augroup Autosave | au! * <buffer>
        if a:enabled
            autocmd InsertLeave,CursorHold <buffer> update
        endif
    augroup end
endfunction " }}}

function! SynStack() "{{{
    return exists('*synstack') ? '['.join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), ',').']' : ''
endfunction "}}}

function! TabOrComplete() "{{{
    return col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w' ? "\<c-n>" : "\<tab>"
endfunction "}}}

" }}}

let g:vimrc_custom = s:TrySourceFile(g:vimrc.'.custom', g:vimrc.'.after')

" vim: foldmethod=marker foldlevel=0

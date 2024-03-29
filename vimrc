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

if get(g:, 'vscode', 0)
  " VS Code Neovim is the most common ShaDa concurrency culprit.
  " Just use VS Code features instead.
  set shada="NONE"
endif

let g:slash        = has('win32') ? '\' : '/'
let g:vimhome      = NormPath('$HOME/.config/nvim')
let g:temp         = NormPath(g:vimhome.'/tmp')
let g:scratch      = NormFile('$HOME/.scratch.md')
let g:vimrc        = NormFile(g:vimhome.'/vimrc')
let g:vimrc_init   = NormFile(g:vimhome.'/init.lua')
let g:vimrc_plug   = NormFile(g:vimhome.'/lua/plugins/init.lua')
let g:vimrc_custom = NormFile(g:vimrc.'.custom')
let g:vimrc_leader = s:TrySourceFile(g:vimrc.'.leader', g:vimrc.'.before')
call Mkdir(g:temp)


" Preferences and Settings {{{

" GUI settings
if exists('&guifont')
  set guifont=Iosevka_Atkinson:h12
endif
let g:neovide_cursor_animate_command_line = v:false
let g:neovide_remember_window_size = v:false
let g:neovide_theme = 'auto'

" Application settings
syntax on
filetype plugin indent on
set guioptions=!egk
set mouse=a
set scrolloff=2 sidescrolloff=1
set splitbelow splitright
set switchbuf=usetab
set updatetime=500
if exists('&termguicolors')
  set termguicolors
endif

" Command bar
set completeopt=menuone,preview,noinsert,noselect
set gdefault ignorecase infercase smartcase
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
set tabstop=2 shiftwidth=0 softtabstop=-1
set number
let &thesaurus = NormFile(g:vimhome.'/moby-thesaurus/words.txt')

" Languages for other settings
let g:ui_languages = [ 'css', 'less', 'sass', 'scss', 'html', 'vue' ]
let g:programming_languages = g:ui_languages +
      \ [ 'c', 'cpp', 'cs', 'dosbatch', 'go', 'java',
      \ 'javascript', 'jsp', 'objc', 'ruby', 'sh',
      \ 'typescript', 'vim', 'zsh' ]

" }}}

" Plugins {{{

" From https://github.com/vscode-neovim/vscode-neovim/issues/415#issuecomment-715533865
function! LoadIf(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction


" Update packpath
if exists('&packpath')
  if match(&packpath, substitute(g:vimhome, '[\\/]', '[\\\\/]', 'g')) == -1
    let &packpath .= ','.g:vimhome
  endif
endif

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
      \   {'buns': ['[ ', ' ]'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': [']']},
      \   {'buns': ['( ', ' )'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': [')']},
      \   {'buns': ['{\s*', '\s*}'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['{', '}']},
      \   {'buns': ['\[\s*', '\s*\]'], 'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['[', ']']},
      \   {'buns': ['(\s*', '\s*)'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['(', ')']},
      \   { 'buns' : ['TagInput(1)', 'TagInput(0)'], 'expr' : 1, 'filetype': ['html'], 'kind' : ['add', 'replace'], 'action' : ['add'], 'input' : ['t'], },
      \ ]

function! TagInput(is_head) abort
  if a:is_head
    let s:TagLast = input('Tag: ')
    if s:TagLast !=# ''
      let tag = printf('<%s>', s:TagLast)
    else
      throw 'OperatorSandwichCancel'
    endif
  else
    let tag = printf('</%s>', matchstr(s:TagLast, '^\a[^[:blank:]>/]*'))
  endif
  return tag
endfunction

" }}}

" Keybindings and Commands {{{
" Sort via :sort /.*\%17v/
noremap          ;             :
noremap          :             ;

noremap <silent> <C-H>         <C-W>h
noremap <silent> <C-J>         <C-W>j
noremap <silent> <C-K>         <C-W>k
noremap <silent> <C-L>         <C-W>l
noremap <silent> <leader>/     <cmd>nohlsearch<cr>
noremap <silent> <leader>[     <cmd>setlocal wrap!<cr><cmd>setlocal wrap?<cr>
noremap <silent> <leader>c,    <cmd>cd ..<cr><cmd>echo ':cd '.getcwd()<cr>
noremap <silent> <leader>cd    <cmd>execute 'cd '.expand('%:p:h')<cr><cmd>echo ':cd '.getcwd()<cr>
noremap <silent> <leader>rg    <cmd>Grep <cword><cr>
noremap <silent> <leader>va    <cmd>execute 'e '.g:vimrc_custom<cr>
noremap <silent> <leader>vb    <cmd>execute 'e '.g:vimrc_leader<cr>
noremap <silent> <leader>vp    <cmd>execute 'e '.g:vimrc_plug<cr>
noremap <silent> <leader>vr    <cmd>execute 'e '.g:vimrc<cr>
noremap <silent> <leader>vi    <cmd>execute 'e '.g:vimrc_init<cr>
noremap <silent> <leader>vz    <cmd>execute 'source '.g:vimrc<cr>

noremap          Q             <C-Q>
noremap          ss            s
noremap <silent> gV            `[v`]
noremap <silent> gl            <plug>(leap-forward)
noremap <silent> gL            <plug>(leap-backward)
noremap <silent> go            <plug>(leap-forward-x)
noremap <silent> gO            <plug>(leap-backward-x)
noremap <silent> gs            <cmd>execute 'e '.g:scratch<cr><cmd>Autosave<cr>
noremap <silent> gz            <cmd>Goyo<cr>
noremap <silent> g.            g;
noremap <silent> g;            <plug>(leap-cross-window)

inoremap <silent> <C-Backspace> <C-W>
inoremap <silent> <D-Backspace> <C-U>
inoremap <silent><expr> <tab>   pumvisible() ? "\<C-N>" : "\<tab>"
inoremap <silent><expr> <s-tab> pumvisible() ? "\<C-P>" : "\<s-tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-Y>" : "\<C-G>u\<cr>"

" System (Ctrl- / Cmd-) commands
noremap  <silent> <leader>a  <C-C>ggVG
inoremap <silent> <leader>a  <esc>ggVG
noremap  <silent> <C-S> <cmd>update<cr>
noremap  <silent> <D-S> <cmd>update<cr>

let explorer = has('win32') ? 'explorer' : 'open'
execute "noremap  <silent> \\e  <cmd>execute 'silent !".explorer." '.shellescape(expand('%:p:h'))<cr>"

if has('clipboard')
  noremap  <leader>p "+gp
  noremap  <leader>P "+gP
  noremap  <leader>x "+x
  noremap  <leader>X "+X
  noremap  <leader>y "+y
  noremap  <leader>Y "+Y
  noremap! <leader>p <c-o>"+gp
  noremap! <leader>P <c-o>"+gP
endif

" Terminal commands
noremap <leader>t <cmd>Terminal<cr>
noremap <leader>T <cmd>terminal<cr>

tnoremap <c-n> <c-\><c-n>
tnoremap <c-w> <c-\><c-n><c-w>

" Commands
command! -nargs=0 Autosave call Autosave(1)
command! -nargs=0 NoAutosave call Autosave(0)
command! -nargs=+ -complete=file_in_path Grep call Grep(0, <f-args>)
command! -nargs=+ -complete=file_in_path LGrep call Grep(1, <f-args>)
call s:GenerateCAbbrev('grep', 2, 'Grep' )
call s:GenerateCAbbrev('lgrep', 2, 'LGrep')
call s:GenerateCAbbrev('rg', 2, 'Grep' )

command! -nargs=* Terminal wincmd b | bel split | terminal <args>
command! -nargs=* VTerminal wincmd l | bel vsplit | terminal <args>
command! -nargs=* ETerminal terminal <args>
call s:GenerateCAbbrev('terminal', 2, 'Terminal' )
call s:GenerateCAbbrev('sterminal', 3, 'Terminal' )
call s:GenerateCAbbrev('vterminal', 3, 'VTerminal' )
call s:GenerateCAbbrev('eterminal', 3, 'terminal' )

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
  autocmd BufNew,BufReadPre *.xaml,*.targets,*.props setf xml
  autocmd BufNew,BufReadPost keymap.c syn match QmkKcAux /_\{7}\|X\{7}\|__MIS__/ | hi! link QmkKcAux LineNr
  autocmd FileType gitcommit setlocal tw=72 fo+=t cc=50,+0
augroup end

augroup Terminal | autocmd!
  autocmd TermOpen * startinsert
  autocmd TermClose * if v:event.status == 0 | bdelete | endif
augroup end

augroup QuickExit | autocmd!
  autocmd BufWinEnter * if (&buftype =~ 'help\|quickfix' || &previewwindow) | noremap <buffer> q <C-W>c | endif
augroup end

augroup Spelling | autocmd!
  autocmd ColorScheme * hi clear SpellRare | hi clear SpellLocal
  autocmd BufRead * if &l:modifiable == 0 | setlocal nospell | endif
augroup end

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
  augroup RememberCursor " Clear cursor jump command
    autocmd!
  augroup end
  execute 'vertical resize '.((&columns * get(g:, 'diff_width', 50)) / 100)
  wincmd l | call setpos('.', [0, 1, 1, 0])
  set equalalways nohidden bufhidden=delete guioptions+=lr
  noremap q :qa<cr>
endfunction

" }}}

if !get(g:, 'vscode', 0)
  if 7 < strftime("%H") && strftime("%H") < 17
    execute 'set background='.get(g:, 'daybackground', 'light')
    execute 'colorscheme  '.get(g:, 'daytheme', 'pencil')
  else
    execute 'set background='.get(g:, 'nightbackground', 'dark')
    execute 'colorscheme  '.get(g:, 'nighttheme', 'pencil')
  endif
endif

let g:vimrc_custom = s:TrySourceFile(g:vimrc.'.custom', g:vimrc.'.after')
" vim: foldmethod=marker
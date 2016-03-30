set nocompatible
filetype off

" Load vimrc.before {{{
    if filereadable($MYVIMRC.'.before')
        source $MYVIMRC.before
    endif
" }}}

" Load pathogen {{{
    " Don't load pathogen more than once if the default paths were overriden
    " in vimrc.before.
    if !exists("g:plugins_loaded")
        let g:plugins_loaded = 1
        execute pathogen#infect('plugins/{}', 'colorschemes/{}', 'custom/{}')
        execute pathogen#helptags()
    endif
" }}}

" Functions {{{
    function! GuiTabLabel()
        " Tab number
        let label = '['.v:lnum.'] '

        " Buffer name
        let bufnrlist = tabpagebuflist(v:lnum)
        let bufnr = tabpagewinnr(v:lnum) - 1
        let name = bufname(bufnrlist[bufnr])
        if (name != '' && name !~ 'NERD_tree')
            " Get the name of the first real buffer
            let name = fnamemodify(name,":t")
        else
            let bufnr = len(bufnrlist)
            while ((name == '' || name =~ 'NERD_tree') && bufnr >= 0)
                let bufnr -= 1
                let name = bufname(bufnrlist[bufnr])
            endwhile
            if (name == '')
                let name = '[No Name]'
                if (&buftype == 'quickfix')
                    let name = '[Quickfix List]'
                endif
            else
                " Get the name of the first real buffer
                let name = fnamemodify(name,":t")
            endif
        endif
        if (getbufvar(bufnrlist[bufnr], '&buftype') == 'help')
            let name = 'help: '.fnamemodify(name, ':r')
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
            let label .= '... ('.wincount.')'
        endif

        " Add '+' if one of the buffers in the tab page is modified
        for bufnr in bufnrlist
            if getbufvar(bufnr, "&modified")
                let label .= ' [+]'
                break
            endif
        endfor

        return label
    endfunction

    function! GuiTabToolTip()
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
    endfunction

    function! TabOrComplete()
        if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
            return "\<C-N>"
        else
            return "\<Tab>"
        endif
    endfunction

    function! TryCreateDir(path)
        if !filereadable(a:path) && filewritable(a:path) != 2
            call mkdir(a:path)
        endif
    endfunction
" }}}

" Preferences and Settings {{{
    syntax on
    filetype plugin indent on
    set mouse=a

    " Visual aesthetics
    set noerrorbells visualbell t_vb=
    set lazyredraw
    set number
    set ruler
    set showcmd
    set wildmenu
    set equalalways
    set scrolloff=3 sidescrolloff=15
    set sidescroll=1

    " Search
    set incsearch
    set hlsearch
    set ignorecase smartcase

    " Whitespace and comments
    set tabstop=4 softtabstop=4 shiftwidth=4
    set expandtab smarttab
    set autoindent smartindent
    set formatoptions=jr

    " Word wrap
    set backspace=indent,eol,start
    set nowrap
    set linebreak
    set formatoptions+=cn

    " File organization
    set hidden
    set autoread
    set switchbuf=usetab
    set shortmess+=A
    set autochdir
    set foldmethod=syntax
    set foldenable
    set foldlevelstart=10
    set modeline modelines=1
" }}}

" Keybindings and Commands {{{
    inoremap          jk        <esc>
    inoremap          kj        <esc>
    inoremap <silent> <tab>     <c-r>=TabOrComplete()<cr>
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
    noremap  <silent> <leader>' :if &go=~#'r'<bar>set go-=r<bar>else<bar>set go+=r<bar>endif<cr>
    noremap  <silent> <leader>[ :setlocal wrap!<cr>:setlocal wrap?<cr>
    noremap  <silent> <leader>/ :noh<cr>
    noremap  <silent> <leader>b :NERDTreeTabsToggle<cr>
   "noremap  <silent> <leader>c {TAKEN: NERDCommenter}
   "noremap  <silent> <leader>f {TAKEN: Findstr}
   "noremap  <silent> <leader>h {TAKEN: GitGutter previews}
    noremap  <silent> <leader>i :set foldmethod=indent<cr>
   "noremap  <silent> <leader>m {TAKEN: Toggle GUI menu}
    noremap  <silent> <leader>n :setlocal relativenumber!<cr>
    noremap  <silent> <leader>N :setlocal number!<cr>
    noremap  <silent> <leader>r :source $MYVIMRC<cr>
    noremap  <silent> <leader>s :Startify<cr>
    noremap           <leader>t <plug>TaskList
    noremap  <silent> <leader>v "*p
    noremap  <silent> <leader>w :execute "resize ".line("$")<cr>
    noremap  <silent> <leader>y "*y
    noremap  <silent> <leader>z :tabnew $MYVIMRC<cr>
    noremap  <silent> cd        :execute 'cd '.expand("%:p:h")<cr>
    noremap  <silent> j         gj
    noremap  <silent> k         gk
    noremap           Q         :q
    noremap           Y         y$
    noremap           <tab>     %
    noremap           <space>   za
    noremap  <silent> [[        ^
    noremap  <silent> ]]        $
   "noremap  <silent> (         {TAKEN: Prev code line}
   "noremap  <silent> )         {TAKEN: Next code line}

    cabbrev h    <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab h' : 'h')<CR>
    cabbrev he   <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab he' : 'he')<CR>
    cabbrev hel  <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab hel' : 'hel')<CR>
    cabbrev help <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'tab help' : 'help')<CR>
" }}}

" Platform-Specific Settings {{{
if has("win32")
    let g:slash = '\'
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
    let g:slash = '/'
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
    let g:startify_bookmarks = [{'gc': $HOME.g:slash.'.gitconfig'}]
    if filereadable($MYVIMRC.'.after')
        let g:startify_bookmarks = [{'va': $MYVIMRC.'.after'}] + g:startify_bookmarks
    endif
    let g:startify_bookmarks = [{'vr': $MYVIMRC}] + g:startify_bookmarks
    if filereadable($MYVIMRC.'.before')
        let g:startify_bookmarks = [{'vb': $MYVIMRC.'.before'}] + g:startify_bookmarks
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
" }}}

" Autocommands {{{
if has("autocmd")
    augroup Startup
        au GUIEnter * set visualbell t_vb=

        " Jump to line cursor was on when last closed, if available
        au BufReadPost * if line("'\'") > 0 && line("'\'") <= line("$") |
            \    exe "normal g`\"" |
            \ endif
    augroup END

    augroup Filetypes
        au FileType c,cpp,cs,js,ts set foldmethod=indent |
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
endif
" }}}

" Load vimrc.after {{{
    if filereadable($MYVIMRC.'.after')
        source $MYVIMRC.after
    endif
" }}}

" vim: foldmethod=marker foldlevel=0

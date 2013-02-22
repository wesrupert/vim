# Ora's vim bundle

## A set of customizations for speedy development
This is the GVim setup I use on Windows Systems. Feel free to use it!

## Notable customizations

## Notable plugins
This bundle contains multiple plugins. The most noteworthy (or the ones that have extra commands) are listed here.

### ScrollColor
This plugin allows you to scroll through previews of your installed colorschemes. call :SCROLL to launch the previewer.

### [CtrlP.vim](https://github.com/kien/ctrlp.vim)
This plugin allows for fuzzy file searching to open documents. Use __<leader>/__ to call :CtrlP (invokes find file mode), then use these commands:
* __<f5>__: Refresh
* __<c-f> <c-b>__: Cycle modes
* __<c-d>__: Filename only search (don't use path)
* __<c-r>__: Regexp mode
* __<c-y>__: Create new file
* __<c-z> -> <c-o>__: Select multiple files, then open them all

### [vim-easymotion](https://github.com/Lokaltog/vim-easymotion)
This plugin allows you to select which result of a motion to use, rather than having to prepend a number beforehand. Just prepend <leader><leader> to a motion, and the results will be displayed afterward!

### [vim-fugitive](https://github.com/tpope/vim-fugitive)
A plugin for the programmer. This plugin has a large number of commands to integrate vim with git.
* __Gedit Gsplit etc.__: Edit a file, write to stage the changes
* __Gstatus__: Brings up the result of git status
* __Gblame__: Brings up the blame window
* __Gbrowse__: Browse the file on GitHub
This plugin is also integrated with powerline, and will give the branch name in the status bar when it belongs to a repository.

### [nerdcommenter](https://github.com/scrooloose/nerdcommenter)
A plugin for the programmer. Provides keystrokes for commenting out various sections of code quickly. (__Note__: Many can be preceded by a count)
* __<leader>cc__: Comments the current line
* __<leader>c<space>__: Toggles the lines to all commented or all uncommented
* __<leader>ci__: Toggles line to commented or uncommented individually
* __<leader>cs__: Comments the selection with pretty formatting
* __<leader>cl__: Comments the selection and gives it a left border
* __<leader>cb__: Comments the selection and puts it in a pretty box
* __<leader>cA__: Creates a comment area at the end of the line and inserts cursor there
* __<leader>cu__: Uncomments the selection

### [nerdtree](https://github.com/scrooloose/nerdtree)

### [vim-powerline](https://github.com/Lokaltog/vim-powerline)

### [vim-scmdiff](https://github.com/ghewgill/vim-scmdiff)

### [supertab](https://github.com/ervandew/supertab)

### [vim-surround](https://github.com/tpope/vim-surround)

### [syntastic](https://github.com/scrooloose/syntastic)

### tasklist
This plugin creates a task list generated from the comments in your code. Just type <leader>t to create the task list!

### [undotree](https://github.com/mbbill/undotree)

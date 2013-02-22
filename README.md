# Ora's vim bundle

## A set of customizations for speedy development
This is the GVim setup I use on Windows Systems. Feel free to use it!


## Notable customizations


## Notable plugins
This bundle contains multiple plugins. The most noteworthy (or the ones that have extra commands) are listed here. __Note__: These may not be up to date! I update them periodically, but go to the given link to check if there is a newer version!

### [CtrlP.vim](https://github.com/kien/ctrlp.vim)
This plugin allows for fuzzy file searching to open documents. Use __\<leader>/__ to call :CtrlP (invokes find file mode), then use these commands:
* __\<f5>__: Refresh
* __\<c-f> \<c-b>__: Cycle modes
* __\<c-d>__: Filename only search (don't use path)
* __\<c-r>__: Regexp mode
* __\<c-y>__: Create new file
* __\<c-z> then \<c-o>__: Select multiple files, then open them all

### [vim-easymotion](https://github.com/Lokaltog/vim-easymotion)
This plugin allows you to select which result of a motion to use, rather than having to prepend a number beforehand. Just prepend \<leader>\<leader> to a motion, and the results will be displayed afterward!

### [vim-fugitive](https://github.com/tpope/vim-fugitive)
A plugin for the programmer. This plugin has a large number of commands to integrate vim with git.
* __Gedit Gsplit etc.__: Edit a file, write to stage the changes
* __Gstatus__: Brings up the result of git status
* __Gblame__: Brings up the blame window
* __Gbrowse__: Browse the file on GitHub
This plugin is also integrated with powerline, and will give the branch name in the status bar when it belongs to a repository.

### [nerdcommenter](https://github.com/scrooloose/nerdcommenter)
A plugin for the programmer. Provides keystrokes for commenting out various sections of code quickly. (__Note__: Many can be preceded by a count)
* __\<leader>cc__: Comments the current line
* __\<leader>c\<space>__: Toggles the lines to all commented or all uncommented
* __\<leader>ci__: Toggles line to commented or uncommented individually
* __\<leader>cs__: Comments the selection with pretty formatting
* __\<leader>cl__: Comments the selection and gives it a left border
* __\<leader>cb__: Comments the selection and puts it in a pretty box
* __\<leader>cA__: Creates a comment area at the end of the line and inserts cursor there
* __\<leader>cu__: Uncomments the selection

### [vim-scmdiff](https://github.com/ghewgill/vim-scmdiff)
A plugin for the programmer. Provides a quick differ to show changes for version-controlled files. Type \<leader>d to toggle diff.

### [ScrollColors](http://www.vim.org/scripts/script.php?script_id=1488)
This plugin allows you to scroll through previews of your installed colorschemes. call :SCROLL to launch the previewer.

### [vim-surround](https://github.com/tpope/vim-surround)
Surrounds chunks of text with paired delimiters.
* __ys\[motion]\[delim]__: Adds the delimiter around the selection given by the motion
* __cs\[motion]\[delim]__: Replaces the delimiter around the selection given by the motion
* __ds\[motion]__: Removes the delimiter around the selection given by the motion
* __S\[delim]__: Adds the delimiter around a visual selection


### [tasklist](http://www.vim.org/scripts/script.php?script_id=2607)
This plugin creates a task list generated from the comments in your code. Just type \<leader>t to create the task list!

### [undotree](https://github.com/mbbill/undotree)
Did you know vim stores its undos, not in a list, but a tree? It saves everything you undo or redo period, even if you change something. But it's a pain to navigate alone. Undotree remedies this. Just type \<leader>u to open the tree for easy navigation.

### Other plugins
Plugins that don't need an introduction to start improving your life.
* [html-autoclosetag](http://www.vim.org/scripts/script.php?script_id=2591): Automatically close html tags.
* [matchit.zip](http://www.vim.org/scripts/script.php?script_id=39): Add % matching to html tags.
* [nerdtree](https://github.com/scrooloose/nerdtree): File explorer in vim.
* [numbers.vim](https://github.com/myusuf3/numbers.vim.git) Changes line numbers to distance from cursor in normal mode.
* [vim-powerline](https://github.com/Lokaltog/vim-powerline) Adds a fancier and more informative status line to the window.
* python-editing: A collection of various pyhon editing plugins from vim.org.
* [SearchComplete](http://www.vim.org/scripts/script.php?script_id=474): Adds tab completion to '/' search.
* [supertab](https://github.com/ervandew/supertab): Better tab completion.
* [syntastic](https://github.com/scrooloose/syntastic): Syntax checking for vim. Checkers sold separately.

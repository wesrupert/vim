# Vim, My Way

## A set of customizations for speedy development
This is the GVim setup I use on Windows Systems. Feel free to use it!

__Note__: This bundle is from a Windows environment. Using it on a non-windows machine may provide less-than-complete functionality.

## Installation instructions
It is really reccomended that you download this with git. It will automate dependency resolution for you, and be a lot less painful.

### Installation
1. Get [git](https://git-scm.com/download).
2. Get [vim](http://www.vim.org/download.php).
3. Clone this repository into a temp folder with `git clone https://github.com/wesrupert/vim`.
4. Copy the result of the clone into your runtime directory (e.g. `~/.vim` or `C:\Vim\vim74`).
5. Download dependencies with `git submodule update --init`.
6. Create links to your vimrc and pathogen.
   * Windows (must be in your vim runtime directory):
   ```dos
   mklink /H ..\_vimrc vimrc
   mkdir .\autoload
   mklink /H autoload\pathogen.vim bundle\pathogen\autoload\pathogen.vim
   ```
   * OSX/Linux:
   ```bash
   ln ~/.vimrc ~/.vim/vimrc
   mkdir ~/.vim/autoload
   ln ~/.vim/autoload/pathogen.vim ~/.vim/bundle/pathogen/autoload/pathogen.vim
   ```

---------------------------------------
# THIS SECTION IS OLD AND MISSING A LOT
---------------------------------------

## Notable customizations
If you really want to understand what is going on with this flavour of vim versus the standard distribution, I really reccomend looking through the vimrc. However, here are the most notable customisations.

### Custom keybindings
I dislike having to reach all the way to the corner to press escape all the time. So I usually rebind capslock systemwide to escape on my computers. However, I find that this little trick also is useful. Having `imap jk <esc>` and `imap kj <esc>` makes it so I can just mash `j` and `k` to return to normal mode.

I manipulate partner files to files I'm editing often, and like to have a file explorer window open in the current directory often. I bound `<c-e>` to `:silent !explorer .<cr>` to accomplish this.

I like `<c-a>` for select all. I'm just used to it. So I use `(i)map <c-a> <esc>ggVG`.

Global copy paste is nice when interacting with other applications. So I use `map <leader>v "+p` and `map <leader>y "+y` to quickly copy to the global register.

I get annoyed by random highlights easily. And I like searching with hlsearch on, so it's nice to have a quick way to disable it after a search. `map <leader>] :noh<CR>` does the trick for me.

When I use j and k to go up and down, I expect it to go up and down. When there's word wrap, it goes to the next line. While I understand the reasoning for it, I find it annoying, and so use `map <silent> j gj` and `map <silent> k gk` to fix this.

Some nice toggles to have: `map <leader>l :setlocal number!<CR>` and `map <leader>[ :setlocal wrap!<CR>:setlocal wrap?<CR>`.

I like window splitting, but dislike the three-finger chord to navigate between them, So I use `map <c-j> <c-w>j` and the like to do it faster.

### Other customizations
There are a few other customizations of note. Most of them are minor tweaks you can see by looking at the .vimrc (it's all commented and separated nicely for you!), but here are the most significant.

I like having things fullscreen, but GVim doesn't have that functionality. So, I use [gvimfullscreen.dll](http://www.vim.org/scripts/script.php?script_id=2596) to give it that functionality. There's a function I wrote at the bottom of the .vimrc managing how it's resized. This is bound to the regular `<f11>` that other applications use. This functionality only applies to GVim, the terminal version doesn't have this.

I also like knowing the current directory for fast file actions. So I put it in the titlebar of the window. Also, I dislike the sound of the error bell, so I disabled it.


## Notable plugins
This bundle contains multiple plugins. The most noteworthy (or the ones that have extra commands) are listed here. __Note__: These may not be up to date! I update them periodically, but go to the given link to check if there is a newer version!

### [CtrlP.vim](https://github.com/kien/ctrlp.vim)
This plugin allows for fuzzy file searching to open documents. Use `<c-p>` to call `:CtrlP` (invokes find file mode), then use these commands:
* `<f5>`: Refresh
* `<c-f> <c-b>`: Cycle modes
* `<c-d>`: Filename only search (don't use path)
* `<c-r>`: Regexp mode
* `<c-y>`: Create new file
* `<c-z> then <c-o>`: Select multiple files, then open them all

### [vim-easymotion](https://github.com/Lokaltog/vim-easymotion)
This plugin allows you to select which result of a motion to use, rather than having to prepend a number beforehand. Just prepend `<leader><leader>` to a motion, and the results will be displayed afterward!

### [engspchk](http://www.vim.org/scripts/script.php?script_id=195)
This plugin adds spellcheck directly into vim. Take control of your spelling! Type `<leader>ec` to commence spellchecking, then use these commands:
* `<leader>ea`: Lookup alternate spellings of the word under the cursor
* `<leader>en` and `<leader>ep`: Navigate through spelling errors
* `<leader>es` and `<leader>eS`: Save and remove word under the cursor for future spellchecking
* `<leader>et` and `<leader>eT`: temprarily save and remove word under cursor
* `<leader>ee`: End spellchecking

### [vim-fugitive](https://github.com/tpope/vim-fugitive)
A plugin for the programmer. This plugin has a large number of commands to integrate vim with git.
* `:Gedit`, `:Gsplit`, etc.: Edit a file, write to stage the changes
* `:Gstatus`: Brings up the result of git status
* `:Gblame`: Brings up the blame window
* `:Gbrowse`: Browse the file on GitHub
This plugin is also integrated with powerline, and will give the branch name in the status bar when it belongs to a repository.

### [nerdcommenter](https://github.com/scrooloose/nerdcommenter)
A plugin for the programmer. Provides keystrokes for commenting out various sections of code quickly. (Note: Many can be preceded by a count)
* `<leader>cc`: Comments the current line
* `<leader>c<space>`: Toggles the lines to all commented or all uncommented
* `<leader>ci`: Toggles line to commented or uncommented individually
* `<leader>cs`: Comments the selection with pretty formatting
* `<leader>cl`: Comments the selection and gives it a left border
* `<leader>cb`: Comments the selection and puts it in a pretty box
* `<leader>cA`: Creates a comment area at the end of the line and inserts cursor there
* `<leader>cu`: Uncomments the selection

### [vim-scmdiff](https://github.com/ghewgill/vim-scmdiff)
A plugin for the programmer. Provides a quick differ to show changes for version-controlled files. Type `<leader>d` to toggle diff.

### [ScrollColors](http://www.vim.org/scripts/script.php?script_id=1488)
This plugin allows you to scroll through your installed colorschemes. call `:SCROLL` to launch the previewer, or use:
* `<leader>n`: Next colorscheme
* `<leader>p`: Previous colorscheme

### [vim-surround](https://github.com/tpope/vim-surround)
Surrounds chunks of text with paired delimiters.
* `ys[motion][delim]`: Adds the delimiter around the selection given by the motion
* `cs[motion][delim]`: Replaces the delimiter around the selection given by the motion
* `ds[motion]`: Removes the delimiter around the selection given by the motion
* `S[delim]`: Adds the delimiter around a visual selection


### [tasklist](http://www.vim.org/scripts/script.php?script_id=2607)
This plugin creates a task list generated from the comments in your code. Just type `<leader>t` to create the task list!

### [tagbar](http://majutsushi.github.com/tagbar/)
A plugin for the programmer. This plugin creates a list of objects in your code (methods, variables, etc.) Open the tag bar with `<leader>l`.

### [undotree](https://github.com/mbbill/undotree)
Did you know vim stores its undos, not in a list, but a tree? It saves everything you undo or redo period, even if you change something. But it's a pain to navigate alone. Undotree remedies this. Just type `<leader>u` to open the tree for easy navigation.

### Other plugins
Plugins that don't need an introduction to start improving your life.
* [html-autoclosetag](http://www.vim.org/scripts/script.php?script_id=2591): Automatically close html tags.
* [matchit.zip](http://www.vim.org/scripts/script.php?script_id=39): Add `%` matching to html tags.
* [numbers.vim](https://github.com/myusuf3/numbers.vim.git) Changes line numbers to distance from cursor in normal mode.
* [vim-powerline](https://github.com/Lokaltog/vim-powerline) Adds a fancier and more informative status line to the window.
* python-editing: A collection of various pyhon editing plugins from vim.org.
* [rainbow-parentheses](https://github.com/kien/rainbow_parentheses.vim) Colors nested parentheses different colors.
* [repeat](https://github.com/tpope/vim-repeat) Adds `.` repeat functionality to plugins.
* [SearchComplete](http://www.vim.org/scripts/script.php?script_id=474): Adds tab completion to `/` search.
* [supertab](https://github.com/ervandew/supertab): Better tab completion.
* [syntastic](https://github.com/scrooloose/syntastic): Syntax checking for vim. Checkers sold separately, check `syntax_checkers/<filetype>/` for what checkers are supported.

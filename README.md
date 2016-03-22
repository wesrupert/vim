# Vim, My Way
This is my personal set of customizations and plugins. I have this set up to be as cross-platform as possible and to be entirely git-driven.

## Installation instructions
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

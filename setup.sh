#!/bin/bash

git submodule update --init
mkdir ~/.vim/autoload
ln -f ~/.vim/vimrc ~/.vimrc
ln -f ~/.vim/bundle/pathogen/autoload/pathogen.vim ~/.vim/autoload/pathogen.vim

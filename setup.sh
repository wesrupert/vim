#!/bin/bash

git submodule update --init
ln -s ~/.vim/vimrc ~/.vimrc
mkdir ~/.vim/autoload
ln -s ~/.vim/bundle/pathogen/autoload/pathogen.vim ~/.vim/autoload/pathogen.vim

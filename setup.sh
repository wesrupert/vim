#!/bin/bash

git submodule update --init
mkdir ~/.vim/autoload
ln -s ~/.vim/bundle/pathogen/autoload/pathogen.vim ~/.vim/autoload/pathogen.vim

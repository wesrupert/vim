#!/bin/bash

pushd ~/.vim

echo Updating vim...
git pull

echo Updating plugins...
git submodule update --init

echo Updating auxiliary files...
mkdir -p ~/.vim/autoload 2>/dev/null
ln -f ~/.vim/vimrc ~/.vimrc
ln -f ~/.vim/bundle/pathogen/autoload/pathogen.vim ~/.vim/autoload/pathogen.vim

echo Setup done!
popd

#!/bin/bash

pushd ~/.vim

echo Updating vim...
git pull

echo Updating plugins...
git submodule update --init

echo Updating auxiliary files...
ln -f ~/.vim/vimrc ~/.vimrc

echo Setup done!
popd

#!/bin/bash

pushd ~/.vim > /dev/null

echo Initializing plugins...
git submodule update --init

echo Updating auxiliary files...
ln -f ~/.vim/vimrc ~/.vimrc
ln -f ~/.vim/vimrc ~/init.vim

echo Setup done! Plugins up to date.
echo Note that the following are disabled by default:
pushd pack > /dev/null
for plug in */; do
    if [ ! -d "$plug/start" && -d "$plug/opt" ]; then
        sub = ls "$plug/opt" | head 1
        echo $sub
    fi
done
popd > /dev/null

popd > /dev/null

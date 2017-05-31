#!/bin/bash

pushd ~/.vim > /dev/null

echo Initializing plugins...
git submodule update --init --recursive

echo Updating auxiliary files...
ln -f ~/.vim/vimrc ~/.vimrc
ln -f ~/.vim/init.vim ~/init.vim

echo Performing additional setup...
pushd pack\omnisharp\opt\omnisharp\server > /dev/null
xbuild > /dev/null
popd > /dev/null

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

#!/bin/bash

installdir="$(dirname $0)"

# Set up links
nvimdir="$HOME/.config/nvim"
mkdir -p $nvimdir

ln $installdir/vimrc $HOME/.vimrc > /dev/null 2>&1
ln $installdir/init.vim $nvimdir > /dev/null 2>&1
ln $installdir/.ideavimrc $HOME/.ideavimrc > /dev/null 2>&1

# Initialize vim plug
git submodule update --init --recursive

echo Done!

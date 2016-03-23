@echo off

git submodule update --init
mkdir autoload
mklink /H autoload\pathogen.vim bundle\pathogen\autoload\pathogen.vim
mklink /H ..\_vsvimrc vsvimrc

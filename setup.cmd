@echo off

pushd %UserProfile%\vimfiles

echo Updating vim...
git pull

echo Updating plugins...
git submodule update --init

echo Updating auxiliary files...
mkdir autoload 2>nul
mklink /H autoload\pathogen.vim bundle\pathogen\autoload\pathogen.vim 2>nul
del ..\_vsvimrc 2>nul
copy /Y vsvimrc ..\_vsvimrc >nul

echo Setup done!
popd

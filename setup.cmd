@echo off

pushd %UserProfile%\vimfiles

echo Updating vim...
git pull

echo Updating plugins...
git submodule update --init

echo Updating auxiliary files...
mkdir autoload 2>nul
copy /Y plugins\pathogen\autoload\pathogen.vim autoload\pathogen.vim >nul
del ..\_vsvimrc 2>nul
copy /Y vsvimrc ..\_vsvimrc >nul

echo Setup done!
popd

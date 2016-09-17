@echo off

pushd %UserProfile%\vimfiles

echo Updating vim...
git pull

echo Updating plugins...
git submodule update --init

echo Updating vsvimrc...
del ..\_vsvimrc 2>nul
copy /Y vsvimrc ..\_vsvimrc >nul

echo Setup done!
popd

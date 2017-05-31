@echo off

pushd %UserProfile%\vimfiles

mklink /H %UserProfile%\AppData\Local\nvim\init.vim init.vim >nul

echo Updating plugins...
git submodule update --init --recursive

echo Updating vsvimrc...
del ..\_vsvimrc 2>nul
copy /Y vsvimrc ..\_vsvimrc >nul

echo Performing additional setup...
pushd pack\omnisharp\opt\omnisharp\server
msbuild >nul
popd

echo Setup done! Plugins up to date.
echo.
echo Note that the following are disabled by default:
pushd pack
for /D %%P in ("*") do (
    if not exist %%P\start (
        echo.    %%P
    )
)

popd
echo.

popd

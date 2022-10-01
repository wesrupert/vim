function Ln {
	param ([string]$target, [string]$path)
	if (-not (Test-Path -Path $path)) {
		New-Item -ItemType SymbolicLink -Target $target -Path $path -ErrorAction Stop
	}
}

$installdir = $PSScriptRoot
pushd $installdir

# Set up links
$nvimdir ="$($env:LOCALAPPDATA)\nvim"
New-Item -Type Directory $nvimdir -ErrorAction SilentlyContinue
Ln -Target "$installdir\vimrc" -Path "$HOME\vimrc"
Ln -Target "$installdir\init.vim" -Path "$nvimdir\init.vim"
Ln -Target "$installdir\ginit.vim" -Path "$nvimdir\ginit.vim"
Ln -Target "$installdir\coc-settings.json" -Path "$nvimdir\coc-settings.json"
Ln -Target "$installdir\.ideavimrc" -Path "$HOME\ideavimrc"

# Initialize vim plug
git submodule update --init --recursive

popd
echo Done!

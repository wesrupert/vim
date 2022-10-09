function Ln {
  param ([string]$target, [string]$path)
    if (-not (Test-Path -Path $path)) {
      New-Item -ItemType SymbolicLink -Target $target -Path $path -ErrorAction Stop
    }
}

Write-Host 'Checking for gcc...'
if (-not (Get-Command gcc -ErrorAction SilentlyContinue)) {
  if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host 'Gcc not found. Installing mingw...'
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {  
      $arguments = "& '" +$myinvocation.mycommand.definition + "'"
        Write-Host 'Running install as admin...'
        Start-Process powershell -Verb runAs -ArgumentList $arguments
        Exit
    }
    choco install mingw
    Exit
  } else {
    Write-Host 'Chocolatey not available. Please install mingw to continue...'
    Exit
  }
} else {
  Write-Host 'Gcc found.'
}

$installdir = $PSScriptRoot
pushd $installdir

Write-Host Setting up links...
$nvimdir ="$($env:LOCALAPPDATA)\nvim"
New-Item -Type Directory $nvimdir -ErrorAction SilentlyContinue
Ln -Target "$installdir\vimrc" -Path "$HOME\vimrc"
Ln -Target "$installdir\init.vim" -Path "$nvimdir\init.vim"
Ln -Target "$installdir\ginit.vim" -Path "$nvimdir\ginit.vim"
Ln -Target "$installdir\coc-settings.json" -Path "$nvimdir\coc-settings.json"
Ln -Target "$installdir\.ideavimrc" -Path "$HOME\ideavimrc"

Write-Host Updating submodules...
git submodule update --init --recursive

popd

Write-Host Done!

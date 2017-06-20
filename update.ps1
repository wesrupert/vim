﻿function Get-Commits {
    $paths = @() ; $commits = @()
    $output = git submodule foreach git log -1 --pretty=format:"%H%n"
    while ($output.Count -ge 2) {
        $path, $commit, $output = $output

        # $path is in the format of "Entering '{path}'", extract path from it.
        $paths += $path -replace "Entering '(.*)'",'$1'
        $commits += $commit
    }

    return $paths, $commits
}

echo 'Rewinding to initial state...'
$null = git submodule update --init --recursive 2>&1

echo 'Getting old commit hashes...'
$paths, $olds = Get-Commits

echo 'Updating plugins...'
$null = git submodule update --remote --merge 2>&1

echo 'Getting new commit hashes...'
$null, $news = Get-Commits

if ($paths.Count -eq 0 -or $($paths.Count + $olds.Count + $news.Count) -ne $($paths.Count * 3)) {
    Write-Host "ERROR: Log data counts don't match!" -ForegroundColor 'Red'
} elseif ($paths.Count -eq 0) {
    echo 'Done! No updates found.'
} else {
    echo 'Done!'
    echo ''
}


for ($i = 0; $i -lt $paths.Count; $i++) {
    $old = $olds[$i]
    $new = $news[$i]
    if ($old -eq $new) { continue }

    $path = $paths[$i]

    pushd $path
    $pwd = $(pwd).Path
    $name = $pwd.Substring($pwd.LastIndexOf('\') + 1)
    echo "Updated {$name}. Changes:"
    git log $old~1..$new --pretty=format:" - %s"

    # If the plugin is up to date, we will only have two directories: 'pack/{name}'.
    $isUpdated = ([Regex]::Matches($path, '/')).Count -eq 1
    if ((-not $isUpdated) -and ($(Test-Path 'start') -or $(Test-Path 'opt'))) {
        Write-Host "WARNING: $name has updated to the new package model!" -ForegroundColor 'Yellow'
    }

    echo ''
    popd
}

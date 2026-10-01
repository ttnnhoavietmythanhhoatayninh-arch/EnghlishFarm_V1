$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$target = 'https://github.com/ttnnhoavietmythanhhoatayninh-arch/EnghlishFarm_V1.git'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Install Git and sign in to GitHub first.' }
$refs = git ls-remote $target
if ($LASTEXITCODE -ne 0) { throw 'Cannot access repository. Check GitHub authentication.' }
if ($refs) { throw 'Repository is no longer empty. Clone it and import this source on a new branch; do not force push.' }
if (-not (Test-Path .git)) {
 git init -b main
 if ($LASTEXITCODE -ne 0) { throw 'git init failed' }
 git add .
 git commit -m 'Add EnglishFarm Town trial, assets, documentation and tests'
 if ($LASTEXITCODE -ne 0) { throw 'Commit failed; configure your Git author identity first.' }
}
$remote = git remote get-url origin 2>$null
if ($remote -and $remote -ne $target) { throw 'Existing origin differs; inspect it manually.' }
if (-not $remote) { git remote add origin $target }
git push -u origin HEAD:main
if ($LASTEXITCODE -ne 0) { throw 'Push failed; check write access. No force push was attempted.' }
Write-Host 'Source uploaded. Open GitHub Actions for the Windows build.'

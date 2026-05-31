# Publish coursework to GitHub and enable GitHub Pages
$ErrorActionPreference = 'Stop'
$RepoName = 'Веб-сайт-онлайн-курса-ВЕБ-ДИЗАЙН.ПРОСТО'

Set-Location $PSScriptRoot

gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'GitHub CLI is not authenticated. Run: gh auth login'
    exit 1
}

$username = gh api user --jq .login
Write-Host "GitHub user: $username"

if (-not (git remote get-url origin 2>$null)) {
    gh repo create $RepoName --public --source=. --remote=origin --description 'Лендинг курса UX/UI — курсовая работа МИРЭА (ТКМО-01-25)'
    git push -u origin main
} else {
    git push -u origin main
}

gh api "repos/$username/$RepoName/pages" -X POST -f build_type=legacy -f 'source[branch]=main' -f 'source[path]=/' 2>$null
if ($LASTEXITCODE -ne 0) {
    gh api "repos/$username/$RepoName/pages" -X PUT -f build_type=legacy -f 'source[branch]=main' -f 'source[path]=/'
}

$pagesUrl = gh api "repos/$username/$RepoName/pages" --jq .html_url 2>$null
if (-not $pagesUrl) {
    $pagesUrl = "https://$username.github.io/$RepoName/"
}

Write-Host ''
Write-Host 'Done!'
Write-Host "Repository: https://github.com/$username/$RepoName"
Write-Host "Live site:  $pagesUrl"
Write-Host ''
Write-Host 'GitHub Pages may take 1-2 minutes to become available.'

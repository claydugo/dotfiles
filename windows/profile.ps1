$env:XDG_CONFIG_HOME = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { "$HOME\.config" }
$env:XDG_DATA_HOME   = if ($env:XDG_DATA_HOME)   { $env:XDG_DATA_HOME }   else { "$HOME\.local\share" }
$env:XDG_CACHE_HOME  = if ($env:XDG_CACHE_HOME)  { $env:XDG_CACHE_HOME }  else { "$HOME\.cache" }
$env:XDG_STATE_HOME  = if ($env:XDG_STATE_HOME)  { $env:XDG_STATE_HOME }  else { "$HOME\.local\state" }

$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:RIPGREP_CONFIG_PATH = "$HOME\dotfiles\.config\.ripgreprc"
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
$env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND
$env:FZF_ALT_C_COMMAND   = 'fd --type d --hidden --exclude .git'
$env:BUN_INSTALL = "$HOME\.bun"

if (Get-Command zig -ErrorAction SilentlyContinue) { $env:CC = 'zig cc' }

$env:RUST_BACKTRACE = 'full'
$env:PYGFX_PRINT_WGSL_ON_COMPILATION_ERROR = '1'
$env:CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = '1'

function Add-PathHead {
    param([string]$Dir)
    if ($Dir -and (Test-Path $Dir) -and (";$env:PATH;" -notlike "*;$Dir;*")) {
        $env:PATH = "$Dir;$env:PATH"
    }
}
Add-PathHead "$HOME\go\bin"
Add-PathHead "$HOME\.bun\bin"
Add-PathHead "$HOME\.cargo\bin"
Add-PathHead "$HOME\.local\bin"
Add-PathHead "$HOME\.pixi\bin"

if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -ViModeIndicator Cursor
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle InlineView   # F2 toggles ListView
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -MaximumHistoryCount 100000
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

foreach ($a in 'ls', 'cat', 'cl', 'r', 'gc', 'gp', 'sl', 'gl') {
    if (Test-Path "Alias:$a") { Remove-Item "Alias:$a" -Force -ErrorAction SilentlyContinue }
}

function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function ..... { Set-Location ../../../.. }
function proj { Set-Location ~/projects }
function dl { Set-Location ~/Downloads }
function doc { Set-Location ~/Documents }
function dt { Set-Location ~/Desktop }

function g { git @args }
function gti { git @args }
function cl { Clear-Host }
function p { python @args }
function i { ipython @args }
function path { $env:PATH -split ';' }
function :q { exit }
function f { explorer . }
function glb { git shortlog -nse }
function git_clean {
    git branch | Where-Object { $_ -notmatch 'main|master' } | ForEach-Object { git branch -D $_.Trim() }
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    function v { nvim @args }
    function vi { nvim @args }
    function vim { nvim @args }
    function vimdiff { nvim -d @args }
}

if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza @args }
    function ll { eza -lah --git --icons @args }
    function lll { eza -abghHliS@ --git --icons @args }
} else {
    function ll { Get-ChildItem -Force @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    function la { bat "$HOME\dotfiles\.aliases" -l bash }
} else {
    function la { Get-Content "$HOME\dotfiles\.aliases" }
}

function td {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $dir | Out-Null
    Set-Location $dir
}

function extract {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path $Path)) { Write-Error "'$Path' not found"; return }
    switch -Wildcard ($Path) {
        '*.tar.gz'  { tar xzf $Path }
        '*.tgz'     { tar xzf $Path }
        '*.tar.bz2' { tar xjf $Path }
        '*.tbz2'    { tar xjf $Path }
        '*.tar.xz'  { tar xf  $Path }
        '*.tar'     { tar xf  $Path }
        '*.gz'      { tar xzf $Path }
        '*.zip'     { Expand-Archive -Path $Path -DestinationPath . -Force }
        default     { Write-Error "Don't know how to extract '$Path'" }
    }
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
}

if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd | Out-String | Invoke-Expression
}

if ((Get-Module -ListAvailable PSFzf) -and (Get-Command fzf -ErrorAction SilentlyContinue)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PsFzfOption -TabExpansion
}

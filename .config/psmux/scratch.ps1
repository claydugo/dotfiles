# Daily scratch note — Windows equivalent of the tmux M-n popup.
$dir = Join-Path $HOME 'scratch'
New-Item -ItemType Directory -Force $dir | Out-Null
nvim (Join-Path $dir ((Get-Date -Format 'yyyyMMdd') + '.md'))

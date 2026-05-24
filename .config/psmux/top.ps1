# Lightweight htop-style process monitor — Windows equivalent of the tmux M-g
# popup (no native htop on Windows; this needs no extra installs). Ctrl-C exits.
try {
    while ($true) {
        Clear-Host
        Get-Process |
            Sort-Object -Property CPU -Descending |
            Select-Object -First 30 Id,
                @{ Name = 'CPU(s)';  Expression = { [math]::Round($_.CPU, 1) } },
                @{ Name = 'Mem(MB)'; Expression = { [math]::Round($_.WS / 1MB) } },
                ProcessName |
            Format-Table -AutoSize
        Start-Sleep -Seconds 2
    }
} catch [System.Management.Automation.PipelineStoppedException] { }

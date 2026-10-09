# sva-skills optify switch — enabled, before, after.
# Dot-sourced by cli.ps1. Uses Die and Write-Out.
#
# Config: ${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env
# Same XDG_DATA_HOME branch as docify, then $HOME/.local/share. No second path.
#
#   .\scripts\cli.ps1 optify on|off|show|before|after|clear-shots

function Get-OptifyConfigPath {
    if ($env:XDG_DATA_HOME) {
        return (Join-Path (Join-Path $env:XDG_DATA_HOME 'sva-skills') 'optify.env')
    }
    return (Join-Path (Join-Path (Join-Path $HOME '.local') 'share') (Join-Path 'sva-skills' 'optify.env'))
}

function Reset-OptifyState {
    $script:OptifyEnabled = ''
    $script:OptifyBefore = ''
    $script:OptifyAfter = ''
}

function Read-OptifyEnv {
    Reset-OptifyState
    $cfg = Get-OptifyConfigPath
    if (-not (Test-Path -LiteralPath $cfg -PathType Leaf)) {
        return
    }
    foreach ($raw in Get-Content -LiteralPath $cfg -Encoding UTF8) {
        $line = $raw.Trim()
        if ($line -eq '' -or $line.StartsWith('#')) { continue }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { continue }
        $key = $line.Substring(0, $eq)
        $val = $line.Substring($eq + 1)
        switch ($key) {
            'enabled' { $script:OptifyEnabled = $val }
            'before' { $script:OptifyBefore = $val }
            'after' { $script:OptifyAfter = $val }
        }
    }
}

function Write-OptifyEnv {
    $cfg = Get-OptifyConfigPath
    $dir = Split-Path -Parent $cfg
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $lines = New-Object System.Collections.Generic.List[string]
    [void]$lines.Add('# sva-skills optify')
    if ($script:OptifyEnabled -eq 'on' -or $script:OptifyEnabled -eq 'off') {
        [void]$lines.Add("enabled=$($script:OptifyEnabled)")
    }
    # before and after are absent unless armed. Never write before=0 or after=0.
    if ($script:OptifyBefore -eq '1') {
        [void]$lines.Add('before=1')
    }
    if ($script:OptifyAfter -eq '1') {
        [void]$lines.Add('after=1')
    }
    $tmp = Join-Path $dir ('.optify.env.{0}' -f [guid]::NewGuid().ToString('N').Substring(0, 8))
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($tmp, $lines.ToArray(), $utf8)
    Move-Item -LiteralPath $tmp -Destination $cfg -Force
    try {
        icacls $cfg /inheritance:r /grant:r "${env:USERNAME}:R" | Out-Null
    }
    catch {
        # Best-effort private file; chmod 600 equivalent is not always available.
    }
}

function Show-OptifyEnv {
    Read-OptifyEnv
    $en = 'on'
    if ($script:OptifyEnabled -eq 'off') { $en = 'off' }
    $before = 'not'
    if ($script:OptifyBefore -eq '1') { $before = 'armed' }
    $after = 'not'
    if ($script:OptifyAfter -eq '1') { $after = 'armed' }
    Write-Out "config: $(Get-OptifyConfigPath)"
    Write-Out "enabled: $en"
    Write-Out "before: $before"
    Write-Out "after: $after"
}

function Set-OptifyEnabled {
    param([string]$Value)
    Read-OptifyEnv
    $script:OptifyEnabled = $Value
    Write-OptifyEnv
}

function Set-OptifyShot {
    param([string]$Which)
    Read-OptifyEnv
    if ($Which -eq 'before') {
        $script:OptifyBefore = '1'
    }
    else {
        $script:OptifyAfter = '1'
    }
    Write-OptifyEnv
}

function Clear-OptifyShots {
    $cfg = Get-OptifyConfigPath
    if (-not (Test-Path -LiteralPath $cfg -PathType Leaf)) {
        return
    }
    Read-OptifyEnv
    $script:OptifyBefore = ''
    $script:OptifyAfter = ''
    Write-OptifyEnv
}

function Invoke-OptifyCommand {
    param([string[]]$OptifyArgs)
    if ($null -eq $OptifyArgs) {
        $OptifyArgs = @()
    }
    if ($OptifyArgs.Count -ne 1 -or [string]::IsNullOrEmpty($OptifyArgs[0])) {
        Die 'usage: optify on|off|show|before|after|clear-shots'
    }
    switch ($OptifyArgs[0].ToLowerInvariant()) {
        'on' { Set-OptifyEnabled -Value 'on' }
        'off' { Set-OptifyEnabled -Value 'off' }
        'show' { Show-OptifyEnv }
        'before' { Set-OptifyShot -Which 'before' }
        'after' { Set-OptifyShot -Which 'after' }
        'clear-shots' { Clear-OptifyShots }
        default { Die 'usage: optify on|off|show|before|after|clear-shots' }
    }
}

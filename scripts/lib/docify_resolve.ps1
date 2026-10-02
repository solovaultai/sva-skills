# sva-skills docify defaults — scratch, format, path, prefix.
# Dot-sourced by cli.ps1. Uses Die and Write-Out.
#
# Config: %LOCALAPPDATA%\sva-skills\docify.env

function Get-DocifyConfigPath {
    if ($env:LOCALAPPDATA) {
        return (Join-Path (Join-Path $env:LOCALAPPDATA 'sva-skills') 'docify.env')
    }
    if ($env:XDG_DATA_HOME) {
        return (Join-Path (Join-Path $env:XDG_DATA_HOME 'sva-skills') 'docify.env')
    }
    return (Join-Path (Join-Path (Join-Path $HOME '.local') 'share') (Join-Path 'sva-skills' 'docify.env'))
}

function Reset-DocifyState {
    $script:DocifyScratch = ''
    $script:DocifyFormat = ''
    $script:DocifyPath = ''
    $script:DocifyPrefix = ''
}

function Read-DocifyEnv {
    Reset-DocifyState
    $cfg = Get-DocifyConfigPath
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
            'scratch' { $script:DocifyScratch = $val }
            'format' { $script:DocifyFormat = $val }
            'path' { $script:DocifyPath = $val }
            'prefix' { $script:DocifyPrefix = $val }
        }
    }
}

function Write-DocifyEnv {
    $cfg = Get-DocifyConfigPath
    $dir = Split-Path -Parent $cfg
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $lines = @(
        '# sva-skills docify defaults'
        "scratch=$($script:DocifyScratch)"
        "format=$($script:DocifyFormat)"
        "path=$($script:DocifyPath)"
        "prefix=$($script:DocifyPrefix)"
    )
    $tmp = Join-Path $dir ('.docify.env.{0}' -f [guid]::NewGuid().ToString('N').Substring(0, 8))
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($tmp, $lines, $utf8)
    Move-Item -LiteralPath $tmp -Destination $cfg -Force
    try {
        icacls $cfg /inheritance:r /grant:r "${env:USERNAME}:R" | Out-Null
    }
    catch {
        # Best-effort private file; chmod 600 equivalent is not always available.
    }
}

function Show-DocifyEnv {
    Read-DocifyEnv
    Write-Out "config: $(Get-DocifyConfigPath)"
    Write-Out "scratch: $($script:DocifyScratch)"
    Write-Out "format: $($script:DocifyFormat)"
    Write-Out "path: $($script:DocifyPath)"
    Write-Out "prefix: $($script:DocifyPrefix)"
}

function ConvertTo-DocifyFormat {
    param([string]$Token)
    switch ($Token.ToLowerInvariant()) {
        { $_ -eq 'md' -or $_ -eq 'markdown' } { return 'md' }
        { $_ -eq 'txt' -or $_ -eq 'text' } { return 'txt' }
        { $_ -eq 'word' -or $_ -eq 'docx' } { return 'docx' }
        'html' { return 'html' }
        default { return $null }
    }
}

function Test-DocifyFormatAlias {
    param([string]$Token)
    $low = $Token.ToLowerInvariant()
    return @('format', 'md', 'markdown', 'txt', 'text', 'word', 'docx', 'html') -contains $low
}

function Show-DocifyUsage {
    $cfg = Get-DocifyConfigPath
    Write-Out @"
Usage:
  .\scripts\cli.ps1 docify show
  .\scripts\cli.ps1 docify set scratch
  .\scripts\cli.ps1 docify set format md|txt|docx|html
  .\scripts\cli.ps1 docify set path <dir>
  .\scripts\cli.ps1 docify set prefix <text>
  .\scripts\cli.ps1 docify clear scratch|format|path|prefix

Config: $cfg
Keys: scratch, format, path, prefix.
A format alias (md, markdown, txt, text, word, docx, html) clears format only.
docif and scrach are not keys.
"@
}

function Set-DocifyKey {
    param([string[]]$KeyArgs)
    if ($null -eq $KeyArgs -or $KeyArgs.Count -lt 1 -or [string]::IsNullOrEmpty($KeyArgs[0])) {
        Die 'usage: docify set scratch|format|path|prefix'
    }
    $key = $KeyArgs[0]
    $low = $key.ToLowerInvariant()
    $rest = @()
    if ($KeyArgs.Count -gt 1) {
        $rest = @($KeyArgs[1..($KeyArgs.Count - 1)])
    }
    if ($low -eq 'docif' -or $low -eq 'scrach') {
        Die "unknown docify key: $key"
    }
    switch ($low) {
        'scratch' {
            if ($rest.Count -gt 1 -or ($rest.Count -eq 1 -and $rest[0] -ne '1')) {
                Die 'usage: docify set scratch'
            }
        }
        'format' {
            if ($rest.Count -ne 1) {
                Die 'usage: docify set format md|txt|docx|html'
            }
            if ($null -eq (ConvertTo-DocifyFormat $rest[0])) {
                Die "unknown docify format: $($rest[0])"
            }
        }
        'path' {
            if ($rest.Count -ne 1 -or [string]::IsNullOrEmpty($rest[0])) {
                Die 'usage: docify set path <dir>'
            }
        }
        'prefix' {
            if ($rest.Count -ne 1) {
                Die 'usage: docify set prefix <text>'
            }
        }
        default {
            Die "unknown docify key: $key (try: scratch, format, path, prefix)"
        }
    }
    Read-DocifyEnv
    switch ($low) {
        'scratch' { $script:DocifyScratch = '1' }
        'format' { $script:DocifyFormat = (ConvertTo-DocifyFormat $rest[0]) }
        'path' { $script:DocifyPath = $rest[0] }
        'prefix' { $script:DocifyPrefix = $rest[0] }
    }
    Write-DocifyEnv
    Show-DocifyEnv
}

function Clear-DocifyKey {
    param([string[]]$KeyArgs)
    if ($null -eq $KeyArgs -or $KeyArgs.Count -ne 1 -or [string]::IsNullOrEmpty($KeyArgs[0])) {
        Die 'usage: docify clear scratch|format|path|prefix'
    }
    $key = $KeyArgs[0]
    $low = $key.ToLowerInvariant()
    if ($low -eq 'docif' -or $low -eq 'scrach') {
        Die "unknown docify key: $key"
    }
    $ok = $low -eq 'scratch' -or $low -eq 'path' -or $low -eq 'prefix' -or $low -eq 'clearprefix' -or (Test-DocifyFormatAlias $low)
    if (-not $ok) {
        Die "unknown docify key: $key (try: scratch, format, path, prefix)"
    }
    Read-DocifyEnv
    switch ($low) {
        'scratch' { $script:DocifyScratch = '' }
        'path' { $script:DocifyPath = '' }
        { $_ -eq 'prefix' -or $_ -eq 'clearprefix' } { $script:DocifyPrefix = '' }
        default { $script:DocifyFormat = '' }
    }
    Write-DocifyEnv
    Show-DocifyEnv
}

function Invoke-DocifyCommand {
    param([string[]]$DocifyArgs)
    if ($null -eq $DocifyArgs) {
        $DocifyArgs = @()
    }
    $sub = if ($DocifyArgs.Count -gt 0) { $DocifyArgs[0] } else { '' }
    $rest = if ($DocifyArgs.Count -gt 1) { @($DocifyArgs[1..($DocifyArgs.Count - 1)]) } else { @() }
    $low = $sub.ToLowerInvariant()
    if ($low -eq '' -or $low -eq '-h' -or $low -eq '--help' -or $low -eq 'help') {
        Show-DocifyUsage
        return
    }
    if ($low -eq 'docif' -or $low -eq 'scrach') {
        Die "unknown docify command: $sub (try: show, set, clear)"
    }
    switch ($low) {
        'show' { Show-DocifyEnv }
        'set' { Set-DocifyKey -KeyArgs $rest }
        'clear' { Clear-DocifyKey -KeyArgs $rest }
        default { Die "unknown docify command: $sub (try: show, set, clear)" }
    }
}

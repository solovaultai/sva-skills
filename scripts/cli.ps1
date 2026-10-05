#Requires -Version 5.1
<#
.SYNOPSIS
  sva-skills installer — sync repo skills into ~/.grok, ~/.cursor,
  and ~/.copilot (local and/or across sshub connections from connections.env)

.DESCRIPTION
  Windows 10/11 port of scripts/cli.sh. Requires Windows PowerShell 5.1
  (preinstalled) or PowerShell 7+. Remote install uses the built-in
  OpenSSH client (ssh.exe / scp.exe).

.EXAMPLE
  .\scripts\cli.ps1 install
  .\scripts\cli.ps1 install grok
  .\scripts\cli.ps1 install copilot
  .\scripts\cli.ps1 project C:\path\to\consumer-repo
  .\scripts\cli.ps1 pullinst
  .\scripts\cli.ps1 pullinst grok
  .\scripts\cli.ps1 pullinst copilot
  .\scripts\cli.ps1 install --remote casai
  .\scripts\cli.ps1 status --remote
  .\scripts\cli.ps1 list
  .\scripts\cli.ps1 scratch show
  .\scripts\cli.ps1 scratch ls 3
  .\scripts\cli.ps1 docify show
  .\scripts\cli.ps1 saveify dir
#>
# Do not use [CmdletBinding()]/param() — bash-style --force/--remote must
# reach the manual parser instead of PowerShell parameter binding.
$CliArgs = @()
if ($null -ne $args -and $args.Count -gt 0) {
    $CliArgs = @($args | ForEach-Object { [string]$_ })
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── paths ─────────────────────────────────────────────────────

$Root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path

$GrokSrc = Join-Path $Root '.grok'
$CursorSrc = Join-Path (Join-Path $Root '.cursor') 'skills'
$CopilotSrc = Join-Path (Join-Path $Root '.copilot') 'skills'
$GrokDest = Join-Path (Join-Path $HOME '.grok') 'skills'
$CursorDest = Join-Path (Join-Path $HOME '.cursor') 'skills'
$CopilotDest = Join-Path (Join-Path $HOME '.copilot') 'skills'

# Remote destinations are always under the remote user's home (Linux hosts).
$RemoteGrokRel = '.grok/skills'
$RemoteCursorRel = '.cursor/skills'
$RemoteCopilotRel = '.copilot/skills'
# Consumer-repo cloud dest (I6). Not a source tree; not written inside this repo.
$ProjectRel = '.github/skills'

if ($env:SSHUB_DATA_DIR) {
    $SshubDataDir = $env:SSHUB_DATA_DIR
}
elseif ($env:XDG_DATA_HOME) {
    $SshubDataDir = Join-Path $env:XDG_DATA_HOME 'sshub'
}
else {
    $SshubDataDir = Join-Path $HOME '.local\share\sshub'
}

if ($env:SSHUB_ENV_FILE) {
    $EnvFile = $env:SSHUB_ENV_FILE
}
else {
    $EnvFile = Join-Path $SshubDataDir 'connections.env'
}

$Force = $false
$DryRun = $false
# ask = prompt on a TTY when GitHub Copilot (the product) is missing
# yes  = --host; no = --no-host
$HostAction = 'ask'
$DoRemote = $false
$DoLocal = $true   # default local; flipped off when --remote is used without --local
$LocalExplicit = $false
$SshubLoaded = $false

$SshubVars = $null          # hashtable NAME_KEY -> value
$SshubNames = $null         # ordered connection names
$ResolvedName = $null
$ResolvedUser = $null
$ResolvedHost = $null
$ResolvedPort = $null
$ResolvedKey = $null
$ResolvedFolder = $null
$RemoteMtime = $null        # hashtable skill -> epoch seconds

$SshExe = $null
$ScpExe = $null

# ── output helpers ────────────────────────────────────────────

function Write-Out {
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Message = ''
    )
    process {
        [Console]::Out.WriteLine($Message)
    }
}

function Write-ErrLine {
    param([string]$Message)
    [Console]::Error.WriteLine($Message)
}

function Die {
    param([string]$Message)
    Write-ErrLine "error: $Message"
    exit 1
}

# Always run against this repo ($Root), not the caller's cwd.
function Invoke-GitPullMain {
    Write-Out "git pull origin main  ($script:Root)"
    & git -C $script:Root pull origin main
    if ($LASTEXITCODE -ne 0) {
        Die 'git pull origin main failed; install skipped'
    }
}

function Show-Usage {
    $text = @'
sva-skills installer — sync repo skills into ~/.grok, ~/.cursor, and ~/.copilot

Usage:
  .\scripts\cli.ps1 install              # same as: install all (local)
  .\scripts\cli.ps1 install all
  .\scripts\cli.ps1 install grok
  .\scripts\cli.ps1 install cursor
  .\scripts\cli.ps1 install copilot
  .\scripts\cli.ps1 project C:\path\to\repo  # .copilot\skills → <repo>\.github\skills
  .\scripts\cli.ps1 project --dry-run C:\path\to\repo
  .\scripts\cli.ps1 pullinst              # git pull origin main, then install
  .\scripts\cli.ps1 pullinst grok
  .\scripts\cli.ps1 pullinst cursor
  .\scripts\cli.ps1 pullinst copilot
  .\scripts\cli.ps1 install --remote                 # all skills → all connections
  .\scripts\cli.ps1 install grok --remote casai      # name or alias from connections.env
  .\scripts\cli.ps1 install --remote casai CAS2SYS
  .\scripts\cli.ps1 install --local --remote         # local + every connection
  .\scripts\cli.ps1 status
  .\scripts\cli.ps1 status --remote [conn...]
  .\scripts\cli.ps1 list                             # list sshub connections
  .\scripts\cli.ps1 scratch show                     # screenshot folder for ify Nimages / Grok /image
  .\scripts\cli.ps1 scratch ls [N]                   # last-N image paths (default 5)
  .\scripts\cli.ps1 docify show                      # docify defaults (scratch, format, path, prefix)
  .\scripts\cli.ps1 saveify dir                      # saveify snapshot store

Options:
  --force       Always install, even if dest is newer
  --dry-run     Print actions only; do not write
  --host        Install GitHub Copilot (VS Code + CLI when possible) without asking
  --no-host     Do not install the GitHub Copilot product
  --remote, -r  Install to remote host(s); with no names, use all connections
  --local       Also install on this machine when using --remote
  --list, -l    List sshub connections and exit
  -h, --help    Show help

Targets:
  grok     .grok\<skill>\           →  ~\.grok\skills\<skill>\
  cursor   .cursor\skills\<skill>\  →  ~\.cursor\skills\<skill>\
  copilot  .copilot\skills\<skill>\ →  ~\.copilot\skills\<skill>\
  all      grok + cursor + copilot (default when target omitted)

Project / cloud (copilot only; I6 — not a fourth install target):
  project  .copilot\skills\<skill>\ →  <consumer-repo>\.github\skills\<skill>\
  Refuses to write .github\skills inside this sva-skills repo (source stays
  .copilot\skills). Path omitted → current working directory. See
  docs/COPILOT_LOAD.md for gh skill install and /skills reload.

Connections come from:
  ~\.local\share\sshub\connections.env
(override with SSHUB_ENV_FILE / SSHUB_DATA_DIR). Names and aliases work
the same as sshub / sshot (e.g. casai, CASSADYAIFAP).

Remote install uses Windows OpenSSH (ssh.exe / scp.exe). Skills land in
the remote user's home (~/.grok/skills, ~/.cursor/skills,
~/.copilot/skills when the copilot target is selected).

A skill is installed when the destination is missing, or when any file under
the repo skill is newer than the newest file under the installed skill.
With --force, every skill is reinstalled regardless of mtimes.

Scratch source (ify Nimages and Grok /image last-N images):
  .\scripts\cli.ps1 scratch show                     # current source; unset is OK (skills use workspace scratch/)
  .\scripts\cli.ps1 scratch set <path>
  .\scripts\cli.ps1 scratch set --remote <conn> <dir>
  .\scripts\cli.ps1 scratch search [--remote <conn>]
  .\scripts\cli.ps1 scratch detect [--force]
  .\scripts\cli.ps1 scratch ls [N]
Config: %LOCALAPPDATA%\sva-skills\scratch.env
Install detects the screenshot folder and writes that file if unset.

Docify defaults (typed-line docify / docpathify):
  .\scripts\cli.ps1 docify show
  .\scripts\cli.ps1 docify set scratch
  .\scripts\cli.ps1 docify set format md|txt|docx|html
  .\scripts\cli.ps1 docify set path <dir>
  .\scripts\cli.ps1 docify set prefix <text>
  .\scripts\cli.ps1 docify clear scratch|format|path|prefix
Config: %LOCALAPPDATA%\sva-skills\docify.env
Keys: scratch, format, path, prefix. docif and scrach are not keys.

Saveify snapshots (see docs/saveify_contract.md):
  .\scripts\cli.ps1 saveify dir
  .\scripts\cli.ps1 saveify ls
  .\scripts\cli.ps1 saveify resolve <slug>
  .\scripts\cli.ps1 saveify rm <slug> --yes
Store: %LOCALAPPDATA%\sva-skills\saveify
ls is newest first (1 = newest), tab-separated:
  <n> <saved_at> <slug> <display_name> <verb> <stage> <cwd>
resolve takes a slug, not a list number or a display name.
rm refuses unless --yes. It does not prompt.
'@
    Write-Out $text
}

# ── sshub connections.env (native parse; no bash sshub) ───────

function Expand-SshubValue {
    param([string]$Value)
    if ([string]::IsNullOrEmpty($Value)) {
        return $Value
    }
    $homePath = $HOME
    $Value = [regex]::Replace($Value, '\$\{HOME\}', { param($m) $homePath })
    $Value = [regex]::Replace($Value, '\$HOME(?![A-Za-z0-9_])', { param($m) $homePath })
    if ($Value -eq '~') {
        return $homePath
    }
    if ($Value.StartsWith('~/') -or $Value.StartsWith('~\')) {
        return (Join-Path $homePath $Value.Substring(2))
    }
    return $Value
}

function Import-SshubEnv {
    if ($script:SshubLoaded) {
        return
    }
    if (-not (Test-Path -LiteralPath $script:EnvFile -PathType Leaf)) {
        Die "connections file not found: $($script:EnvFile)"
    }

    $script:SshubVars = @{}
    $script:SshubNames = New-Object System.Collections.Generic.List[string]

    foreach ($raw in Get-Content -LiteralPath $script:EnvFile -Encoding UTF8) {
        $line = $raw.Trim()
        if ($line -eq '' -or $line.StartsWith('#')) {
            continue
        }
        if ($line.StartsWith('export ')) {
            $line = $line.Substring(7).Trim()
        }
        if ($line -notmatch '^([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
            continue
        }
        $key = $Matches[1]
        $val = $Matches[2]
        if ($val.Length -ge 2) {
            $q = $val[0]
            if (($q -eq [char]34 -or $q -eq [char]39) -and $val[-1] -eq $q) {
                $val = $val.Substring(1, $val.Length - 2)
            }
        }
        $script:SshubVars[$key] = (Expand-SshubValue $val)
        if ($key.EndsWith('_HOST') -and $key.Length -gt 5) {
            $name = $key.Substring(0, $key.Length - 5)
            if (-not $script:SshubNames.Contains($name)) {
                [void]$script:SshubNames.Add($name)
            }
        }
    }
    $script:SshubLoaded = $true
}

function Get-SshubVar {
    param(
        [string]$Name,
        [string]$Suffix,
        [string]$Default = ''
    )
    $key = "${Name}_${Suffix}"
    if ($script:SshubVars.ContainsKey($key)) {
        return [string]$script:SshubVars[$key]
    }
    return $Default
}

function Get-SshubConnectionNames {
    Import-SshubEnv
    return @($script:SshubNames)
}

function Resolve-SshubConnection {
    param([string]$InputToken)
    Import-SshubEnv

    $found = $null
    $aliasUpper = $InputToken.ToUpperInvariant()
    foreach ($name in $script:SshubNames) {
        $aliasVal = Get-SshubVar $name 'ALIAS'
        if ($aliasVal -and $aliasVal.ToUpperInvariant() -eq $aliasUpper) {
            $found = $name
            break
        }
    }
    if ($found) {
        $script:ResolvedName = $found
    }
    else {
        $script:ResolvedName = $InputToken.ToUpperInvariant()
    }

    $hostVal = Get-SshubVar $script:ResolvedName 'HOST'
    if ([string]::IsNullOrEmpty($hostVal)) {
        return $false
    }

    $script:ResolvedUser = Get-SshubVar $script:ResolvedName 'USER'
    $script:ResolvedHost = $hostVal
    $script:ResolvedPort = Get-SshubVar $script:ResolvedName 'PORT' '22'
    if ([string]::IsNullOrEmpty($script:ResolvedPort)) {
        $script:ResolvedPort = '22'
    }
    $script:ResolvedKey = Get-SshubVar $script:ResolvedName 'KEY'
    $script:ResolvedFolder = Get-SshubVar $script:ResolvedName 'FOLDER'
    return $true
}

function Show-SshubConnections {
    Import-SshubEnv
    $names = @(Get-SshubConnectionNames)
    Write-Out "Connections in $($script:EnvFile):"
    if ($names.Count -eq 0) {
        Write-Out '  (none)'
        return
    }
    foreach ($n in $names) {
        $alias = Get-SshubVar $n 'ALIAS'
        $hostVal = Get-SshubVar $n 'HOST'
        $folder = Get-SshubVar $n 'FOLDER'
        if ($alias) {
            $line = ('  {0,-16}  alias={1,-10}  {2}' -f $n, $alias, $hostVal)
        }
        else {
            $line = ('  {0,-16}  {1}' -f $n, $hostVal)
        }
        if ($folder) {
            $line = "$line  (folder: $folder)"
        }
        Write-Out $line
    }
}

function Resolve-RemoteList {
    param([string[]]$Tokens)
    Import-SshubEnv
    $resolved = New-Object System.Collections.Generic.List[string]

    if ($null -eq $Tokens -or $Tokens.Count -eq 0) {
        $all = @(Get-SshubConnectionNames)
        if ($all.Count -eq 0) {
            Die "no connections defined in $($script:EnvFile)"
        }
        return @($all)
    }

    foreach ($token in $Tokens) {
        foreach ($part in ($token -split ',')) {
            $part = $part.Trim()
            if (-not $part) {
                continue
            }
            if (-not (Resolve-SshubConnection $part)) {
                Die "unknown connection: $part"
            }
            [void]$resolved.Add($script:ResolvedName)
        }
    }
    if ($resolved.Count -eq 0) {
        Die 'no remote connections selected'
    }
    return @($resolved)
}

# ── OpenSSH ───────────────────────────────────────────────────

function Resolve-OpenSshExe {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) {
        return $cmd.Source
    }
    $bundled = Join-Path $env:WINDIR "System32\OpenSSH\$Name.exe"
    if (Test-Path -LiteralPath $bundled -PathType Leaf) {
        return $bundled
    }
    return $null
}

function Ensure-OpenSsh {
    if ($script:SshExe -and $script:ScpExe) {
        return
    }
    $script:SshExe = Resolve-OpenSshExe 'ssh'
    $script:ScpExe = Resolve-OpenSshExe 'scp'
    if (-not $script:SshExe -or -not $script:ScpExe) {
        Die @'
OpenSSH client not found (ssh.exe / scp.exe). On Windows 10/11 install it with:
  Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
or: Settings → Apps → Optional features → OpenSSH Client
'@
    }
}

function ConvertTo-BashSingleQuoted {
    param([string]$Value)
    $escaped = $Value -replace "'", "'\''"
    return "'$escaped'"
}

function Get-SshCommonArgs {
    param([switch]$ForScp)
    $list = New-Object System.Collections.Generic.List[string]
    [void]$list.Add('-o'); [void]$list.Add('BatchMode=yes')
    [void]$list.Add('-o'); [void]$list.Add('StrictHostKeyChecking=accept-new')
    [void]$list.Add('-o'); [void]$list.Add('ConnectTimeout=8')
    if (-not $ForScp) {
        [void]$list.Add('-o'); [void]$list.Add('ConnectionAttempts=1')
        [void]$list.Add('-p'); [void]$list.Add([string]$script:ResolvedPort)
    }
    else {
        [void]$list.Add('-P'); [void]$list.Add([string]$script:ResolvedPort)
    }
    if ($script:ResolvedKey) {
        [void]$list.Add('-i'); [void]$list.Add($script:ResolvedKey)
    }
    return @($list)
}

function Invoke-RemoteSsh {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RemoteCommand,
        [string]$Stdin
    )
    Ensure-OpenSsh
    $sshArgs = @(Get-SshCommonArgs)
    $sshArgs += "$($script:ResolvedUser)@$($script:ResolvedHost)"
    $sshArgs += $RemoteCommand

    # Capture stdout only (mtime lines). Let ssh stderr pass through like cli.sh.
    $output = $null
    if ($PSBoundParameters.ContainsKey('Stdin')) {
        $output = $Stdin | & $script:SshExe @sshArgs
    }
    else {
        $output = & $script:SshExe @sshArgs
    }
    $rc = $LASTEXITCODE
    return @{
        ExitCode = $rc
        Output   = $output
    }
}

# ── mtime / skill helpers ─────────────────────────────────────

function Get-NewestMtime {
    param([string]$Dir)
    if (-not (Test-Path -LiteralPath $Dir -PathType Container)) {
        return [int64]0
    }
    $files = @(Get-ChildItem -LiteralPath $Dir -Recurse -File -Force -ErrorAction SilentlyContinue)
    if ($files.Count -eq 0) {
        return [int64]0
    }
    $newest = $files | Sort-Object LastWriteTimeUtc | Select-Object -Last 1
    return [int64]([DateTimeOffset]$newest.LastWriteTimeUtc).ToUnixTimeSeconds()
}

function Get-RemoteSkillMtimes {
    param(
        [string]$RelParent,
        [string[]]$Names
    )
    $script:RemoteMtime = @{}
    if ($null -eq $Names -or $Names.Count -eq 0) {
        return $true
    }

    $namesQ = ($Names | ForEach-Object { ' ' + (ConvertTo-BashSingleQuoted $_) }) -join ''
    $qParent = ConvertTo-BashSingleQuoted $RelParent
    $remote = @"
set +e
parent="`$HOME"/$qParent
for name in$namesQ; do
  d="`$parent/`$name"
  if [ ! -d "`$d" ]; then
    printf '%s 0\n' "`$name"
    continue
  fi
  ts=`$(find "`$d" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
  if [ -z "`${ts:-}" ]; then
    printf '%s 0\n' "`$name"
  else
    printf '%s %s\n' "`$name" "`${ts%%.*}"
  fi
done
"@

    $result = Invoke-RemoteSsh -RemoteCommand 'bash -s' -Stdin $remote
    if ($result.ExitCode -ne 0) {
        return $false
    }

    $text = if ($null -eq $result.Output) { '' } else { ($result.Output | ForEach-Object { "$_" }) -join "`n" }
    foreach ($line in ($text -split '\r?\n')) {
        if (-not $line.Trim()) {
            continue
        }
        $skill, $ts = ($line.Trim() -split '\s+', 2)
        if ($ts -notmatch '^\d+$') {
            $ts = '0'
        }
        $script:RemoteMtime[$skill] = [int64]$ts
    }
    foreach ($n in $Names) {
        if (-not $script:RemoteMtime.ContainsKey($n)) {
            $script:RemoteMtime[$n] = [int64]0
        }
    }
    return $true
}

function Get-SkillDirs {
    param([string]$Src)
    $names = New-Object System.Collections.Generic.List[string]
    if (-not (Test-Path -LiteralPath $Src -PathType Container)) {
        return @()
    }
    $dirs = @(Get-ChildItem -LiteralPath $Src -Directory -ErrorAction SilentlyContinue | Sort-Object Name)
    foreach ($d in $dirs) {
        if ($d.Name.StartsWith('.')) {
            continue
        }
        $skillMd = Join-Path $d.FullName 'SKILL.md'
        $include = Test-Path -LiteralPath $skillMd -PathType Leaf
        if (-not $include) {
            $any = Get-ChildItem -LiteralPath $d.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
                Select-Object -First 1
            $include = $null -ne $any
        }
        if ($include) {
            [void]$names.Add($d.Name)
        }
    }
    return @($names)
}

function Test-ShouldInstallTs {
    param([int64]$SrcTs, [int64]$DestTs)
    if ($script:Force) {
        return $true
    }
    if ($DestTs -eq 0) {
        return $true
    }
    return ($SrcTs -gt $DestTs)
}

function Get-ReasonForTs {
    param([int64]$SrcTs, [int64]$DestTs)
    if ($script:Force) {
        return 'forced'
    }
    if ($DestTs -eq 0) {
        return 'new'
    }
    if ($SrcTs -gt $DestTs) {
        return 'newer'
    }
    if ($SrcTs -eq $DestTs) {
        return 'same age'
    }
    return 'dest newer'
}

# ── local install ─────────────────────────────────────────────

function Invoke-RobocopyContents {
    param([string]$From, [string]$To)
    $robocopy = Join-Path $env:WINDIR 'System32\robocopy.exe'
    if (-not (Test-Path -LiteralPath $robocopy -PathType Leaf)) {
        Die "robocopy not found at $robocopy"
    }
    $roboArgs = @(
        $From, $To,
        '/E',
        '/COPY:DAT',
        '/R:1', '/W:1',
        '/NFL', '/NDL', '/NJH', '/NJS', '/NC', '/NS', '/NP'
    )
    & $robocopy @roboArgs | Out-Null
    return [int]$LASTEXITCODE
}

function Install-SkillLocal {
    param(
        [string]$Name,
        [string]$Src,
        [string]$DestParent
    )
    $dest = Join-Path $DestParent $Name
    $srcTs = Get-NewestMtime $Src
    $destTs = Get-NewestMtime $dest
    if (-not (Test-ShouldInstallTs $srcTs $destTs)) {
        Write-Out ("  skip  {0}  ({1})" -f $Name, (Get-ReasonForTs $srcTs $destTs))
        return
    }
    $why = Get-ReasonForTs $srcTs $destTs
    if ($script:DryRun) {
        Write-Out ("  would install  {0}  ({1})  →  {2}" -f $Name, $why, $dest)
        return
    }

    if (-not (Test-Path -LiteralPath $DestParent -PathType Container)) {
        New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
    }
    $suffix = [guid]::NewGuid().ToString('N').Substring(0, 8)
    $staging = Join-Path $DestParent (".sva-skills-staging.{0}.{1}" -f $Name, $suffix)
    New-Item -ItemType Directory -Path $staging -Force | Out-Null
    $rc = Invoke-RobocopyContents -From $Src -To $staging
    if ($rc -ge 8) {
        Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue
        Die "copy failed for skill: $Name"
    }
    if (Test-Path -LiteralPath $dest) {
        Remove-Item -LiteralPath $dest -Recurse -Force
    }
    Move-Item -LiteralPath $staging -Destination $dest
    Write-Out ("  install  {0}  ({1})  →  {2}" -f $Name, $why, $dest)
}

function Get-TargetPaths {
    param([string]$Target)
    switch ($Target) {
        'grok' {
            return @{
                Src   = $script:GrokSrc
                Dest  = $script:GrokDest
                Rel   = $script:RemoteGrokRel
                Label = 'grok'
            }
        }
        'cursor' {
            return @{
                Src   = $script:CursorSrc
                Dest  = $script:CursorDest
                Rel   = $script:RemoteCursorRel
                Label = 'cursor'
            }
        }
        'copilot' {
            return @{
                Src   = $script:CopilotSrc
                Dest  = $script:CopilotDest
                Rel   = $script:RemoteCopilotRel
                Label = 'copilot'
            }
        }
        default {
            Die "unknown target: $Target (use grok, cursor, copilot, or all)"
        }
    }
}

function Install-TargetLocal {
    param([string]$Target)
    $info = Get-TargetPaths $Target
    if (-not (Test-Path -LiteralPath $info.Src -PathType Container)) {
        Die "source not found: $($info.Src)"
    }
    $skills = @(Get-SkillDirs $info.Src)
    if ($skills.Count -eq 0) {
        Write-Out ("{0}: no skills under {1}" -f $info.Label, $info.Src)
        return
    }
    Write-Out ("local {0}: {1}  →  {2}" -f $info.Label, $info.Src, $info.Dest)
    foreach ($name in $skills) {
        Install-SkillLocal $name (Join-Path $info.Src $name) $info.Dest
    }
}

function Get-CodeBin {
    $cmd = Get-Command code -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $cmd = Get-Command code-insiders -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $win = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'
    if (Test-Path -LiteralPath $win) { return $win }
    return $null
}

function Test-CopilotCliPresent {
    return [bool](Get-Command copilot -ErrorAction SilentlyContinue)
}

function Get-VscodeAppRoot {
    $bin = Get-CodeBin
    if ($bin) {
        $dir = Split-Path -Parent $bin
        if ((Split-Path -Leaf $dir) -eq 'bin') {
            $root = Split-Path -Parent $dir
            $pkg = Join-Path $root 'resources\app\extensions\copilot\package.json'
            if (Test-Path -LiteralPath $pkg) { return $root }
        }
    }
    $candidates = @(
        'C:\Program Files\Microsoft VS Code',
        (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code')
    )
    foreach ($root in $candidates) {
        $pkg = Join-Path $root 'resources\app\extensions\copilot\package.json'
        if (Test-Path -LiteralPath $pkg) { return $root }
    }
    return $null
}

function Test-CopilotVscodeBuiltin {
    $root = Get-VscodeAppRoot
    if (-not $root) { return $false }
    return (Test-Path -LiteralPath (Join-Path $root 'resources\app\extensions\copilot\package.json'))
}

function Test-CopilotVscodeUserExt {
    $bin = Get-CodeBin
    if (-not $bin) { return $false }
    $exts = @(& $bin --list-extensions 2>$null)
    return [bool]($exts | Where-Object { $_ -ieq 'GitHub.copilot' })
}

function Test-CopilotVscodePresent {
    return (Test-CopilotVscodeUserExt) -or (Test-CopilotVscodeBuiltin)
}

function Test-CopilotHostPresent {
    return (Test-CopilotVscodePresent) -or (Test-CopilotCliPresent)
}

function Test-CopilotVscodeInstallable {
    return [bool](Get-CodeBin)
}

function Test-CopilotCliInstallable {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { return $false }
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) { return $false }
    try {
        $major = [int](& node -p "process.versions.node.split('.')[0]" 2>$null)
        return $major -ge 22
    }
    catch {
        return $false
    }
}

function Test-CopilotHostInstallable {
    return (Test-CopilotVscodeInstallable) -or (Test-CopilotCliInstallable)
}

function Install-CopilotVscode {
    $bin = Get-CodeBin
    if (-not $bin) { return $false }
    if (Test-CopilotVscodeBuiltin) {
        Write-Out '  skip  GitHub.copilot  (built into this VS Code; Chat cannot be marketplace-downgraded)'
        return $true
    }
    if (-not $script:Force -and (Test-CopilotVscodeUserExt)) {
        Write-Out '  skip  GitHub.copilot  (already installed)'
        return $true
    }
    if ($script:DryRun) {
        Write-Out ("  would install  GitHub.copilot  via {0}" -f $bin)
        return $true
    }
    $args = @('--install-extension', 'GitHub.copilot')
    if ($script:Force) { $args += '--force' }
    $err = & $bin @args 2>&1 | Out-String
    Write-Out $err.TrimEnd()
    if (Test-CopilotVscodePresent) {
        Write-Out '  install  GitHub.copilot'
        return $true
    }
    if ($err -match 'cannot be downgraded|is a built-in extension') {
        Write-Out '  skip  GitHub.copilot-chat  (built into this VS Code)'
        Write-Out '  note: VS Code already has Copilot Chat built in; marketplace GitHub.copilot was not added'
        return $true
    }
    Write-ErrLine '  error: failed to install GitHub.copilot'
    return $false
}

function Install-CopilotCli {
    if (Test-CopilotCliPresent) {
        Write-Out '  skip  copilot CLI  (already on PATH)'
        return $true
    }
    if (-not (Test-CopilotCliInstallable)) { return $false }
    $prefix = Join-Path $HOME '.local'
    if ($script:DryRun) {
        Write-Out ("  would install  @github/copilot  →  {0}" -f $prefix)
        return $true
    }
    $binDir = Join-Path $prefix 'bin'
    if (-not (Test-Path -LiteralPath $binDir)) {
        New-Item -ItemType Directory -Path $binDir -Force | Out-Null
    }
    & npm install -g --prefix $prefix @github/copilot
    if ($LASTEXITCODE -ne 0) {
        Write-ErrLine ("  error: npm install -g --prefix {0} @github/copilot failed" -f $prefix)
        return $false
    }
    Write-Out ("  install  copilot CLI  →  {0}\copilot" -f $binDir)
    if (-not (Get-Command copilot -ErrorAction SilentlyContinue)) {
        Write-Out ("  note: add {0} to PATH if 'copilot' is not found" -f $binDir)
    }
    return $true
}

function Test-InstallerTty {
    try {
        return -not [Console]::IsInputRedirected
    }
    catch {
        return $false
    }
}

function Request-CopilotHostInstall {
    if ($script:HostAction -eq 'yes') { return $true }
    if ($script:HostAction -eq 'no') { return $false }
    if (-not (Test-InstallerTty)) {
        Write-Out 'host: GitHub Copilot is installable but not installed.'
        Write-Out '  re-run with --host to install it, or --no-host to skip asking.'
        return $false
    }
    if ((Test-CopilotVscodePresent) -and -not (Test-CopilotCliPresent)) {
        Write-Host -NoNewline 'VS Code already has GitHub Copilot built in. Install Copilot CLI too? [y/N] '
    }
    else {
        Write-Host -NoNewline 'GitHub Copilot is not installed. Install the VS Code host (if needed) and Copilot CLI if possible? [y/N] '
    }
    $reply = [Console]::In.ReadLine()
    if ($null -eq $reply) { return $false }
    return ($reply -match '^(?i)(y|yes)$')
}

function Invoke-MaybeInstallCopilotHost {
    Write-Out 'host: GitHub Copilot (product — VS Code built-in/extension and/or Copilot CLI)'
    if ((Test-CopilotVscodePresent) -and (Test-CopilotCliPresent)) {
        Write-Out '  already installed (VS Code + CLI)'
        return
    }
    if ((Test-CopilotVscodePresent) -and -not (Test-CopilotCliInstallable)) {
        Write-Out '  already installed (VS Code)'
        return
    }
    if (-not (Test-CopilotVscodePresent) -and -not (Test-CopilotCliPresent) -and -not (Test-CopilotHostInstallable)) {
        Write-Out "  not installed and not installable here (need 'code' and/or Node 22+ npm)"
        return
    }
    if (-not (Request-CopilotHostInstall)) {
        Write-Out ("  skip  product (skills will still be copied to {0})" -f $script:CopilotDest)
        return
    }
    $ok = $false
    if (Test-CopilotVscodeInstallable) {
        if (Install-CopilotVscode) { $ok = $true }
    }
    if (-not (Test-CopilotCliPresent) -and (Test-CopilotCliInstallable)) {
        if (Install-CopilotCli) { $ok = $true }
    }
    if ($ok) {
        Write-Out '  next: sign in to GitHub Copilot, then /skills reload (or copilot skill add)'
    }
}

function Resolve-ProjectRepo {
    param([string]$Raw)
    if ([string]::IsNullOrWhiteSpace($Raw)) {
        $Raw = (Get-Location).Path
    }
    if (-not (Test-Path -LiteralPath $Raw -PathType Container)) {
        Die "consumer repo not found: $Raw"
    }
    $repo = (Resolve-Path -LiteralPath $Raw).Path
    $rootP = (Resolve-Path -LiteralPath $script:Root).Path
    if ([string]::Equals($repo, $rootP, [System.StringComparison]::OrdinalIgnoreCase)) {
        Die 'refusing to write .github/skills inside sva-skills (source is .copilot/skills). Pass a consumer repo path.'
    }
    return $repo
}

function Install-Project {
    param([string[]]$Rest)
    if ($null -eq $Rest) {
        $Rest = @()
    }
    if ($Rest.Count -gt 1) {
        Die ("project takes at most one repo path (got extra: {0})" -f $Rest[1])
    }
    if ($script:DoRemote) {
        Die 'project is local consumer-repo only (I6); do not use --remote'
    }
    if (-not (Test-Path -LiteralPath $script:CopilotSrc -PathType Container)) {
        Die "source not found: $($script:CopilotSrc)"
    }
    $raw = ''
    if ($Rest.Count -ge 1) {
        $raw = $Rest[0]
    }
    $repo = Resolve-ProjectRepo $raw
    $dest = Join-Path $repo $script:ProjectRel
    $skills = @(Get-SkillDirs $script:CopilotSrc)
    if ($skills.Count -eq 0) {
        Write-Out ("project: no skills under {0}" -f $script:CopilotSrc)
        return
    }
    Write-Out ("project copilot: {0}  →  {1}" -f $script:CopilotSrc, $dest)
    foreach ($name in $skills) {
        Install-SkillLocal $name (Join-Path $script:CopilotSrc $name) $dest
    }
}

function Show-TargetStatusLocal {
    param([string]$Target)
    $info = Get-TargetPaths $Target
    Write-Out ("local {0}: {1}  →  {2}" -f $info.Label, $info.Src, $info.Dest)
    if (-not (Test-Path -LiteralPath $info.Src -PathType Container)) {
        Write-Out '  (source missing)'
        return
    }
    foreach ($name in @(Get-SkillDirs $info.Src)) {
        $srcSkill = Join-Path $info.Src $name
        $destSkill = Join-Path $info.Dest $name
        $srcTs = Get-NewestMtime $srcSkill
        $destTs = Get-NewestMtime $destSkill
        $action = if (Test-ShouldInstallTs $srcTs $destTs) { 'INSTALL' } else { 'skip' }
        Write-Out ('  {0,-8}  {1,-20}  {2}' -f $action, $name, (Get-ReasonForTs $srcTs $destTs))
    }
}

# ── remote install ────────────────────────────────────────────

function Install-SkillRemote {
    param(
        [string]$Name,
        [string]$Src,
        [string]$RelParent,
        [string]$ConnLabel
    )
    $srcTs = Get-NewestMtime $Src
    $destTs = [int64]0
    if ($script:RemoteMtime -and $script:RemoteMtime.ContainsKey($Name)) {
        $destTs = [int64]$script:RemoteMtime[$Name]
    }
    if (-not (Test-ShouldInstallTs $srcTs $destTs)) {
        Write-Out ("  skip  {0}  ({1})" -f $Name, (Get-ReasonForTs $srcTs $destTs))
        return $true
    }
    $why = Get-ReasonForTs $srcTs $destTs
    $remoteDest = '{0}@{1}:~/{2}/{3}' -f $script:ResolvedUser, $script:ResolvedHost, $RelParent, $Name
    if ($script:DryRun) {
        Write-Out ("  would install  {0}  ({1})  →  {2}" -f $Name, $why, $remoteDest)
        return $true
    }

    Ensure-OpenSsh
    $qRel = ConvertTo-BashSingleQuoted $RelParent
    $qName = ConvertTo-BashSingleQuoted $Name
    $prep = @"
set -e
parent="`$HOME"/$qRel
mkdir -p "`$parent"
rm -rf "`$parent/.sva-skills-staging."$qName
"@
    $prepResult = Invoke-RemoteSsh -RemoteCommand 'bash -s' -Stdin $prep
    if ($prepResult.ExitCode -ne 0) {
        Write-ErrLine ("  error  {0}  (remote stage prep failed on {1})" -f $Name, $ConnLabel)
        return $false
    }

    $stageRel = "$RelParent/.sva-skills-staging.$Name"
    $scpArgs = @(Get-SshCommonArgs -ForScp)
    $scpArgs += @('-q', '-r', '-p')
    $scpArgs += $Src
    $scpArgs += ('{0}@{1}:{2}' -f $script:ResolvedUser, $script:ResolvedHost, $stageRel)
    & $script:ScpExe @scpArgs | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $qStage = ConvertTo-BashSingleQuoted $stageRel
        $null = Invoke-RemoteSsh -RemoteCommand ('rm -rf "$HOME"/{0}' -f $qStage)
        Write-ErrLine ("  error  {0}  (scp failed → {1})" -f $Name, $ConnLabel)
        return $false
    }

    $swap = @"
set -e
parent="`$HOME"/$qRel
stage="`$parent/.sva-skills-staging."$qName
dest="`$parent/"$qName
if [ -d "`$stage/"$qName ] && [ ! -f "`$stage/SKILL.md" ]; then
  tmp="`$parent/.sva-skills-lift."$qName
  rm -rf "`$tmp"
  mv "`$stage/"$qName "`$tmp"
  rm -rf "`$stage"
  stage="`$tmp"
fi
rm -rf "`$dest"
mv "`$stage" "`$dest"
"@
    $swapResult = Invoke-RemoteSsh -RemoteCommand 'bash -s' -Stdin $swap
    if ($swapResult.ExitCode -ne 0) {
        Write-ErrLine ("  error  {0}  (remote swap failed on {1})" -f $Name, $ConnLabel)
        return $false
    }

    Write-Out ("  install  {0}  ({1})  →  {2}" -f $Name, $why, $remoteDest)
    return $true
}

function Install-TargetRemote {
    param([string]$Target, [string]$Conn)
    if (-not (Resolve-SshubConnection $Conn)) {
        Die "could not resolve connection: $Conn"
    }
    $info = Get-TargetPaths $Target
    if (-not (Test-Path -LiteralPath $info.Src -PathType Container)) {
        Die "source not found: $($info.Src)"
    }
    $skills = @(Get-SkillDirs $info.Src)
    if ($skills.Count -eq 0) {
        Write-Out ("{0} {1}: no skills under {2}" -f $script:ResolvedName, $info.Label, $info.Src)
        return $true
    }
    Write-Out ("remote {0} @ {1} ({2}@{3}): {4}  →  ~/{5}/" -f `
            $info.Label, $script:ResolvedName, $script:ResolvedUser, $script:ResolvedHost, $info.Src, $info.Rel)
    if (-not (Get-RemoteSkillMtimes -RelParent $info.Rel -Names $skills)) {
        Write-ErrLine ("  error: cannot reach {0} ({1}@{2})" -f $script:ResolvedName, $script:ResolvedUser, $script:ResolvedHost)
        return $false
    }
    $ok = $true
    foreach ($name in $skills) {
        if (-not (Install-SkillRemote $name (Join-Path $info.Src $name) $info.Rel $script:ResolvedName)) {
            $ok = $false
        }
    }
    return $ok
}

function Show-TargetStatusRemote {
    param([string]$Target, [string]$Conn)
    if (-not (Resolve-SshubConnection $Conn)) {
        Die "could not resolve connection: $Conn"
    }
    $info = Get-TargetPaths $Target
    Write-Out ("remote {0} @ {1} ({2}@{3}): ~/{4}/" -f `
            $info.Label, $script:ResolvedName, $script:ResolvedUser, $script:ResolvedHost, $info.Rel)
    if (-not (Test-Path -LiteralPath $info.Src -PathType Container)) {
        Write-Out '  (source missing)'
        return $true
    }
    $skills = @(Get-SkillDirs $info.Src)
    if (-not (Get-RemoteSkillMtimes -RelParent $info.Rel -Names $skills)) {
        Write-ErrLine '  error: cannot reach host'
        return $false
    }
    foreach ($name in $skills) {
        $srcTs = Get-NewestMtime (Join-Path $info.Src $name)
        $destTs = [int64]0
        if ($script:RemoteMtime.ContainsKey($name)) {
            $destTs = [int64]$script:RemoteMtime[$name]
        }
        $action = if (Test-ShouldInstallTs $srcTs $destTs) { 'INSTALL' } else { 'skip' }
        Write-Out ('  {0,-8}  {1,-20}  {2}' -f $action, $name, (Get-ReasonForTs $srcTs $destTs))
    }
    return $true
}

function Invoke-ForTargets {
    param(
        [ValidateSet('install', 'status')]
        [string]$Mode,
        [string[]]$Targets,
        [string[]]$RemoteNames
    )
    $failures = 0

    if ($script:DoLocal) {
        if ($Mode -eq 'install' -and ($Targets -contains 'copilot')) {
            Invoke-MaybeInstallCopilotHost
            Write-Out ''
        }
        foreach ($t in $Targets) {
            if ($Mode -eq 'install') {
                Install-TargetLocal $t
            }
            else {
                Show-TargetStatusLocal $t
            }
            Write-Out ''
        }
    }

    if ($script:DoRemote) {
        $conns = @(Resolve-RemoteList -Tokens $RemoteNames)
        foreach ($conn in $conns) {
            foreach ($t in $Targets) {
                if ($Mode -eq 'install') {
                    if (-not (Install-TargetRemote $t $conn)) {
                        Write-ErrLine ("error: remote install failed for {0} ({1})" -f $conn, $t)
                        $failures++
                    }
                }
                else {
                    if (-not (Show-TargetStatusRemote $t $conn)) {
                        Write-ErrLine ("error: remote status failed for {0} ({1})" -f $conn, $t)
                        $failures++
                    }
                }
                Write-Out ''
            }
        }
    }

    return $failures
}

# ── scratch source (detect / last-N) ──────────────────────────

. (Join-Path $PSScriptRoot 'lib\scratch_resolve.ps1')
# Show-ScratchSource / Write-ScratchUnsetState / Write-ScratchDieUnset live in that file.

# scratch has its own --remote / --force; handle before installer flags.
if ($CliArgs.Count -gt 0 -and $CliArgs[0] -eq 'scratch') {
    $scratchRest = @()
    if ($CliArgs.Count -gt 1) {
        $scratchRest = @($CliArgs[1..($CliArgs.Count - 1)])
    }
    Invoke-ScratchCommand -ScratchArgs $scratchRest
    exit 0
}

. (Join-Path $PSScriptRoot 'lib\docify_resolve.ps1')
if ($CliArgs.Count -gt 0 -and $CliArgs[0] -eq 'docify') {
    $docifyRest = @()
    if ($CliArgs.Count -gt 1) {
        $docifyRest = @($CliArgs[1..($CliArgs.Count - 1)])
    }
    Invoke-DocifyCommand -DocifyArgs $docifyRest
    exit 0
}

. (Join-Path $PSScriptRoot 'lib\saveify_resolve.ps1')
if ($CliArgs.Count -gt 0 -and $CliArgs[0] -eq 'saveify') {
    $saveifyRest = @()
    if ($CliArgs.Count -gt 1) {
        $saveifyRest = @($CliArgs[1..($CliArgs.Count - 1)])
    }
    Invoke-SaveifyCommand -SaveifyArgs $saveifyRest
    exit 0
}

# ── arg parse (same rules as cli.sh) ──────────────────────────

function Test-KnownTarget {
    param([string]$Token)
    return ($Token -eq 'grok' -or $Token -eq 'cursor' -or $Token -eq 'copilot' -or $Token -eq 'all')
}

$ArgList = New-Object System.Collections.Generic.List[string]
$RemoteConns = New-Object System.Collections.Generic.List[string]

$i = 0
:parseLoop while ($i -lt $CliArgs.Count) {
    $a = $CliArgs[$i]
    switch -Regex ($a) {
        '^(-h|--help|-Help)$' {
            Show-Usage
            exit 0
        }
        '^(--list|-l|-List)$' {
            Show-SshubConnections
            exit 0
        }
        '^(--force|-Force)$' {
            $Force = $true
            $i++
            continue parseLoop
        }
        '^(--host|-Host)$' {
            if ($HostAction -eq 'no') {
                Die 'use only one of --host or --no-host'
            }
            $HostAction = 'yes'
            $i++
            continue parseLoop
        }
        '^(--no-host|-NoHost)$' {
            if ($HostAction -eq 'yes') {
                Die 'use only one of --host or --no-host'
            }
            $HostAction = 'no'
            $i++
            continue parseLoop
        }
        '^(--dry-run|-DryRun)$' {
            $DryRun = $true
            $i++
            continue parseLoop
        }
        '^(--local|-Local)$' {
            $DoLocal = $true
            $LocalExplicit = $true
            $i++
            continue parseLoop
        }
        '^(--remote|-r|-Remote)$' {
            $DoRemote = $true
            if (-not $LocalExplicit) {
                $DoLocal = $false
            }
            $i++
            while ($i -lt $CliArgs.Count -and $CliArgs[$i] -notmatch '^-') {
                [void]$RemoteConns.Add($CliArgs[$i])
                $i++
            }
            continue parseLoop
        }
        '^--$' {
            $i++
            while ($i -lt $CliArgs.Count) {
                [void]$ArgList.Add($CliArgs[$i])
                $i++
            }
            break parseLoop
        }
        '^-' {
            Die "unknown option: $a (try --help)"
        }
        default {
            [void]$ArgList.Add($a)
            $i++
        }
    }
}

$Cmd = ''
$Rest = @()
if ($ArgList.Count -gt 0) {
    $Cmd = $ArgList[0]
    if ($ArgList.Count -gt 1) {
        $Rest = @($ArgList.GetRange(1, $ArgList.Count - 1))
    }
}

if ($Cmd -eq 'project') {
    Install-Project -Rest $Rest
    if ($DryRun) {
        Write-Out '(dry-run: no files written)'
    }
    exit 0
}

$Targets = New-Object System.Collections.Generic.List[string]
$TargetSet = $false

foreach ($tok in $Rest) {
    if (Test-KnownTarget $tok) {
        if ($tok -eq 'all') {
            $Targets.Clear()
            [void]$Targets.Add('grok')
            [void]$Targets.Add('cursor')
            [void]$Targets.Add('copilot')
        }
        else {
            [void]$Targets.Add($tok)
        }
        $TargetSet = $true
    }
    else {
        $DoRemote = $true
        if (-not $LocalExplicit) {
            $DoLocal = $false
        }
        [void]$RemoteConns.Add($tok)
    }
}

if ($RemoteConns.Count -gt 0) {
    $filtered = New-Object System.Collections.Generic.List[string]
    foreach ($tok in @($RemoteConns)) {
        if (Test-KnownTarget $tok) {
            if (-not $TargetSet) {
                if ($tok -eq 'all') {
                    $Targets.Clear()
                    [void]$Targets.Add('grok')
                    [void]$Targets.Add('cursor')
                    [void]$Targets.Add('copilot')
                }
                else {
                    [void]$Targets.Add($tok)
                }
                $TargetSet = $true
            }
        }
        else {
            [void]$filtered.Add($tok)
        }
    }
    $RemoteConns = $filtered
}

if (-not $TargetSet -or $Targets.Count -eq 0) {
    $Targets.Clear()
    [void]$Targets.Add('grok')
    [void]$Targets.Add('cursor')
    [void]$Targets.Add('copilot')
}

$deduped = New-Object System.Collections.Generic.List[string]
$seen = @{}
foreach ($t in $Targets) {
    if (-not $seen.ContainsKey($t)) {
        $seen[$t] = $true
        [void]$deduped.Add($t)
    }
}
$Targets = $deduped

switch ($Cmd) {
    { $_ -eq '' -or $_ -eq '-h' -or $_ -eq '--help' } {
        Show-Usage
        exit 0
    }
    { $_ -eq 'list' -or $_ -eq 'ls' } {
        Show-SshubConnections
        exit 0
    }
    { $_ -eq 'install' -or $_ -eq 'pullinst' } {
        if ($Cmd -eq 'pullinst') {
            Invoke-GitPullMain
        }
        if (-not $DoLocal -and -not $DoRemote) {
            $DoLocal = $true
        }
        $rc = Invoke-ForTargets -Mode install -Targets @($Targets) -RemoteNames @($RemoteConns)
        if ($DryRun) {
            Write-Out '(dry-run: no files written)'
        }
        elseif ($rc -eq 0) {
            Invoke-ScratchInstallDetect
        }
        exit $rc
    }
    'status' {
        if (-not $DoLocal -and -not $DoRemote) {
            $DoLocal = $true
        }
        $rc = Invoke-ForTargets -Mode status -Targets @($Targets) -RemoteNames @($RemoteConns)
        exit $rc
    }
    default {
        Die "unknown command: $Cmd (try: install, pullinst, project, status, list, scratch, docify, saveify, --help)"
    }
}

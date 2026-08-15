#Requires -Version 5.1
<#
.SYNOPSIS
  sva-skills installer — sync repo skills into ~/.grok and ~/.cursor
  (local and/or across sshub connections from connections.env)

.DESCRIPTION
  Windows 10/11 port of scripts/cli.sh. Requires Windows PowerShell 5.1
  (preinstalled) or PowerShell 7+. Remote install uses the built-in
  OpenSSH client (ssh.exe / scp.exe).

.EXAMPLE
  .\scripts\cli.ps1 install
  .\scripts\cli.ps1 install grok
  .\scripts\cli.ps1 install --remote casai
  .\scripts\cli.ps1 status --remote
  .\scripts\cli.ps1 list
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
$GrokDest = Join-Path (Join-Path $HOME '.grok') 'skills'
$CursorDest = Join-Path (Join-Path $HOME '.cursor') 'skills'

# Remote destinations are always under the remote user's home (Linux hosts).
$RemoteGrokRel = '.grok/skills'
$RemoteCursorRel = '.cursor/skills'

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

function Show-Usage {
    $text = @'
sva-skills installer — sync repo skills into ~/.grok and ~/.cursor

Usage:
  .\scripts\cli.ps1 install              # same as: install all (local)
  .\scripts\cli.ps1 install all
  .\scripts\cli.ps1 install grok
  .\scripts\cli.ps1 install cursor
  .\scripts\cli.ps1 install --remote                 # all skills → all connections
  .\scripts\cli.ps1 install grok --remote casai      # name or alias from connections.env
  .\scripts\cli.ps1 install --remote casai CAS2SYS
  .\scripts\cli.ps1 install --local --remote         # local + every connection
  .\scripts\cli.ps1 status
  .\scripts\cli.ps1 status --remote [conn...]
  .\scripts\cli.ps1 list                             # list sshub connections

Options:
  --force       Always install, even if dest is newer
  --dry-run     Print actions only; do not write
  --remote, -r  Install to remote host(s); with no names, use all connections
  --local       Also install on this machine when using --remote
  --list, -l    List sshub connections and exit
  -h, --help    Show help

Targets:
  grok    .grok\<skill>\          →  ~\.grok\skills\<skill>\
  cursor  .cursor\skills\<skill>\ →  ~\.cursor\skills\<skill>\
  all     both (default when target omitted)

Connections come from:
  ~\.local\share\sshub\connections.env
(override with SSHUB_ENV_FILE / SSHUB_DATA_DIR). Names and aliases work
the same as sshub / sshot (e.g. casai, CASSADYAIFAP).

Remote install uses Windows OpenSSH (ssh.exe / scp.exe). Skills land in
the remote user's home (~/.grok/skills, ~/.cursor/skills).

A skill is installed when the destination is missing, or when any file under
the repo skill is newer than the newest file under the installed skill.
With --force, every skill is reinstalled regardless of mtimes.
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
        default {
            Die "unknown target: $Target (use grok, cursor, or all)"
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

# ── arg parse (same rules as cli.sh) ──────────────────────────

function Test-KnownTarget {
    param([string]$Token)
    return ($Token -eq 'grok' -or $Token -eq 'cursor' -or $Token -eq 'all')
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

$Targets = New-Object System.Collections.Generic.List[string]
$TargetSet = $false

foreach ($tok in $Rest) {
    if (Test-KnownTarget $tok) {
        if ($tok -eq 'all') {
            $Targets.Clear()
            [void]$Targets.Add('grok')
            [void]$Targets.Add('cursor')
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
    'install' {
        if (-not $DoLocal -and -not $DoRemote) {
            $DoLocal = $true
        }
        $rc = Invoke-ForTargets -Mode install -Targets @($Targets) -RemoteNames @($RemoteConns)
        if ($DryRun) {
            Write-Out '(dry-run: no files written)'
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
        Die "unknown command: $Cmd (try: install, status, list, --help)"
    }
}

# sva-skills scratch source — config, detect, search, last-N resolve.
# Dot-sourced by cli.ps1. Uses Die, Import-SshubEnv, Resolve-SshubConnection,
# Invoke-RemoteSsh, Ensure-OpenSsh, ConvertTo-BashSingleQuoted.

function Get-ScratchConfigPath {
    if ($env:LOCALAPPDATA) {
        return (Join-Path (Join-Path $env:LOCALAPPDATA 'sva-skills') 'scratch.env')
    }
    if ($env:XDG_DATA_HOME) {
        return (Join-Path (Join-Path $env:XDG_DATA_HOME 'sva-skills') 'scratch.env')
    }
    return (Join-Path (Join-Path (Join-Path $HOME '.local') 'share') (Join-Path 'sva-skills' 'scratch.env'))
}

function Get-ScratchCacheDir {
    if ($env:LOCALAPPDATA) {
        return (Join-Path (Join-Path (Join-Path $env:LOCALAPPDATA 'sva-skills') 'cache') 'scratch')
    }
    if ($env:XDG_CACHE_HOME) {
        return (Join-Path (Join-Path $env:XDG_CACHE_HOME 'sva-skills') 'scratch')
    }
    return (Join-Path (Join-Path (Join-Path $HOME '.cache') 'sva-skills') 'scratch')
}

function Test-ScratchImageName {
    param([string]$Name)
    $ext = [System.IO.Path]::GetExtension($Name)
    if ([string]::IsNullOrEmpty($ext)) {
        return $false
    }
    return @('.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp') -contains $ext.ToLowerInvariant()
}

function ConvertTo-ScratchLocalPath {
    param([string]$Path)
    if ([string]::IsNullOrEmpty($Path)) {
        return $Path
    }
    if ($Path -eq '~') {
        return $HOME
    }
    if ($Path.StartsWith('~/') -or $Path.StartsWith('~\')) {
        return (Join-Path $HOME $Path.Substring(2))
    }
    # Git Bash / POSIX /c/Users/... → C:\Users\...
    if ($Path -match '^/([A-Za-z])(/.*)?$') {
        $drive = $Matches[1].ToUpperInvariant()
        $rest = if ($Matches[2]) { ($Matches[2] -replace '/', '\') } else { '\' }
        return "${drive}:${rest}"
    }
    return $Path
}

function Get-ScratchImageCount {
    param([string]$Dir)
    if (-not (Test-Path -LiteralPath $Dir -PathType Container)) {
        return 0
    }
    $n = 0
    foreach ($f in @(Get-ChildItem -LiteralPath $Dir -File -Force -ErrorAction SilentlyContinue)) {
        if (Test-ScratchImageName $f.Name) {
            $n++
        }
    }
    return $n
}

function Get-ScratchLocalImages {
    param([string]$Dir)
    if (-not (Test-Path -LiteralPath $Dir -PathType Container)) {
        return @()
    }
    $items = @(Get-ChildItem -LiteralPath $Dir -File -Force -ErrorAction SilentlyContinue |
            Where-Object { Test-ScratchImageName $_.Name } |
            Sort-Object LastWriteTimeUtc -Descending)
    return $items
}

function Get-ScratchLocalCandidates {
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $list = New-Object System.Collections.Generic.List[string]
    $add = {
        param([string]$P)
        if ([string]::IsNullOrWhiteSpace($P)) { return }
        $norm = ConvertTo-ScratchLocalPath $P
        try {
            $full = [System.IO.Path]::GetFullPath($norm)
        }
        catch {
            $full = $norm
        }
        if ($seen.Add($full)) {
            [void]$list.Add($full)
        }
    }

    if ($env:SCREENSHOT_DIR) {
        & $add $env:SCREENSHOT_DIR
    }

    $pictures = $null
    try {
        $pictures = [Environment]::GetFolderPath('MyPictures')
    }
    catch {
        $pictures = $null
    }
    if ($pictures) {
        & $add (Join-Path $pictures 'Screenshots')
        & $add $pictures
    }

    & $add (Join-Path (Join-Path $HOME 'Pictures') 'Screenshots')
    & $add (Join-Path $HOME 'Pictures')

    $oneDrives = @(
        $env:OneDrive
        $env:OneDriveConsumer
        $env:OneDriveCommercial
        (Join-Path $HOME 'OneDrive')
    )
    foreach ($od in $oneDrives) {
        if ($od) {
            & $add (Join-Path (Join-Path $od 'Pictures') 'Screenshots')
            & $add (Join-Path $od 'Pictures')
        }
    }

    $userProfile = $env:USERPROFILE
    if ($userProfile) {
        & $add (Join-Path (Join-Path $userProfile 'Pictures') 'Screenshots')
        & $add (Join-Path $userProfile 'Pictures')
    }

    return @($list)
}

function Get-ScratchDetectPick {
    $firstExisting = $null
    foreach ($p in @(Get-ScratchLocalCandidates)) {
        if (Test-Path -LiteralPath $p -PathType Container) {
            if ((Get-ScratchImageCount $p) -gt 0) {
                return $p
            }
            if (-not $firstExisting) {
                $firstExisting = $p
            }
        }
    }
    return $firstExisting
}

function Import-ScratchEnv {
    $script:ScratchKind = ''
    $script:ScratchDir = ''
    $script:ScratchConn = ''
    $script:ScratchRemoteDir = ''
    $cfg = Get-ScratchConfigPath
    if (-not (Test-Path -LiteralPath $cfg -PathType Leaf)) {
        return $false
    }
    foreach ($raw in Get-Content -LiteralPath $cfg -Encoding UTF8) {
        $line = $raw.Trim()
        if ($line -eq '' -or $line.StartsWith('#')) { continue }
        if ($line.StartsWith('export ')) { $line = $line.Substring(7).Trim() }
        if ($line -notmatch '^([A-Za-z_][A-Za-z0-9_]*)=(.*)$') { continue }
        $key = $Matches[1]
        $val = $Matches[2]
        if ($val.Length -ge 2) {
            $q = $val[0]
            if (($q -eq [char]34 -or $q -eq [char]39) -and $val[-1] -eq $q) {
                $val = $val.Substring(1, $val.Length - 2)
            }
        }
        switch ($key) {
            'SCRATCH_KIND' { $script:ScratchKind = $val }
            'SCRATCH_DIR' { $script:ScratchDir = $val }
            'SCRATCH_CONN' { $script:ScratchConn = $val }
            'SCRATCH_REMOTE_DIR' { $script:ScratchRemoteDir = $val }
        }
    }
    return $true
}

function Write-ScratchEnv {
    $cfg = Get-ScratchConfigPath
    $dir = Split-Path -Parent $cfg
    if ($script:DryRun) {
        Write-Out "would write  $cfg"
        return
    }
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $lines = New-Object System.Collections.Generic.List[string]
    [void]$lines.Add('# sva-skills scratch source — kind=local|remote')
    [void]$lines.Add("SCRATCH_KIND=$($script:ScratchKind)")
    if ($script:ScratchKind -eq 'remote') {
        [void]$lines.Add("SCRATCH_CONN=$($script:ScratchConn)")
        [void]$lines.Add("SCRATCH_REMOTE_DIR=$($script:ScratchRemoteDir)")
    }
    else {
        [void]$lines.Add("SCRATCH_DIR=$($script:ScratchDir)")
    }
    $tmp = Join-Path $dir ('.scratch.env.{0}' -f [guid]::NewGuid().ToString('N').Substring(0, 8))
    Set-Content -LiteralPath $tmp -Value @($lines) -Encoding UTF8
    Move-Item -LiteralPath $tmp -Destination $cfg -Force
    try {
        icacls $cfg /inheritance:r /grant:r "${env:USERNAME}:R" | Out-Null
    }
    catch {
        # Best-effort private file; chmod 600 equivalent is not always available.
    }
}

function Resolve-ScratchRemotePath {
    param(
        [string]$Dir,
        [string]$Base = $script:ResolvedFolder
    )
    if ([string]::IsNullOrEmpty($Dir) -or $Dir -eq '~' -or $Dir.StartsWith('~/') -or $Dir.StartsWith('/')) {
        return $Dir
    }
    if ($Base) {
        if ($Base.EndsWith('/')) {
            return "$Base$Dir"
        }
        return "$Base/$Dir"
    }
    return $Dir
}

function Get-ScratchRemoteImages {
    param([string]$Rdir)
    $qDir = ConvertTo-BashSingleQuoted $Rdir
    $remote = @"
set +e
dir=$qDir
case "`$dir" in
  ~) dir="`$HOME" ;;
  "~/"*) dir="`$HOME/`${dir#\~/}" ;;
esac
if [ ! -d "`$dir" ]; then
  echo NODIR >&2
  exit 2
fi
if find "`$dir" -maxdepth 1 -type f -printf '%T@ %f\n' >/dev/null 2>&1; then
  find "`$dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' \) -printf '%T@\t%f\n'
  exit 0
fi
found=0
for f in "`$dir"/*; do
  [ -f "`$f" ] || continue
  b="`${f##*/}"
  e="`${b##*.}"
  [ "`$b" != "`$e" ] || continue
  e=`$(printf '%s' "`$e" | tr '[:upper:]' '[:lower:]')
  echo "`$e" | grep -Eq '^(png|jpg|jpeg|webp|gif|bmp)\$' || continue
  ts=`$(stat -c '%Y' "`$f" 2>/dev/null || stat -f '%m' "`$f" 2>/dev/null || echo "")
  [ -n "`$ts" ] || continue
  found=1
  printf '%s\t%s\n' "`$ts" "`$b"
done
if [ "`$found" -eq 1 ]; then
  exit 0
fi
n=100000
ls -lt "`$dir" 2>/dev/null | while IFS= read -r line; do
  case "`$line" in
    total*) continue ;;
  esac
  name=`$(printf '%s' "`$line" | awk '{print `$NF}')
  [ -n "`$name" ] || continue
  e="`${name##*.}"
  e=`$(printf '%s' "`$e" | tr '[:upper:]' '[:lower:]')
  echo "`$e" | grep -Eq '^(png|jpg|jpeg|webp|gif|bmp)\$' || continue
  printf '%s\t%s\n' "`$n" "`$name"
  n=`$((n - 1))
done
"@
    $result = Invoke-RemoteSsh -RemoteCommand 'bash -s' -Stdin $remote
    if ($result.ExitCode -ne 0) {
        return $null
    }
    $text = if ($null -eq $result.Output) { '' } else { ($result.Output | ForEach-Object { "$_" }) -join "`n" }
    $rows = New-Object System.Collections.Generic.List[object]
    foreach ($line in ($text -split '\r?\n')) {
        if (-not $line.Trim()) { continue }
        $parts = $line -split "`t", 2
        if ($parts.Count -lt 2) { continue }
        $ts = 0L
        [void][int64]::TryParse($parts[0], [ref]$ts)
        [void]$rows.Add([pscustomobject]@{ Ts = $ts; Name = $parts[1] })
    }
    return @($rows | Sort-Object Ts -Descending)
}

function Copy-ScratchRemoteFile {
    param(
        [string]$RemoteFile,
        [string]$Dest
    )
    Ensure-OpenSsh
    $scpArgs = @(Get-SshCommonArgs -ForScp)
    $scpArgs += @('-q', '-p')
    $scpArgs += ('{0}@{1}:{2}' -f $script:ResolvedUser, $script:ResolvedHost, $RemoteFile)
    $scpArgs += $Dest
    & $script:ScpExe @scpArgs | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Get-ScratchRemoteLastN {
    param(
        [int]$N,
        [string]$Rdir
    )
    $cache = Get-ScratchCacheDir
    if (-not (Test-Path -LiteralPath $cache -PathType Container)) {
        New-Item -ItemType Directory -Path $cache -Force | Out-Null
    }
    $rows = Get-ScratchRemoteImages $Rdir
    if ($null -eq $rows) {
        Die "cannot list remote images in $Rdir"
    }
    $scpDir = $Rdir
    if ($scpDir -eq '~') {
        $scpDir = ''
    }
    elseif ($scpDir.StartsWith('~/')) {
        $scpDir = $scpDir.Substring(2)
    }
    $paths = New-Object System.Collections.Generic.List[string]
    $count = 0
    foreach ($row in $rows) {
        $name = $row.Name
        if (-not $name) { continue }
        $remoteSpec = if ($scpDir) { "$scpDir/$name" } else { $name }
        $dest = Join-Path $cache $name
        if (-not (Copy-ScratchRemoteFile $remoteSpec $dest)) {
            Die "scp failed for $name"
        }
        [void]$paths.Add($dest)
        $count++
        if ($count -ge $N) { break }
    }
    return @($paths)
}

function Write-ScratchPurpose {
    Write-Out 'Screenshot / scratch image source'
    Write-Out 'This is the folder ify Nimages and Grok /image use for last-N images'
    Write-Out '(png, jpg, jpeg, webp, gif, bmp).'
}

function Write-ScratchNextSteps {
    param([switch]$ToError)
    $lines = @(
        'Next steps (copy-paste):'
        '  cli scratch detect'
        '  .\scripts\cli.ps1 scratch detect'
        ''
        '  cli scratch search'
        '  .\scripts\cli.ps1 scratch search'
        ''
        '  cli scratch set ~/Pictures/Screenshots'
        '  .\scripts\cli.ps1 scratch set ~/Pictures/Screenshots'
    )
    foreach ($line in $lines) {
        if ($ToError) { Write-ErrLine $line } else { Write-Out $line }
    }
}

function Write-ScratchConfigNote {
    param(
        [string]$Cfg,
        [switch]$ToError
    )
    $lines = @('{0,-15}{1}' -f 'Config file:', $Cfg)
    if (Test-Path -LiteralPath $Cfg -PathType Leaf) {
        $lines += '               (exists but no source is set — detect/set will write it here)'
    }
    else {
        $lines += '               (not created yet — detect/set will save the source here)'
    }
    foreach ($line in $lines) {
        if ($ToError) { Write-ErrLine $line } else { Write-Out $line }
    }
}

function Test-ScratchSourceSet {
    if (-not (Import-ScratchEnv)) {
        return $false
    }
    if ($script:ScratchKind -eq 'local' -and -not [string]::IsNullOrWhiteSpace($script:ScratchDir)) {
        return $true
    }
    if ($script:ScratchKind -eq 'remote' -and -not [string]::IsNullOrWhiteSpace($script:ScratchConn)) {
        return $true
    }
    return $false
}

function Write-ScratchUnsetState {
    $cfg = Get-ScratchConfigPath
    Write-ScratchPurpose
    Write-Out ''
    Write-Out 'No screenshot folder is configured yet.'
    Write-Out 'This is not broken. Skills fall back to the workspace scratch/ directory'
    Write-Out '(repo root, or the project''s existing scratch dir). last-N will not use'
    Write-Out '~/Pictures/Screenshots until you detect or set a source.'
    Write-Out ''
    Write-ScratchConfigNote -Cfg $cfg
    Write-Out ''
    Write-ScratchNextSteps
}

function Write-ScratchDieUnset {
    Write-ErrLine 'error: no screenshot folder is configured yet'
    Write-ErrLine 'This is not broken. Skills fall back to the workspace scratch/ directory.'
    Write-ErrLine 'last-N will not use ~/Pictures/Screenshots until you detect or set a source.'
    Write-ErrLine ''
    Write-ScratchConfigNote -Cfg (Get-ScratchConfigPath) -ToError
    Write-ErrLine ''
    Write-ScratchNextSteps -ToError
    exit 1
}

function Write-ScratchKv {
    param([string]$Label, [string]$Value)
    Write-Out ('{0,-15}{1}' -f $Label, $Value)
}

function Show-ScratchUsage {
    $cfg = Get-ScratchConfigPath
    $cache = Get-ScratchCacheDir
    $text = @"
sva-skills scratch source — last-N images for ify Nimages and Grok /image

``scratch show`` reports the screenshot / scratch folder those skills read.
If unset, skills fall back to the workspace scratch/ directory (not broken).

Usage:
  .\scripts\cli.ps1 scratch show
  .\scripts\cli.ps1 scratch set <path>
  .\scripts\cli.ps1 scratch set --remote <conn> <dir>
  .\scripts\cli.ps1 scratch search
  .\scripts\cli.ps1 scratch search --remote <conn>
  .\scripts\cli.ps1 scratch detect [--force]
  .\scripts\cli.ps1 scratch ls [N]          # default N=5; paths only (skills use this)

Config:
  $cfg
  kind=local|remote  (install writes if unset; detect --force overwrites)

Remote dirs use sshub rules: bare name joins NAME_FOLDER; ~ ~/x /abs stay verbatim.
Last-N remote: ssh list by mtime, scp only those N files into
  $cache
"@
    Write-Out $text
}

function Show-ScratchSource {
    $cfg = Get-ScratchConfigPath
    if (-not (Test-ScratchSourceSet)) {
        Write-ScratchUnsetState
        return
    }
    Write-ScratchPurpose
    Write-Out ''
    Write-ScratchKv 'Kind:' $script:ScratchKind
    if ($script:ScratchKind -eq 'local') {
        $dir = ConvertTo-ScratchLocalPath $script:ScratchDir
        if (Test-Path -LiteralPath $dir -PathType Container) {
            Write-ScratchKv 'Local folder:' $script:ScratchDir
            Write-ScratchKv 'Images:' (Get-ScratchImageCount $dir)
            Write-Out 'Recent:'
            $i = 0
            foreach ($f in @(Get-ScratchLocalImages $dir)) {
                Write-Out ('  {0}  {1}' -f $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'), $f.Name)
                $i++
                if ($i -ge 5) { break }
            }
            if ($i -eq 0) {
                Write-Out '  (none)'
            }
        }
        else {
            Write-ScratchKv 'Local folder:' ($script:ScratchDir + '  (missing on this box)')
        }
    }
    elseif ($script:ScratchKind -eq 'remote') {
        Write-ScratchKv 'Remote host:' $script:ScratchConn
        Write-ScratchKv 'Remote folder:' $script:ScratchRemoteDir
        if (-not (Resolve-SshubConnection $script:ScratchConn)) {
            Die "unknown connection: $($script:ScratchConn)"
        }
        $rdir = Resolve-ScratchRemotePath $script:ScratchRemoteDir
        Write-ScratchKv 'Resolved as:' ('{0}  ({1}@{2})' -f $rdir, $script:ResolvedUser, $script:ResolvedHost)
        $rows = Get-ScratchRemoteImages $rdir
        if ($null -eq $rows) {
            Write-ScratchKv 'Recent:' '(host unreachable)'
            Write-ScratchKv 'Config file:' $cfg
            return
        }
        Write-Out 'Recent:'
        $i = 0
        foreach ($row in $rows) {
            $when = if ($row.Ts -gt 100000) {
                ([DateTimeOffset]::FromUnixTimeSeconds([int64]$row.Ts)).LocalDateTime.ToString('yyyy-MM-dd HH:mm:ss')
            }
            else {
                [string]$row.Ts
            }
            Write-Out ('  {0}  {1}' -f $when, $row.Name)
            $i++
            if ($i -ge 5) { break }
        }
        if ($i -eq 0) {
            Write-Out '  (none reachable)'
        }
    }
    Write-ScratchKv 'Config file:' $cfg
}

function Set-ScratchSource {
    param([string[]]$Args)
    if ($Args.Count -ge 1 -and ($Args[0] -eq '--remote' -or $Args[0] -eq '-r')) {
        if ($Args.Count -lt 3) {
            Die 'usage: scratch set --remote <conn> <dir>'
        }
        $conn = $Args[1]
        $rdir = $Args[2]
        if (-not (Resolve-SshubConnection $conn)) {
            Die "unknown connection: $conn"
        }
        $script:ScratchKind = 'remote'
        $script:ScratchConn = $script:ResolvedName
        $script:ScratchRemoteDir = $rdir
        $script:ScratchDir = ''
        Write-ScratchEnv
        Write-Out ("scratch source: remote {0}:{1}" -f $script:ScratchConn, $script:ScratchRemoteDir)
        Write-Out ("config:         {0}" -f (Get-ScratchConfigPath))
        return
    }
    if ($Args.Count -lt 1 -or [string]::IsNullOrWhiteSpace($Args[0])) {
        Die 'usage: scratch set <path>   or   scratch set --remote <conn> <dir>'
    }
    $path = ConvertTo-ScratchLocalPath $Args[0]
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        Die "directory not found: $path"
    }
    $path = (Resolve-Path -LiteralPath $path).Path
    $script:ScratchKind = 'local'
    $script:ScratchDir = $path
    $script:ScratchConn = ''
    $script:ScratchRemoteDir = ''
    Write-ScratchEnv
    Write-Out ("scratch source: local {0}" -f $script:ScratchDir)
    Write-Out ("config:         {0}" -f (Get-ScratchConfigPath))
}

function Search-ScratchSource {
    param([string[]]$Args)
    if ($Args.Count -ge 1 -and ($Args[0] -eq '--remote' -or $Args[0] -eq '-r')) {
        if ($Args.Count -lt 2) {
            Die 'usage: scratch search --remote <conn>'
        }
        $conn = $Args[1]
        if (-not (Resolve-SshubConnection $conn)) {
            Die "unknown connection: $conn"
        }
        Write-Out ("remote search @ {0} ({1}@{2})" -f $script:ResolvedName, $script:ResolvedUser, $script:ResolvedHost)
        $cands = New-Object System.Collections.Generic.List[string]
        if ($script:ResolvedFolder) {
            [void]$cands.Add($script:ResolvedFolder)
            [void]$cands.Add(($script:ResolvedFolder.TrimEnd('/') + '/scratch'))
        }
        foreach ($d in @('scratch', '~/Pictures/Screenshots', '~/Pictures', '~/Desktop')) {
            [void]$cands.Add($d)
        }
        foreach ($d in $cands) {
            $rdir = Resolve-ScratchRemotePath $d
            $qDir = ConvertTo-BashSingleQuoted $rdir
            $remote = @"
set +e
dir=$qDir
case "`$dir" in
  ~) dir="`$HOME" ;;
  "~/"*) dir="`$HOME/`${dir#\~/}" ;;
esac
if [ ! -d "`$dir" ]; then
  echo missing
  exit 0
fi
n=0
for f in "`$dir"/*; do
  [ -f "`$f" ] || continue
  b="`${f##*/}"
  e="`${b##*.}"
  [ "`$b" != "`$e" ] || continue
  e=`$(printf '%s' "`$e" | tr '[:upper:]' '[:lower:]')
  echo "`$e" | grep -Eq '^(png|jpg|jpeg|webp|gif|bmp)\$' || continue
  n=`$((n + 1))
done
echo "ok `$n"
"@
            $result = Invoke-RemoteSsh -RemoteCommand 'bash -s' -Stdin $remote
            if ($result.ExitCode -ne 0) {
                Write-Out ('  {0,-40}  (unreachable)' -f $rdir)
                continue
            }
            $out = if ($null -eq $result.Output) { '' } else { [string]$result.Output }
            $out = $out.Trim()
            if ($out -eq 'missing') {
                Write-Out ('  {0,-40}  missing' -f $rdir)
            }
            else {
                $n = $out -replace '^ok\s+', ''
                Write-Out ('  {0,-40}  {1} images' -f $rdir, $n)
            }
        }
        return
    }

    Write-Out 'local search (this box):'
    foreach ($p in @(Get-ScratchLocalCandidates)) {
        if (Test-Path -LiteralPath $p -PathType Container) {
            Write-Out ('  {0,-50}  {1,-8}  {2} images' -f $p, 'exists', (Get-ScratchImageCount $p))
        }
        else {
            Write-Out ('  {0,-50}  {1,-8}  {2}' -f $p, 'missing', '-')
        }
    }
}

function Write-ScratchDetect {
    param([bool]$Force)
    $cfg = Get-ScratchConfigPath
    if ((Test-Path -LiteralPath $cfg -PathType Leaf) -and -not $Force -and (Test-ScratchSourceSet)) {
        Write-Out ("scratch source already set ({0}) — use --force to overwrite" -f $cfg)
        Show-ScratchSource
        return
    }
    $picked = Get-ScratchDetectPick
    if (-not $picked) {
        Write-Out 'No screenshot folder was found on this box.'
        Write-Out 'This is not broken. Skills fall back to the workspace scratch/ directory.'
        Write-Out 'last-N will not use ~/Pictures/Screenshots until you set a source.'
        Write-Out ''
        Write-ScratchConfigNote -Cfg $cfg
        Write-Out ''
        Write-ScratchNextSteps
        return
    }
    $script:ScratchKind = 'local'
    $script:ScratchDir = $picked
    $script:ScratchConn = ''
    $script:ScratchRemoteDir = ''
    Write-ScratchEnv
    Write-Out ("scratch source: local {0}" -f $script:ScratchDir)
    Write-Out ("config:         {0}" -f (Get-ScratchConfigPath))
}

function Invoke-ScratchDetect {
    param([string[]]$Args)
    $force = $script:Force
    foreach ($a in $Args) {
        if ($a -eq '--force') {
            $force = $true
        }
        else {
            Die "unknown option for scratch detect: $a"
        }
    }
    Write-ScratchDetect -Force $force
}

function Invoke-ScratchInstallDetect {
    $cfg = Get-ScratchConfigPath
    if (Test-Path -LiteralPath $cfg -PathType Leaf) {
        return
    }
    Write-Out ''
    Write-Out 'scratch source (first install):'
    Write-ScratchDetect -Force $false
}

function Get-ScratchLastN {
    param([int]$N)
    if (-not (Test-ScratchSourceSet)) {
        Write-ScratchDieUnset
    }
    if ($script:ScratchKind -eq 'local') {
        if (-not $script:ScratchDir) {
            Die 'SCRATCH_DIR is empty'
        }
        $dir = ConvertTo-ScratchLocalPath $script:ScratchDir
        if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
            Die "scratch dir not found: $dir"
        }
        $i = 0
        foreach ($f in @(Get-ScratchLocalImages $dir)) {
            Write-Out $f.FullName
            $i++
            if ($i -ge $N) { break }
        }
        return
    }
    if ($script:ScratchKind -eq 'remote') {
        if (-not $script:ScratchConn) {
            Die 'SCRATCH_CONN is empty'
        }
        if (-not (Resolve-SshubConnection $script:ScratchConn)) {
            Die "unknown connection: $($script:ScratchConn)"
        }
        $rdir = Resolve-ScratchRemotePath $(if ($script:ScratchRemoteDir) { $script:ScratchRemoteDir } else { 'scratch' })
        foreach ($p in @(Get-ScratchRemoteLastN -N $N -Rdir $rdir)) {
            Write-Out $p
        }
        return
    }
    Die "unknown SCRATCH_KIND: $($script:ScratchKind)"
}

function Invoke-ScratchCommand {
    param([string[]]$ScratchArgs)
    if ($null -eq $ScratchArgs) {
        $ScratchArgs = @()
    }
    $sub = if ($ScratchArgs.Count -gt 0) { $ScratchArgs[0] } else { '' }
    $rest = if ($ScratchArgs.Count -gt 1) { @($ScratchArgs[1..($ScratchArgs.Count - 1)]) } else { @() }
    switch ($sub) {
        { $_ -eq '' -or $_ -eq '-h' -or $_ -eq '--help' -or $_ -eq 'help' } {
            Show-ScratchUsage
        }
        'show' { Show-ScratchSource }
        'set' { Set-ScratchSource -Args $rest }
        'search' { Search-ScratchSource -Args $rest }
        'detect' { Invoke-ScratchDetect -Args $rest }
        'ls' {
            $n = 5
            if ($rest.Count -ge 1 -and $rest[0]) {
                if ($rest[0] -notmatch '^\d+$' -or [int]$rest[0] -lt 1) {
                    Die "scratch ls: N must be a positive integer (got: $($rest[0]))"
                }
                $n = [int]$rest[0]
            }
            Get-ScratchLastN -N $n
        }
        default {
            Die "unknown scratch command: $sub (try: show, set, search, detect, ls)"
        }
    }
}

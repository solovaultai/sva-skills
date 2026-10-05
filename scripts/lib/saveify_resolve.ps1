# sva-skills saveify store — dir, ls, resolve, rm.
# Dot-sourced by cli.ps1. Uses Die and Write-Out.
#
# Store: %LOCALAPPDATA%\sva-skills\saveify\<slug>\
# See docs/saveify_contract.md. Do not create the store for dir or ls.

function Get-SaveifyStoreRoot {
    $base = $null
    if ($env:LOCALAPPDATA) {
        $base = $env:LOCALAPPDATA
    }
    elseif ($env:XDG_DATA_HOME) {
        $base = $env:XDG_DATA_HOME
    }
    else {
        $base = Join-Path (Join-Path $HOME '.local') 'share'
    }
    $path = Join-Path (Join-Path $base 'sva-skills') 'saveify'
    return [System.IO.Path]::GetFullPath($path)
}

function Write-SaveifyError {
    param([string]$Message)
    Write-ErrLine "**Error:** $Message"
    exit 1
}

function Test-SaveifySlug {
    param([string]$Slug)
    if ([string]::IsNullOrEmpty($Slug)) { return $false }
    if ($Slug.StartsWith('-')) { return $false }
    if ($Slug -eq '.' -or $Slug -eq '..') { return $false }
    if ($Slug.IndexOfAny([char[]]@('\', '/', "`n", "`r", "`t")) -ge 0) { return $false }
    return $true
}

function Get-SaveifyTextField {
    param($Obj, [string]$Name)
    if ($null -eq $Obj) { return '' }
    $prop = $Obj.PSObject.Properties[$Name]
    if ($null -eq $prop -or $null -eq $prop.Value) { return '' }
    $text = [string]$prop.Value
    $text = $text.Replace("`t", ' ').Replace("`r", '').Replace("`n", ' ')
    return $text
}

# Absolute snapshot directory, or $null when it is not a snapshot.
function Get-SaveifySnapshotPath {
    param([string]$Slug)
    if (-not (Test-SaveifySlug $Slug)) { return $null }
    $root = Get-SaveifyStoreRoot
    $dir = [System.IO.Path]::GetFullPath((Join-Path $root $Slug))
    $prefix = $root.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (-not $dir.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { return $null }
    $item = Get-Item -LiteralPath $dir -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { return $null }
    $meta = Join-Path $dir 'meta.json'
    if (-not (Test-Path -LiteralPath $meta -PathType Leaf)) { return $null }
    $metaItem = Get-Item -LiteralPath $meta -Force
    if ($metaItem.PSIsContainer) { return $null }
    if ($metaItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { return $null }
    return $dir
}

function Show-SaveifyUsage {
    $store = Get-SaveifyStoreRoot
    Write-Out @"
Usage:
  .\scripts\cli.ps1 saveify dir
  .\scripts\cli.ps1 saveify ls
  .\scripts\cli.ps1 saveify resolve <slug>
  .\scripts\cli.ps1 saveify rm <slug> --yes

Store: $store
ls: newest first. Empty store prints nothing.
  <n> <saved_at> <slug> <display_name> <verb> <stage> <cwd>
  tab-separated. 1 is the newest. A directory with no meta.json is not a row.
resolve prints that slug's directory. It takes a slug, not a list number
or a display name.
rm deletes that slug only when --yes is present. It does not prompt.
"@
}

function Show-SaveifyDir {
    param([string[]]$CmdArgs)
    if ($null -ne $CmdArgs -and $CmdArgs.Count -gt 0) {
        Die 'usage: saveify dir'
    }
    Write-Out (Get-SaveifyStoreRoot)
}

function Show-SaveifyList {
    param([string[]]$CmdArgs)
    if ($null -ne $CmdArgs -and $CmdArgs.Count -gt 0) {
        Die 'usage: saveify ls'
    }
    $root = Get-SaveifyStoreRoot
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { return }
    $rootItem = Get-Item -LiteralPath $root -Force
    if ($rootItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { return }

    $rows = New-Object System.Collections.Generic.List[object]
    foreach ($d in @(Get-ChildItem -LiteralPath $root -Force -Directory)) {
        if ($d.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { continue }
        $name = $d.Name
        if (-not (Test-SaveifySlug $name)) { continue }
        $meta = Join-Path $d.FullName 'meta.json'
        if (-not (Test-Path -LiteralPath $meta -PathType Leaf)) { continue }
        $metaItem = Get-Item -LiteralPath $meta -Force
        if ($metaItem.PSIsContainer) { continue }
        if ($metaItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { continue }
        try {
            $raw = [System.IO.File]::ReadAllText($meta)
            $obj = $raw | ConvertFrom-Json
        }
        catch {
            continue
        }
        if ($null -eq $obj -or $obj -is [System.Array]) { continue }
        [void]$rows.Add([pscustomobject]@{
                SavedAt     = (Get-SaveifyTextField $obj 'saved_at')
                Slug        = $name
                DisplayName = (Get-SaveifyTextField $obj 'display_name')
                Verb        = (Get-SaveifyTextField $obj 'verb')
                Stage       = (Get-SaveifyTextField $obj 'stage')
                Cwd         = (Get-SaveifyTextField $obj 'cwd')
            })
    }

    $sorted = @($rows | Sort-Object -Property `
        @{ Expression = { -not [string]::IsNullOrEmpty($_.SavedAt) }; Descending = $true }, `
        @{ Expression = { $_.SavedAt }; Descending = $true }, `
        @{ Expression = { $_.Slug }; Descending = $false })
    $n = 1
    foreach ($r in $sorted) {
        Write-Out ("{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}" -f $n, $r.SavedAt, $r.Slug, $r.DisplayName, $r.Verb, $r.Stage, $r.Cwd)
        $n++
    }
}

function Resolve-SaveifySlug {
    param([string[]]$CmdArgs)
    if ($null -eq $CmdArgs -or $CmdArgs.Count -ne 1 -or [string]::IsNullOrEmpty($CmdArgs[0])) {
        Die 'usage: saveify resolve <slug>'
    }
    $slug = $CmdArgs[0]
    $dir = Get-SaveifySnapshotPath $slug
    if ([string]::IsNullOrEmpty($dir)) {
        Write-SaveifyError "not found: $slug"
    }
    Write-Out $dir
}

function Remove-SaveifySlug {
    param([string[]]$CmdArgs)
    $yes = $false
    $slug = ''
    if ($null -eq $CmdArgs) { $CmdArgs = @() }
    foreach ($arg in $CmdArgs) {
        if ($arg -ceq '--yes') {
            $yes = $true
            continue
        }
        if (-not [string]::IsNullOrEmpty($slug)) {
            Die 'usage: saveify rm <slug> --yes'
        }
        $slug = $arg
    }
    if ([string]::IsNullOrEmpty($slug)) {
        Die 'usage: saveify rm <slug> --yes'
    }
    $dir = Get-SaveifySnapshotPath $slug
    if ([string]::IsNullOrEmpty($dir)) {
        Write-SaveifyError "not found: $slug"
    }
    if (-not $yes) {
        Write-SaveifyError '--yes required'
    }
    Remove-Item -LiteralPath $dir -Recurse -Force
}

function Invoke-SaveifyCommand {
    param([string[]]$SaveifyArgs)
    if ($null -eq $SaveifyArgs) {
        $SaveifyArgs = @()
    }
    $sub = if ($SaveifyArgs.Count -gt 0) { $SaveifyArgs[0] } else { '' }
    $rest = if ($SaveifyArgs.Count -gt 1) { @($SaveifyArgs[1..($SaveifyArgs.Count - 1)]) } else { @() }
    $low = $sub.ToLowerInvariant()
    if ($low -eq '' -or $low -eq '-h' -or $low -eq '--help' -or $low -eq 'help') {
        Show-SaveifyUsage
        return
    }
    switch ($low) {
        'dir' { Show-SaveifyDir -CmdArgs $rest }
        'ls' { Show-SaveifyList -CmdArgs $rest }
        'resolve' { Resolve-SaveifySlug -CmdArgs $rest }
        'rm' { Remove-SaveifySlug -CmdArgs $rest }
        default { Die "unknown saveify command: $sub (try: dir, ls, resolve, rm)" }
    }
}

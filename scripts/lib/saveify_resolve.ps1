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

# JSON string as stored. ConvertFrom-Json turns saved_at into a DateTime.
function Get-SaveifyJsonString {
    param($Element, [string]$Name)
    $prop = [System.Text.Json.JsonElement]::new()
    $found = $Element.TryGetProperty($Name, [ref]$prop)
    if (-not $found) { return '' }
    $kind = $prop.ValueKind
    if ($kind -eq [System.Text.Json.JsonValueKind]::String) {
        $text = $prop.GetString()
    }
    elseif ($kind -eq [System.Text.Json.JsonValueKind]::Null -or $kind -eq [System.Text.Json.JsonValueKind]::Undefined) {
        return ''
    }
    else {
        $text = $prop.ToString()
    }
    if ($null -eq $text) { return '' }
    return $text.Replace("`t", ' ').Replace("`r", '').Replace("`n", ' ')
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
ls: newest first. Empty store prints nothing. Does not require --yes.
  <n>  <saved_at>  <display_name>  <verb>, <phases> Phases, <stage>, <blocks> Blocks, <defers> Defers, <cwd>
  then a tab, then the slug. 1 is the newest. Show the row; map # via the slug.
  Counts come from table.txt (phase_layout box or a markdown phase table).
  No table.txt: 0 Phases, 0 Blocks, 0 Defers. A directory with no meta.json is not a row.
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

function Get-SaveifyHeaderIndexes {
    param([string[]]$Cells)
    $phaseI = -1
    $statusI = -1
    for ($i = 0; $i -lt $Cells.Count; $i++) {
        $low = $Cells[$i].ToLowerInvariant()
        if ($low -eq 'phase' -and $phaseI -lt 0) { $phaseI = $i }
        if ($low -eq 'status' -and $statusI -lt 0) { $statusI = $i }
    }
    if ($phaseI -lt 0 -or $statusI -lt 0) { return $null }
    return @($phaseI, $statusI)
}

function Split-SaveifyCells {
    param([string]$Line, [char]$Sep)
    $parts = $Line.Split($Sep)
    if ($parts.Count -ge 2 -and [string]::IsNullOrWhiteSpace($parts[0]) -and [string]::IsNullOrWhiteSpace($parts[$parts.Count - 1])) {
        if ($parts.Count -eq 2) { return @() }
        $parts = $parts[1..($parts.Count - 2)]
    }
    $cells = New-Object System.Collections.Generic.List[string]
    foreach ($p in $parts) { [void]$cells.Add($p.Trim()) }
    return ,$cells.ToArray()
}

function Test-SaveifyRuleRow {
    param([string[]]$Cells)
    if ($null -eq $Cells -or $Cells.Count -eq 0) { return $false }
    foreach ($c in $Cells) {
        if ([string]::IsNullOrWhiteSpace($c)) { continue }
        if ($c.Replace(' ', '') -notmatch '^:?-+:?$') { return $false }
    }
    return $true
}

function Get-SaveifyNormStatus {
    param([string]$Status)
    if ($null -eq $Status) { return '' }
    $text = $Status.Replace([char]0x2013, '-').Replace([char]0x2014, '-')
    $text = [regex]::Replace($text, '\s+', ' ').Trim().ToLowerInvariant()
    return $text
}

# Work-phase counts from table.txt. Missing or unreadable: 0, 0, 0.
function Get-SaveifyPhaseCounts {
    param([string]$Dir)
    $zeros = @(0, 0, 0)
    $table = Join-Path $Dir 'table.txt'
    if (-not (Test-Path -LiteralPath $table -PathType Leaf)) { return $zeros }
    $item = Get-Item -LiteralPath $table -Force
    if ($item.PSIsContainer) { return $zeros }
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { return $zeros }
    try {
        $text = [System.IO.File]::ReadAllText($table)
    }
    catch {
        return $zeros
    }
    $workRe = [regex]'(?i)^(?:P\d+|Phase\s+\d+)\b'
    $box = [char]0x2502
    $rows = New-Object System.Collections.Generic.List[object]
    $found = $false
    $phaseI = -1
    $statusI = -1
    foreach ($line in ($text -split "`r?`n")) {
        if ($line.IndexOf($box) -lt 0) { continue }
        $cells = Split-SaveifyCells -Line $line -Sep $box
        if ($phaseI -lt 0) {
            $idx = Get-SaveifyHeaderIndexes -Cells $cells
            if ($null -eq $idx) { continue }
            $phaseI = $idx[0]
            $statusI = $idx[1]
            $found = $true
            continue
        }
        $need = [Math]::Max($phaseI, $statusI)
        if ($cells.Count -le $need) { continue }
        if ([string]::IsNullOrWhiteSpace($cells[$phaseI])) { continue }
        [void]$rows.Add(@($cells[$phaseI], $cells[$statusI]))
    }
    if (-not $found) {
        $rows.Clear()
        $phaseI = -1
        $statusI = -1
        foreach ($line in ($text -split "`r?`n")) {
            $stripped = $line.Trim()
            if (-not $stripped.StartsWith('|')) {
                if ($found -and -not [string]::IsNullOrWhiteSpace($stripped)) { break }
                continue
            }
            $cells = Split-SaveifyCells -Line $stripped -Sep '|'
            if ($phaseI -lt 0) {
                $idx = Get-SaveifyHeaderIndexes -Cells $cells
                if ($null -eq $idx) { continue }
                $phaseI = $idx[0]
                $statusI = $idx[1]
                $found = $true
                continue
            }
            if (Test-SaveifyRuleRow -Cells $cells) { continue }
            $need = [Math]::Max($phaseI, $statusI)
            if ($cells.Count -le $need) { continue }
            if ([string]::IsNullOrWhiteSpace($cells[$phaseI])) { continue }
            [void]$rows.Add(@($cells[$phaseI], $cells[$statusI]))
        }
    }
    if (-not $found) { return $zeros }
    $phases = 0
    $blocks = 0
    $defers = 0
    foreach ($pair in $rows) {
        $phase = ([string]$pair[0]).Trim()
        if (-not $workRe.IsMatch($phase)) { continue }
        $phases++
        $st = Get-SaveifyNormStatus -Status ([string]$pair[1])
        if ($st -eq 'blocked' -or $st -eq 'def-blocked') { $blocks++ }
        if ($st -eq 'deferred' -or $st -eq 'def-blocked') { $defers++ }
    }
    return @($phases, $blocks, $defers)
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
        $doc = $null
        try {
            $raw = [System.IO.File]::ReadAllText($meta)
            $doc = [System.Text.Json.JsonDocument]::Parse($raw)
            $rootEl = $doc.RootElement
            if ($rootEl.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) { continue }
            $counts = Get-SaveifyPhaseCounts -Dir $d.FullName
            [void]$rows.Add([pscustomobject]@{
                    SavedAt     = (Get-SaveifyJsonString $rootEl 'saved_at')
                    Slug        = $name
                    DisplayName = (Get-SaveifyJsonString $rootEl 'display_name')
                    Verb        = (Get-SaveifyJsonString $rootEl 'verb')
                    Stage       = (Get-SaveifyJsonString $rootEl 'stage')
                    Cwd         = (Get-SaveifyJsonString $rootEl 'cwd')
                    Phases      = $counts[0]
                    Blocks      = $counts[1]
                    Defers      = $counts[2]
                })
        }
        catch {
            continue
        }
        finally {
            if ($null -ne $doc) { $doc.Dispose() }
        }
    }

    $sorted = @($rows | Sort-Object -Property `
        @{ Expression = { -not [string]::IsNullOrEmpty($_.SavedAt) }; Descending = $true }, `
        @{ Expression = { $_.SavedAt }; Descending = $true }, `
        @{ Expression = { $_.Slug }; Descending = $false })
    $n = 1
    foreach ($r in $sorted) {
        $printed = "{0}  {1}  {2}  {3}, {4} Phases, {5}, {6} Blocks, {7} Defers, {8}" -f $n, $r.SavedAt, $r.DisplayName, $r.Verb, $r.Phases, $r.Stage, $r.Blocks, $r.Defers, $r.Cwd
        Write-Out ("{0}`t{1}" -f $printed, $r.Slug)
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

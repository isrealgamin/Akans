<#
.SYNOPSIS
    Re-inserts the Akan and Maroon map entities into the War Sails campaign map.

.DESCRIPTION
    All 15 Akan and Maroon settlements, plus the Maroon wooden bridge east of
    Adanse, need game_entity nodes in NavalDLC/SceneObj/Main_map/scene.xscene,
    named to match the settlement ids in Akans/ModuleData/akan_settlements.xml,
    or they appear on the map with no icon and cannot be clicked.

    scene.xscene is a BASE-GAME file. Anything that rewrites it drops those
    entities silently:
      - a Steam file-verify or a War Sails patch,
      - and, most easily missed, opening the map in the Bannerlord editor.
        The editor holds the scene in memory and rewrites it on save AND on
        exit, so it will undo edits made underneath it. Its process is named
        TaleWorlds.MountAndBlade.Launcher; the only reliable tell is a window
        title reading "Edit Mode: .../Main_map/scene.xscene". Close it before
        running this.

    Entities are matched by name, and the bridge additionally by position,
    since the map already contains 34 native wooden_brige entities. Only
    entities that are genuinely absent get inserted, so a partial revert is
    repaired without duplicating whatever survived.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\Restore-MapIcons.ps1
#>
[CmdletBinding()]
param(
    [string] $ScenePath,
    [string] $FragmentPath,
    [switch] $NoBackup
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $ScenePath)    { $ScenePath    = Join-Path $here '..\..\NavalDLC\SceneObj\Main_map\scene.xscene' }
if (-not $FragmentPath) { $FragmentPath = Join-Path $here 'akan_map_icons.xscene.fragment' }

foreach ($p in @($ScenePath, $FragmentPath)) {
    if (-not (Test-Path $p)) { Write-Error "Not found: $p"; exit 1 }
}
$ScenePath    = (Resolve-Path $ScenePath).Path
$FragmentPath = (Resolve-Path $FragmentPath).Path

Write-Host "Scene    : $ScenePath"
Write-Host "Fragment : $FragmentPath"

# Warn if the editor is holding the scene, because anything written now is lost.
$editor = Get-Process -ErrorAction SilentlyContinue |
          Where-Object { $_.MainWindowTitle -like '*Edit Mode*Main_map*' }
if ($editor) {
    Write-Warning "The Bannerlord editor appears to have this scene open (PID $($editor[0].Id))."
    Write-Warning "It rewrites scene.xscene on save and on exit, which will silently undo this."
    Write-Warning "Close it first, then re-run."
    exit 1
}

# Split a scene/fragment into top-level <game_entity> blocks.
function Get-TopLevelBlocks([string[]] $lines) {
    $blocks = @()
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^\t\t<game_entity name="([^"]*)"') {
            $name = $Matches[1]
            $pos  = ''
            for ($j = $i + 1; $j -lt [Math]::Min($i + 10, $lines.Length); $j++) {
                if ($lines[$j] -match '^\t\t\t<transform position="([^"]*)"') { $pos = $Matches[1]; break }
            }
            for ($j = $i + 1; $j -lt $lines.Length; $j++) {
                if ($lines[$j] -eq "`t`t</game_entity>") {
                    $blocks += [pscustomobject]@{ Name = $name; Pos = $pos; Start = $i; End = $j }
                    $i = $j
                    break
                }
            }
        }
    }
    return $blocks
}

$sceneLines = [IO.File]::ReadAllLines($ScenePath)
Write-Host ("Scene has {0:N0} lines." -f $sceneLines.Length)

$fragLines  = [IO.File]::ReadAllLines($FragmentPath)
$fragBlocks = Get-TopLevelBlocks $fragLines
Write-Host ("Fragment holds {0} entities." -f $fragBlocks.Count)

# Key existing scene entities by name, and by name+position for the bridges.
$sceneBlocks = Get-TopLevelBlocks $sceneLines
$byName = @{}
$byNamePos = @{}
foreach ($b in $sceneBlocks) {
    $byName[$b.Name] = $true
    $byNamePos["$($b.Name)|$($b.Pos)"] = $true
}

$missing = @()
foreach ($b in $fragBlocks) {
    # wooden_brige is not unique by name - 34 native ones exist - so match on position too.
    $present = if ($b.Name -eq 'wooden_brige') { $byNamePos["$($b.Name)|$($b.Pos)"] } else { $byName[$b.Name] }
    if (-not $present) { $missing += $b }
}

if ($missing.Count -eq 0) {
    Write-Host "Every entity is already present - nothing to do." -ForegroundColor Green
    exit 0
}
Write-Host ("Missing {0} of {1}: {2}" -f $missing.Count, $fragBlocks.Count, (($missing | ForEach-Object { $_.Name }) -join ', '))

$anchor = -1
for ($i = $sceneLines.Length - 1; $i -ge 0; $i--) {
    if ($sceneLines[$i].TrimEnd() -match '^\s*</entities>$') { $anchor = $i; break }
}
if ($anchor -lt 0) { Write-Error "Could not find the closing </entities> tag in the scene."; exit 1 }
Write-Host "Insertion point: line $($anchor + 1) (</entities>)."

if (-not $NoBackup) {
    Copy-Item $ScenePath "$ScenePath.bak" -Force
    Write-Host "Backed up original to: $ScenePath.bak"
}

$insert = New-Object System.Collections.Generic.List[string]
foreach ($b in $missing) { $insert.AddRange([string[]]$fragLines[$b.Start..$b.End]) }

$out = New-Object System.Collections.Generic.List[string]
if ($anchor -gt 0) { $out.AddRange([string[]]$sceneLines[0..($anchor - 1)]) }
$out.AddRange($insert)
$out.AddRange([string[]]$sceneLines[$anchor..($sceneLines.Length - 1)])

# Refuse to install a scene that does not parse.
$joined = [string]::Join("`r`n", $out)
try {
    $sr = New-Object IO.StringReader($joined)
    $r  = [System.Xml.XmlReader]::Create($sr)
    while ($r.Read()) {}
    $r.Close()
} catch {
    Write-Error "Result was not well-formed XML; scene left untouched. $($_.Exception.Message)"
    exit 1
}

[IO.File]::WriteAllLines($ScenePath, $out)
Write-Host ("Done - inserted {0:N0} lines for {1} entities; scene is now {2:N0} lines." -f $insert.Count, $missing.Count, $out.Count) -ForegroundColor Green

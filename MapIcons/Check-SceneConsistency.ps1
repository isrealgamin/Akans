<#
.SYNOPSIS
    Checks the campaign map scene against akan_settlements.xml for the kinds of
    mismatch that crash a new campaign but leave every XML file schema-valid.

.DESCRIPTION
    Four checks, each of which corresponds to a bug that actually happened:

    1. Data -> scene. Every settlement in akan_settlements.xml has an entity in
       the scene, at matching coordinates. A settlement with no icon cannot be
       clicked.

    2. Scene -> data. Every entity tagged town/castle/village/wm_hideout has a
       settlement behind it. This is the direction that gets forgotten: an
       entity referencing a settlement that no longer exists is an unresolvable
       reference, and the campaign dies at "Ticking map scene for first
       initialization". It is what the blwii_hideout crash was, and what
       removing akan_settlements.xml while leaving its entities recreated.

    3. drop_point parity. drop_point children are naval drop-off markers.
       NavalDLC.View.NavalMapSceneWrapper.InitializeDropOffLocations() walks
       them at map init, so a settlement carrying them MUST also carry
       port_posX/port_posY. Axim inherited two from a Khuzait coastal village
       it was cloned from, had no port position, and every new campaign died
       with 15 x "(Vec2) X: 0 Y: 0 has no region data" followed by a null.
       Cloning a settlement entity copies whatever the template had.

    4. Blockade arc parity. Native port towns carry exactly one
       Blockade_Arc_Start/End pair and a port position; non-port towns carry
       neither. The two must agree.

    Note that hideout_forest_20 is present in the scene TaleWorlds ships while
    being absent from settlement data. It is vanilla, harmless, and excluded.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\Check-SceneConsistency.ps1
#>
[CmdletBinding()]
param(
    [string] $ScenePath,
    [string] $SettlementsPath
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScenePath)       { $ScenePath       = Join-Path $here '..\..\NavalDLC\SceneObj\Main_map\scene.xscene' }
if (-not $SettlementsPath) { $SettlementsPath = Join-Path $here '..\ModuleData\akan_settlements.xml' }
foreach ($p in @($ScenePath, $SettlementsPath)) { if (-not (Test-Path $p)) { Write-Error "Not found: $p"; exit 1 } }
$ScenePath       = (Resolve-Path $ScenePath).Path
$SettlementsPath = (Resolve-Path $SettlementsPath).Path

# Entities the base game ships without matching settlement data. Vanilla, harmless.
$KnownSceneOnly = @('hideout_forest_20')

$moduleRoot = Split-Path (Split-Path $SettlementsPath -Parent) -Parent
$modulesDir = Split-Path $moduleRoot -Parent

$lines = [IO.File]::ReadAllLines($ScenePath)
$ax = New-Object System.Xml.XmlDocument; $ax.Load($SettlementsPath)

# Every settlement id the loaded modules define, so check 2 does not
# false-positive on native entities.
$known = @{}
foreach ($rel in @('NavalDLC\ModuleData\settlements.xml','SandBox\ModuleData\settlements.xml','StoryMode\ModuleData\story_mode_settlements.xml')) {
    $p = Join-Path $modulesDir $rel
    if (-not (Test-Path $p)) { continue }
    $d = New-Object System.Xml.XmlDocument; $d.Load($p)
    foreach ($n in $d.SelectNodes('//Settlement')) { $known[$n.GetAttribute('id')] = $true }
}
foreach ($n in $ax.SelectNodes('//Settlement')) { $known[$n.GetAttribute('id')] = $true }

# Index the scene's top-level entities.
$entities = @{}
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^\t\t<game_entity name="([^"]*)"') {
        $name = $Matches[1]
        $end = -1
        for ($j = $i + 1; $j -lt $lines.Length; $j++) { if ($lines[$j] -eq "`t`t</game_entity>") { $end = $j; break } }
        if ($end -lt 0) { continue }
        $block = $lines[$i..$end]
        $tags = @(); $pos = ''
        foreach ($l in $block) {
            if ($l -match '<tag name="([^"]*)"') { $tags += $Matches[1] }
            if (-not $pos -and $l -match '^\t\t\t<transform position="([-\d.]+), ([-\d.]+)') { $pos = "$($Matches[1]),$($Matches[2])" }
        }
        $rec = [pscustomobject]@{
            Name       = $name
            Tags       = $tags
            Pos        = $pos
            DropPoints = @($block | Where-Object { $_ -match '<game_entity name="drop_point"' }).Count
            ArcStart   = @($block | Where-Object { $_ -match 'Blockade_Arc_Start' }).Count
        }
        if (-not $entities.ContainsKey($name)) { $entities[$name] = @() }
        $entities[$name] += $rec
        $i = $end
    }
}

$problems = 0
function Fail($msg) { Write-Host "  FAIL  $msg" -ForegroundColor Red; $script:problems++ }

Write-Host "Scene       : $ScenePath"
Write-Host "Settlements : $SettlementsPath"
Write-Host ""

Write-Host "1. data -> scene (every settlement has an icon, positions agree)"
foreach ($s in $ax.SelectNodes('//Settlement')) {
    $id = $s.GetAttribute('id')
    if (-not $entities.ContainsKey($id)) { Fail "$id has no scene entity"; continue }
    $e = $entities[$id][0]
    if ($entities[$id].Count -gt 1) { Fail "$id appears $($entities[$id].Count) times in the scene" }
    $xy = $e.Pos -split ','
    if ($xy.Count -eq 2) {
        $dx = [Math]::Abs([double]$xy[0] - [double]$s.GetAttribute('posX'))
        $dy = [Math]::Abs([double]$xy[1] - [double]$s.GetAttribute('posY'))
        if ($dx -gt 0.01 -or $dy -gt 0.01) { Fail "$id position differs: scene ($($e.Pos)) vs data ($($s.GetAttribute('posX')),$($s.GetAttribute('posY')))" }
    }
}
Write-Host "      $($ax.SelectNodes('//Settlement').Count) settlements checked"

Write-Host "2. scene -> data (no entity references a settlement that does not exist)"
$settlementTags = @('town','castle','village','wm_hideout')
foreach ($name in $entities.Keys) {
    foreach ($e in $entities[$name]) {
        if (@($e.Tags | Where-Object { $settlementTags -contains $_ }).Count -eq 0) { continue }
        if ($known.ContainsKey($name)) { continue }
        if ($KnownSceneOnly -contains $name) { continue }
        Fail "$name is tagged [$($e.Tags -join '+')] but no module defines that settlement"
    }
}

Write-Host "3. drop_point parity (drop points require a port position)"
foreach ($s in $ax.SelectNodes('//Settlement')) {
    $id = $s.GetAttribute('id')
    if (-not $entities.ContainsKey($id)) { continue }
    $dp = $entities[$id][0].DropPoints
    $hasPort = [bool]$s.GetAttribute('port_posX')
    if ($dp -gt 0 -and -not $hasPort) { Fail "$id has $dp drop_point(s) but no port_posX - InitializeDropOffLocations will null" }
    if ($hasPort -and $dp -eq 0 -and $s.SelectSingleNode('Components/Village')) { Write-Host "  note  $id is a port village with no drop_point (native ones have 2)" -ForegroundColor Yellow }
}

Write-Host "4. blockade arc parity (arc iff port)"
foreach ($s in $ax.SelectNodes('//Settlement')) {
    $id = $s.GetAttribute('id')
    $town = $s.SelectSingleNode('Components/Town')
    if (-not $town -or $town.GetAttribute('is_castle') -eq 'true') { continue }
    if (-not $entities.ContainsKey($id)) { continue }
    $arc = $entities[$id][0].ArcStart -gt 0
    $hasPort = [bool]$s.GetAttribute('port_posX')
    if ($arc -and -not $hasPort) { Fail "$id has a blockade arc but no port_posX" }
    if ($hasPort -and -not $arc) { Fail "$id has port_posX but no blockade arc" }
}

Write-Host ""
if ($problems -eq 0) { Write-Host "PASS - scene and settlement data are consistent." -ForegroundColor Green; exit 0 }
Write-Host "$problems problem(s) found." -ForegroundColor Red
exit 1

<#
.SYNOPSIS
    Re-inserts the Akan settlement map icons into the War Sails campaign map.

.DESCRIPTION
    All 15 Akan and Maroon settlements need game_entity nodes in
    NavalDLC/SceneObj/Main_map/scene.xscene, named to match the settlement ids
    in Akans/ModuleData/akan_settlements.xml, or they appear on the map with no
    icon and cannot be clicked. That is Gao Castle and its two villages, plus
    Kormantse, Abrafo Castle, Nanny Town and Trelawny Keep with theirs.

    scene.xscene is a BASE-GAME file. A Steam file-verify or a War Sails patch
    reverts it and silently drops those three entities. This script puts them
    back from the fragment kept alongside it.

    Safe to run repeatedly: it detects icons that are already present and exits
    without touching the file.

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

$lines = [IO.File]::ReadAllLines($ScenePath)
Write-Host ("Scene has {0:N0} lines." -f $lines.Length)

$present = @($lines | Where-Object { $_ -match '<game_entity name="castle_M1"' }).Count
if ($present -gt 0) {
    Write-Host "Akan map icons are already present - nothing to do." -ForegroundColor Green
    exit 0
}

# The three entities belong at the end of <entities>, which is where the
# editor originally wrote them.
$anchor = -1
for ($i = $lines.Length - 1; $i -ge 0; $i--) {
    if ($lines[$i].TrimEnd() -match '^\s*</entities>$') { $anchor = $i; break }
}
if ($anchor -lt 0) { Write-Error "Could not find the closing </entities> tag in the scene."; exit 1 }
Write-Host "Insertion point: line $($anchor + 1) (</entities>)."

$fragment = [IO.File]::ReadAllLines($FragmentPath)
Write-Host ("Fragment has {0:N0} lines." -f $fragment.Length)

if (-not $NoBackup) {
    $bak = "$ScenePath.bak"
    Copy-Item $ScenePath $bak -Force
    Write-Host "Backed up original to: $bak"
}

$out = New-Object System.Collections.Generic.List[string]
if ($anchor -gt 0) { $out.AddRange([string[]]$lines[0..($anchor - 1)]) }
$out.AddRange([string[]]$fragment)
$out.AddRange([string[]]$lines[$anchor..($lines.Length - 1)])

$tmp = "$ScenePath.tmp"
[IO.File]::WriteAllLines($tmp, $out)

# Refuse to install a scene that does not parse.
try {
    $r = [System.Xml.XmlReader]::Create($tmp)
    while ($r.Read()) {}
    $r.Close()
} catch {
    Remove-Item $tmp -Force
    Write-Error "Result was not well-formed XML; scene left untouched. $($_.Exception.Message)"
    exit 1
}

Move-Item $tmp $ScenePath -Force
Write-Host ("Done - inserted {0:N0} lines, scene is now {1:N0} lines." -f $fragment.Length, $out.Count) -ForegroundColor Green
Write-Host ("Restored icons for {0} settlements." -f ($fragment | Where-Object { $_ -match '^\t\t<game_entity name=' }).Count)

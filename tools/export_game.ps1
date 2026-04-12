param(
    [string]$Preset
)

$ErrorActionPreference = "Stop"

$Godot = if ($env:GODOT) { $env:GODOT } else { "godot3" }
$Version = (Select-String -Path project.godot -Pattern 'config/version="v(.+)"').Matches.Groups[1].Value

$exports = @(
    @{ Preset = "windows"; File = "FlappyRace.exe" }
    @{ Preset = "mac";     File = "FlappyRace.zip" }
    @{ Preset = "linux";   File = "FlappyRace.x86_64" }
    @{ Preset = "html5";   File = "index.html" }
)

if ($Preset) {
    $valid = ($exports | ForEach-Object { $_.Preset }) -join ', '
    $exports = $exports | Where-Object { $_.Preset -eq $Preset }
    if ($exports.Count -eq 0) {
        Write-Error "Unknown preset '$Preset'. Valid presets: $valid"
        exit 1
    }
}

foreach ($export in $exports) {
    $dir = "builds/$($export.Preset)"
    Write-Host "Exporting $($export.Preset)..."
    if (Test-Path $dir) { Remove-Item "$dir/*" -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Start-Process -Wait -NoNewWindow $Godot -ArgumentList "--no-window", "--export", $export.Preset, "$dir/$($export.File)"
    Write-Host "Zipping $($export.Preset)..."
    $zipName = "builds/FlappyRace-$Version-$($export.Preset).zip"
    if ($export.Preset -eq "mac") {
        # Mac exports already come as a zip, so just move it to the correct name
        Move-Item -Force "$dir/$($export.File)" $zipName
    } else {
        Compress-Archive -Force -Path "$dir/*" -DestinationPath $zipName
    }
    Write-Host "Created $zipName"
}

Write-Host "All exports and zips complete!"

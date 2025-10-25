# Robust deploy script for Flutter on Windows
# Launches emulator if needed, waits for device, then runs app

param(
    [string]$emulatorId = "emulator-5554",
    [string]$emulatorName = "dev"
)

$running = flutter devices | Select-String $emulatorId
if (-not $running) {
    Write-Host "Launching emulator: $emulatorName"
    flutter emulators --launch $emulatorName
    do {
        Start-Sleep -Seconds 2
        $running = flutter devices | Select-String $emulatorId
        Write-Host "Waiting for $emulatorId to be available..."
    } while (-not $running)
}
Write-Host "Deploying to $emulatorId"
flutter run --debug -d $emulatorId

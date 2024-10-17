# Part 1: part1.ps1
# Check if the script is running in PowerShell

if ($Host.Name -ne 'ConsoleHost') {
    Write-Host "This script must be run in PowerShell." -ForegroundColor Red
    Write-Host "Launching PowerShell..." -ForegroundColor Green
    
    # Get the full path of the current script
    $scriptPath = $MyInvocation.MyCommand.Path
    
    # Launch PowerShell and execute the script
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    
    Exit
}

# Check and update PowerShell
$PowerShellSetupScript = Join-Path $PSScriptRoot "Update-Powershell.ps1"
if (Test-Path $PowerShellSetupScript) {
    Write-Host "Checking PowerShell installation..." -ForegroundColor Cyan
    & $PowerShellSetupScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "PowerShell setup failed. Please check the errors and try again." -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "PowerShell setup script not found. Continuing with existing PowerShell version." -ForegroundColor Yellow
}

Write-Host "This procedure WILL FORCE a system restart, please save your progress and close any open programs to prevent data loss." -ForegroundColor Red
Start-Sleep -Seconds 2
Write-Host "Press 'C' to continue, or 'Q' to quit"

$key = $null

while ($key.Character -ne 'c' -and $key.Character -ne 'q') {
    $key = $host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
}

if ($key.Character -eq 'q') {
    Exit 1
}

Write-Host "Starting WSL2 and Docker Desktop setup (Part 1)..." -ForegroundColor Green

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Host "This script requires administrative privileges." -ForegroundColor Red
    Write-Host "Please run this script as an administrator." -ForegroundColor Red
    Pause
    Exit 1
}

# Enable Windows features required for WSL2
Write-Host "Enabling Windows features for WSL2..." -ForegroundColor Cyan
Start-Process -FilePath "dism.exe" -ArgumentList "/online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart" -Wait
Start-Process -FilePath "dism.exe" -ArgumentList "/online /enable-feature /featurename:VirtualMachinePlatform /all /norestart" -Wait

# Download WSL2 Linux kernel update package
Write-Host "Downloading WSL2 Linux kernel update package..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile "$env:TEMP\wsl_update_x64.msi"

# Install WSL2 Linux kernel update package
Write-Host "Installing WSL2 Linux kernel update package..." -ForegroundColor Cyan
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $env:TEMP\wsl_update_x64.msi /qn" -Wait

# Set WSL2 as default
Write-Host "Setting WSL2 as default..." -ForegroundColor Cyan
wsl --set-default-version 2

# Create a scheduled task to run Part 2 after reboot
Write-Host "Creating scheduled task for Part 2..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$PSScriptRoot\Recovery-Setup2.ps1`""
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay (New-TimeSpan -Seconds 30)
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Write-Host "Task Scheduled. The system will now restart" -ForegroundColor Cyan
Register-ScheduledTask -TaskName "BackblazeSetupPart2" -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings -Force
Start-Sleep -Seconds 2
Write-Host "After reboot, operations will continue ~30 seconds after logging in." -ForegroundColor Green
Start-Sleep -Seconds 10
Restart-Computer -Force

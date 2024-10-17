# PowerShell Installation and Update Script

$MinimumVersion = [Version]"7.0.0"

function Install-PowerShell {
    Write-Host "Installing PowerShell..." -ForegroundColor Cyan
    try {
        Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
    }
    catch {
        Write-Host "Error installing PowerShell: $_" -ForegroundColor Red
        exit 1
    }
}

function Update-PowerShell {
    Write-Host "Updating PowerShell..." -ForegroundColor Cyan
    try {
        Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
    }
    catch {
        Write-Host "Error updating PowerShell: $_" -ForegroundColor Red
        exit 1
    }
}

# Check if running with admin privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrative privileges. Please run as administrator." -ForegroundColor Red
    exit 1
}

# Check if PowerShell 7+ is installed
$PSVersion = $PSVersionTable.PSVersion
if ($PSVersion.Major -lt 7) {
    Write-Host "PowerShell 7 or later is not installed." -ForegroundColor Yellow
    Install-PowerShell
}
else {
    Write-Host "PowerShell version $PSVersion is installed." -ForegroundColor Green
    
    # Check if an update is available
    $LatestVersion = (Invoke-RestMethod https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json).StableReleaseTag -replace '^v'
    if ([Version]$LatestVersion -gt $PSVersion) {
        Write-Host "A new version of PowerShell is available: $LatestVersion" -ForegroundColor Yellow
        $UpdateChoice = Read-Host "Do you want to update? (Y/N)"
        if ($UpdateChoice -eq "Y") {
            Update-PowerShell
        }
    }
    else {
        Write-Host "You have the latest version of PowerShell installed." -ForegroundColor Green
    }
}

# Verify the installation
$NewPSVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShellCore\InstalledVersions\*" -Name "SemanticVersion" -ErrorAction SilentlyContinue).SemanticVersion
if ($NewPSVersion -and [Version]$NewPSVersion -ge $MinimumVersion) {
    Write-Host "PowerShell $NewPSVersion is now installed and ready to use." -ForegroundColor Green
    Write-Host "Please restart your terminal or VS Code to use the new PowerShell version." -ForegroundColor Yellow
}
else {
    Write-Host "PowerShell installation or update may have failed. Please check and try again." -ForegroundColor Red
}
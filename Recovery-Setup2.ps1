# Part 2: part2.ps1
2 
# Error handling
$errorOccurred = $false

# Start setup process
Write-Host "Starting Docker Desktop and Backblaze Restore setup (Part 2)..." -ForegroundColor Green

# Download Docker Desktop Installer
Write-Host "Downloading Docker Desktop Installer..." -ForegroundColor Green
try {
    Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile "$env:TEMP\DockerDesktopInstaller.exe"
} catch {
    $errorOccurred = $true
    Write-Host "Error downloading Docker Desktop Installer." -ForegroundColor Red
    goto cleanup
}

# Install Docker Desktop
Write-Host "Installing Docker Desktop..." -ForegroundColor Green
try {
    Start-Process -FilePath "$env:TEMP\DockerDesktopInstaller.exe" -ArgumentList "install --quiet" -Wait
} catch {
    $errorOccurred = $true
    Write-Host "Error installing Docker Desktop." -ForegroundColor Red
    goto cleanup
}

# Wait for Docker to be ready
Write-Host "Waiting for Docker to start..." -ForegroundColor Yellow
$maxRetries = 10
$retryCount = 0
while ($retryCount -lt $maxRetries) {
    try {
        docker version
        Write-Host "Docker is up and running!" -ForegroundColor Green
        break
    } catch {
        Write-Host "Docker not ready yet. Retrying in 10 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        $retryCount++
    }
}

if ($retryCount -ge $maxRetries) {
    Write-Host "Docker failed to start after several attempts. Please check Docker Desktop." -ForegroundColor Red
    Exit 1
}

# Create directory for Backblaze restore
Write-Host "Creating directory for Backblaze restore..." -ForegroundColor Green
$restoreDir = "$env:USERPROFILE\backblaze_restore"
try {
    New-Item -ItemType Directory -Path $restoreDir -Force
    Write-Host "Created directory: $restoreDir" -ForegroundColor Green
} catch {
    $errorOccurred = $true
    Write-Host "Error creating Backblaze restore directory." -ForegroundColor Red
    goto cleanup
}

# Prompt for Backblaze credentials
$applicationKeyId = Read-Host "Enter your Backblaze Application Key ID"
$applicationKey = Read-Host "Enter your Backblaze Application Key"
$bucketName = Read-Host "Enter your Backblaze Bucket Name"

# Prompt for restore type
$restoreType = Read-Host "restore whole bucket or single file? (full/single)"

if ($restoreType -eq "single") {
    $fileId = Read-Host "Enter the file ID to retrieve"
    $fileName = Read-Host "Enter the desired file name for the downloaded file"
}

# Create a .env file with the RESTORE_DIR and Backblaze credentials
Write-Host "Creating .env file..." -ForegroundColor Green
$envContent = @"
RESTORE_DIR=$restoreDir
APPLICATION_KEY_ID=$applicationKeyId
APPLICATION_KEY=$applicationKey
BUCKET_NAME=$bucketName
RESTORE_TYPE=$restoreType
"@

if ($restoreType -eq "single") {
    $envContent += @"

FILE_ID=$fileId
FILE_NAME=$fileName
"@
}

try {
    $envContent | Out-File -FilePath "$restoreDir\.env" -Encoding UTF8
} catch {
    $errorOccurred = $true
    Write-Host "Error creating .env file." -ForegroundColor Red
    goto cleanup
}

# Clone the GitHub repository
Write-Host "Cloning the GitHub repository..." -ForegroundColor Green
$githubRepo = "https://github.com/the-muppet/backblaze-recovery.git"
try {
    git clone $githubRepo "$restoreDir\repo"
} catch {
    $errorOccurred = $true
    Write-Host "Error cloning GitHub repository." -ForegroundColor Red
    goto cleanup
}

# Move to the cloned repository directory
Set-Location -Path "$restoreDir\repo"

# Move the .env file to the cloned repository directory
Write-Host "Moving .env file to the cloned repository..." -ForegroundColor Green
try {
    Move-Item -Path "$restoreDir\.env" -Destination "$restoreDir\repo\.env"
} catch {
    $errorOccurred = $true
    Write-Host "Error moving .env file." -ForegroundColor Red
    goto cleanup
}

# Run docker-compose up --build
Write-Host "Running docker-compose up --build..." -ForegroundColor Green
try {
    docker-compose up --build
} catch {
    $errorOccurred = $true
    Write-Host "Error running docker-compose." -ForegroundColor Red
    goto cleanup
}

:cleanup
# Always remove the scheduled task
Write-Host "Removing scheduled task..." -ForegroundColor Green
try {
    Unregister-ScheduledTask -TaskName "BackblazeSetupPart2" -Confirm:$false
} catch {
    Write-Host "Error removing scheduled task." -ForegroundColor Red
}

if ($errorOccurred) {
    Write-Host "Setup encountered an error. Please check the logs and try again." -ForegroundColor Red
    Pause
    Exit 1
} else {
    Write-Host "Setup complete!" -ForegroundColor Green
    Write-Host "Docker Compose has been started and is building the containers." -ForegroundColor Green
    Write-Host "Please check the Docker logs for further details." -ForegroundColor Green
    Pause
    Exit 0
}

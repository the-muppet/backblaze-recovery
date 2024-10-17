# I need my shit Back(Blaze)!

## Overview

This project provides a set of scripts to streamline the process of restoring data from Backblaze B2 cloud storage. With different run options allowing for full-bucket sync or targeted single file retrieval.

## Components

- `Update-Powershell.ps1`: Ensures PowerShell 7+ is installed and up to date.
- `Recovery-Setup1.ps1`: Sets up WSL2 and Docker Desktop.
- `Recovery-Setup2.ps1`: Completes the setup process and prepares for data restoration.
- `restore.py`: Handles the actual data restoration from Backblaze B2.
- `Dockerfile` and `docker-compose.yml`: Docker configuration files for containerized execution.

## Prerequisites

- Windows 10 version 2004 and higher or Windows 11
- Administrator privileges on your Windows machine
- Internet connection
- Backblaze B2 account information:
  - Application Key ID
  - Application Key
  - Bucket Name
  - File ID (optional)

## Installation and Usage

1. Clone this repository or download and unzip the package on your local machine.

2. Navigate into the `backblaze-recovery` directory and start the recovery-process either by running:
  - `./Recovery-Setup1.ps1` in your console, or by right-clicking the script and selecting the `Run with Powershell` option.

This will set up WSL2 and Docker Desktop. Your system will restart after this step.

4. After the system restarts, the second part of the setup should run automatically, but in case it doesn't:
  - `.\Recovery-Setup2.ps1`
  
This script will complete the Docker Desktop installation and prepare for data restoration.

5. During setup, you'll be prompted to enter your Backblaze B2 credentials and choose between full bucket sync or single file retrieval.

6. The restore process will start automatically using Docker. You can monitor the progress in the Docker Desktop dashboard or command line.

## Restoration Options

As we're running this operation through a virtual Linux distribution and using volume mounting for persistence, I believe this will allow us to get around your filename length issue.

### Full Bucket Sync:
This option downloads all files from your specified Backblaze B2 bucket to your local machine. 
- give the answer `full` during setup when prompted for this option.

### Single File Retrieval:
This option allows you to download a specific file from your Backblaze B2 bucket using its file ID. 
- give the answer `single` during setup when prompted for this option.
    - this will require you input the file ID and a destination folder name.

## Troubleshooting

- For PowerShell installation issues, ensure you're running the script with administrative privileges.
- If you encounter Docker-related problems, check the Docker Desktop dashboard for logs and error messages.
- For Backblaze B2 restoration issues, verify your credentials and bucket information.

## Security Note

This tool handles sensitive information like your Backblaze B2 credentials. Always run these scripts in a secure environment and never share your credentials.

## The Fine Print (aka Disclaimer)

This tool is provided as-is, no warranties, no guarantees, no "get out of jail free" cards. Always keep backups of your backups (backupception?). Any users of this tool agree to not hold the author liable for any damages and will not hold author responsible for any data mishaps, computer rebellions, or if using this tool somehow turns you into a JavaScript developer. (which would be extra super weird, i know)

## License

This project is MIT licensed! 🎉

What does that mean? Well, in simple terms:

- Feel free to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of this software.
- Just make sure to include the original copyright notice and this permission notice in all copies or substantial portions of the software.

For the fun of it, here's the full MIT license text (because lawyers need something to read too):

```
MIT License

Copyright (c) 2024 Robert Pratt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

# Now go forth and restore those files! 💾✨
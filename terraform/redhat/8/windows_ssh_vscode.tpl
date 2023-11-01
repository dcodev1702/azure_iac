# Check if .ssh directory exists in C:\Users\$env:USERNAME
$sshDir = "$env:SystemDrive\$env:HOMEPATH\.ssh"
if (-not (Test-Path $sshDir)) {
    # If it doesn't exist, create it
    New-Item -Path $sshDir -ItemType Directory
}

# Check if the config file exists within the .ssh directory
$configFile = "$sshDir\config"
if (-not (Test-Path $configFile)) {
    # If it doesn't exist, create it
    New-Item -Path $configFile -ItemType File
}

Add-Content -path "${username}\.ssh\config" -value @'

Host ${hostname}
   HostName ${hostname}
   User ${user}
   IdentityFile ${identityfile}
'@

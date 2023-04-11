$usernme = [System.Environment]::UserName
add-content -path C:/Users/$username/.ssh/config -value @'

Host ${hostname}
   HostName ${hostname}
   User ${user}
   IdentityFile ${identityfile}
'@

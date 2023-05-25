Add-Content -path "C:\Users\${username}\.ssh\config" -value @'

Host ${hostname}
   HostName ${hostname}
   User ${user}
   IdentityFile ${identityfile}
'@

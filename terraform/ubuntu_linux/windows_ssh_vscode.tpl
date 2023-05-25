Add-Content -path "${username}\.ssh\config" -value @'

Host ${hostname}
   HostName ${hostname}
   User ${user}
   IdentityFile ${identityfile}
'@

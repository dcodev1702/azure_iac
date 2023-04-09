add-content -path C:/Users/lorenzo/.ssh/config -value @'

Host ${hostname}
   HostName ${hostname}
   User ${user}
   IdentityFile ${identityfile}
'@

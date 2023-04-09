add-content -path c:/Users/lireland/.ssh/config -value @'

Host ${hostname}
   HostName ${hostname}
   User ${user}
   IdentityFile ${identityfile}
'@

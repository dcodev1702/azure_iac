<#
This only runs when terraform detects that it is running
on a Windows host. This gets the logged in username and
converts a Key : Value pair into JSON.
#>
ConvertTo-Json @{
  username = (Get-ChildItem Env:USERNAME).Value
}

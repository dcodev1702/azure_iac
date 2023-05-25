ConvertTo-Json @{
  username = (Get-ChildItem Env:USERNAME).Value
}

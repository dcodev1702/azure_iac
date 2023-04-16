# Assumptions:
* You have Internet access
* You have access to PowerShell 5.X or greater. <br />
  * You can also accomplish this using Bash ..however, you need to modify [Step 3] $env:USERNAME -> $USER. <br />

# Instructions
0. [Works Cited:](https://www.youtube.com/watch?v=V53AHWun17s) A really helpful tutorial and great primer!

1. Login to your Azure Subscription via
[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

 
*** If required to login via Azure US Government Cloud *** <br />
    `az cloud set --name AzureUSGovernment`

```code
az login
```

2. Install Terraform
```code
https://developer.hashicorp.com/terraform/downloads
```

3. Provision SSH Key (Windows / Linux) <br />

   `3a. Provision SSH Key on a Windows Host`
   ```PowerShell
   ssh-keygen -t rsa -b 4096 -f "$env:SYSTEMDRIVE$env:HOMEPATH\.ssh\secOpsAzureKey"
   ```
   

   `3b. Provision SSH Key on a Linux Host`
    ```PowerShell
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/secOpsAzureKey
    ```


4. Download Github Repository
```code
git clone https://github.com/dcodev1702/azure_iac.git
```

5. Modify Terraform variables as required
```code
modify variables.tf
  - change
    + Username
    + Host OS
    
modify main.tf
  - change
    + line 126 to reflect your Host OS
    
terraform fmt
```

6. Initialize Terraform (Azure -> Linux VM)
```code
terraform init
```

7. Verify Terraform Plan is compliant with sanity checks
```code
terraform plan
```

8. Provision and deploy Azure resources and Ubuntu 22.04 VM
```code
terraform apply -auto-approve
```

9. SSH into your newly provisioned Linux VM
```code
ssh -i .ssh/secOpsAzureKey <username>@<VM-PUBLIC-UP>
```

10. Connect VSCode via SSH


11. Remove Resource Group, Ubuntu 22.04 VM & associated resources
```code
terraform apply -destroy -auto-approve
```

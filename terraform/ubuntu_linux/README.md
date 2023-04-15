# Assumptions:
* You have Internet access
* You have access to PowerShell 5.X or greater. <br />
  * You can also accomplish this using Bash ..however, you need to modify [Step 3] $env:USERNAME -> $USER. <br />

# Instructions
0. [Works Cited:](https://www.youtube.com/watch?v=V53AHWun17s) A really helpful tutorial and great primer!

1. Login to your Azure Subscription via
[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

 
*** If required to login via Azure US Government Cloud *** <br />
    --> az cloud set --name AzureUSGovernment

```code
az login --use-device-code
```

2. Install Terraform
```code
https://developer.hashicorp.com/terraform/downloads?ajs_aid=218faf6d-b0b4-4ef3-8c19-7f0805043ee6&product_intent=terraform
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
    
terraform fmt
```

6. Initialize Terraform (Azure -> Linux VM)
```code
terraform init
```

7. Deploy Resource Group and Ubuntu 22.04 VM to Azure
```code
terraform plan
terraform apply -auto-approve
```

8. SSH into your newly provisioned Linux VM
```code
ssh -i .ssh/secOpsAzureKey <username>@<VM-PUBLIC-UP>
```

9. Connect VSCode via SSH


10. Remove Resource Group, Ubuntu 22.04 VM & associated resources
```code
terraform apply -destroy -auto-approve
```

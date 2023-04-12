# Assumptions:
* You have Internet access
* You have access to PowerShell 5.X or greater. <br />
* You can also accomplish this using Bash ..however, you need to modify step 3 '$($env:USER)' for example to $USER. <br />

# Instructions
0. [Works Cited:](https://www.youtube.com/watch?v=V53AHWun17s) A really helpful tutorial and great primer!

1. Login to your Azure Subscription via
[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

 
*** If required to login via Azure US Government Cloud ***
```code
az cloud set --name AzureUSGovernment
```

```code
az login --use-device-code
```

2. Install Terraform
```code
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
```

3. Create ssh-key
```PowerShell
ssh-keygen -t rsa -f "C:\Users\$env:USERNAME/.ssh/secOpsAzureKey"
```

4. Download Repo
```code
git clone https://github.com/dcodev1702/azure_iac.git
```

5. Modify Terraform variables as required
```code
modify variables.tf
  - change
    + IP Address
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

8. Remove Resource Group, Ubuntu 22.04 VM & associated resources
```code
terraform apply -destroy -auto-approve
```

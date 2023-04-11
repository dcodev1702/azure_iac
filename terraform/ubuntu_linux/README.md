It is assumed that PowerShell 5.X or greater is the environment you're working from. <br />
You can also accomplish this using Bash ..you will just need to modify a step 3 '$($env:USER)' for example to $USER. <br />

0. [Works Cited:](https://www.youtube.com/watch?v=V53AHWun17s) A really helpful tutorial and great primer!

1. Login to your Azure Subscription via
[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

  * If required to login via Azure US Government Cloud
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
ssh-keygen -t rsa -f C:\Users\$($env:USER)/.ssh/secOpsAzureKey
```

4. Download Repo
```code
git clone https://github.com/dcodev1702/azure_iac.git
```

5. Initialize Terraform (Azure -> Linux VM)
```code
terraform fmt
terraform init
terraform plan
terraform apply -auto-approve
```

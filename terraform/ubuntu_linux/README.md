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
```code
ssh-keygen -o -a 100 -t ed25519 -f C:\Users\lorenzo/.ssh/secOpsAzureKey
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

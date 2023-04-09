0. [Works Cited:](https://www.youtube.com/watch?v=V53AHWun17s)

1. Install Terraform
```code
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
```

2. Create ssh-key
```code
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/secOpsAzureKey
```

3. Download Repo
```code
git clone https://github.com/dcodev1702/azure_iac.git
```

4. Initialize Terraform (Azure -> Linux VM)
```code
terraform fmt
terraform init
```

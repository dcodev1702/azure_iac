# Terraform -> Azure -> RHEL 8.8
1. It is assumed you have a [Microsoft Azure subscription](https://www.googleadservices.com/pagead/aclk?sa=L&ai=DChcSEwiWpuXG-9uBAxVESEcBHWBwAZgYABAAGgJxdQ&gclid=Cj0KCQjwmvSoBhDOARIsAK6aV7hY_R0AQtooe0G7jUgnei74fZDEHxmBdrAMRCpF4RFBRFYcsXf5aogaAt4nEALw_wcB&ohost=www.google.com&cid=CAESV-D2oYum1fYGjjaGhxnHvnWoX1f789QATR7Gd3anE2ra-eclgk2vrm1eDZV4r_rb7-XEuscGUmEwPEnXsol7EgAkHmKTUvc8DbTAThZRwpYo4TJ5GNNn8g&sig=AOD64_3_96UyILGUIi6Yt96ibtWYcBwmIg&q&adurl&ved=2ahUKEwjxwdzG-9uBAxUNjIkEHW1dCZUQ0Qx6BAgJEAE) with the appropriate permissions.
2. It is assumed [Azure CLI is installed](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf)
3. It is assumed [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) is installed <br />
4. Provision an SSH Key for the RedHat Linux Host (Key MUST be type: RSA)
```console
ssh-keygen -t rsa -b 4096 -f ~/.ssh/rhel88-rsyslog-azure
```

## Azure Login via Service Principal (SP) <br />
5. Create Service Principal and fill out the following in terraform.tfvars <br />

```console
export SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
az login --use-device-code
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
```

:: terraform.tfvars :: <br />
azure_subscription_id = "YOUR_SUBSCRIPTION_ID" <br />
azure_client_id       = "YOUR_CLIENT(APP)_ID" <br />
azure_client_secret   = "YOUR_CLIENT_SECRET" <br />
azure_tenant_id       = "YOUR_TENANT_ID" <br />

<br />

```console
terraform init
```

```console
terraform fmt
```

```console
terraform plan
```

```console
terraform apply -auto-approve
```

```console
terraform apply -destroy -auto-approve
```

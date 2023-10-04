# Terraform -> Azure -> RHEL 8.8
1. It is assumed [Azure CLI is installed](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf)

2. Create Service Principal and fill out the following in terraform.tfvars <br />

## Azure Login via Service Principal (SP) <br />

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
terraform apply -destory -auto-approve
```

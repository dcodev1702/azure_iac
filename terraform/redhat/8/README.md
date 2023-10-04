# Terraform -> Azure -> RHEL 8.8
Create Service Principal and fill out the following in terraform.tfvars <br />

## Azure Login via Service Principal (SP) <br />
```console
SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
```

:: terraform.tfvars ::
azure_subscription_id = "" <br />
azure_client_id       = "" <br />
azure_client_secret   = "" <br />
azure_tenant_id       = "" <br />


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

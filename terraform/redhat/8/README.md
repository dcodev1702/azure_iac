# RHEL 8.8 on Azure via Terraform
1. It is assumed you have a [Microsoft Azure subscription](https://www.googleadservices.com/pagead/aclk?sa=L&ai=DChcSEwiWpuXG-9uBAxVESEcBHWBwAZgYABAAGgJxdQ&gclid=Cj0KCQjwmvSoBhDOARIsAK6aV7hY_R0AQtooe0G7jUgnei74fZDEHxmBdrAMRCpF4RFBRFYcsXf5aogaAt4nEALw_wcB&ohost=www.google.com&cid=CAESV-D2oYum1fYGjjaGhxnHvnWoX1f789QATR7Gd3anE2ra-eclgk2vrm1eDZV4r_rb7-XEuscGUmEwPEnXsol7EgAkHmKTUvc8DbTAThZRwpYo4TJ5GNNn8g&sig=AOD64_3_96UyILGUIi6Yt96ibtWYcBwmIg&q&adurl&ved=2ahUKEwjxwdzG-9uBAxUNjIkEHW1dCZUQ0Qx6BAgJEAE) with the appropriate permissions.
2. It is assumed [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf) is installed. <br />
3. It is assumed [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) is installed. <br />
   * Requires Azure CLI when using Microsoft Azure


## Azure Login via Service Principal (SP)
4. Create a Service Principal and fill out the following fields in terraform.tfvars <br />

```console
export SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
az login --use-device-code
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
```

## Fill out these values in terraform.tfvars for Key Vault, RedHat 8/backend, and RedHat 8.
:: terraform.tfvars :: <br />
azure_subscription_id = "YOUR_SUBSCRIPTION_ID" <br />
azure_client_id       = "YOUR_CLIENT(APP)_ID" <br />
azure_client_secret   = "YOUR_CLIENT_SECRET" <br />
azure_tenant_id       = "YOUR_TENANT_ID" <br />

<br />

## Terraform Build Order
* Key Vault provisoning
* Azure Storage Account (backend provisioning for tfstate files)
* RedHat 8.8 Virtual Machine (VM) provisioning

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
ssh -i ./ssh/rhel88-rsyslog-azure dcodev@<RHEL88-VM-PUBLIC-IP>
```
<br />

[SELINUX TROUBLESHOOTING](https://www.syslog-ng.com/community/b/blog/posts/using-syslog-ng-with-selinux-in-enforcing-mode) TIPS:
VERY VALUABLE -- Search the Journal for SELINUX issues <br />
```console
sudo journalctl -b 0
```

By default; SELINUX is in "enforcing" mode, you can change it to "permissive" mode (requires reboot)  <br />
```console
sudo vi /etc/selinux/config
```

If you spot errors with SELINUX and RSYSLOG, you might see this as a suggestion <br />
```console
ausearch -c 'rsyslogd' --raw | audit2allow -M my-rsyslogd
semodule -X 300 -i my-rsyslogd.pp
```

```console
ls -dZ /var/log/
```

```console
semanage port --list | grep syslog
```

```console
semanage port -a -t syslogd_port_t -p tcp 20514
```

<br />

Tear down (destroy) the RHEL 8.8 VM as associated resources.  <br />
```console
terraform apply -destroy -auto-approve
```

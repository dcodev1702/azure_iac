# Terraform::Azure | Infrastructure as Code (IaC)
* Uses [Managed Identities (User Assigned)](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp#create-a-user-assigned-managed-identity) to provision infrastructure
   * Create Managed Identity (User-Assigned)
   * Assign Managed Identity to an Azure Virtual Machine.
   * Assign Managed Identity (User-Assigned) to the builtin "Storage Blob Data Owner" role.
* Azure Blob Storage Account (Terraform Backend support for tfstate)
   * Assigns Managed Identity to Azure Blob Storage Account
* Key Vault (VM SSH Key storage)
   * Uses remote TF backend (azure blob storage) to store TF state
   * Assigns Managed Identity to Key Vault Policy for access to read/write Secrets (SSH Keys) to the provisioned Key Vault.
   * Auditing is enabled however, requires you to specify a Log Analytics Workspace (LAW).
     * Change the values in the terraform.tfvars file.
* Data Collection Rule (Azure Monitor Agent)
   * Provision a Linux Syslog Data Collection Rule for the RHEL 8.8 Syslog Collector
* RHEL 8 Linux (8.8) Syslog Collector (Forwarder) w/ Azure Monitor Agent (AMA)
  * Uses remote TF backend (azure blob storage) to store TF state
  * Stores generated SSH Key in Azure Key Vault
  * Creates INBOUND NSG rules for [TCP:22 | UDP:514 | TCP:20514] fused to your WAN IP
  * Data Collection Rule (DCR) Syslog Association
  * RSyslog configured to accept UDP:514 and TCP:20514 remote connections via /etc/rsyslog.d/00-remotelog.conf
* Ubuntu Linux (22.04) as Syslog Client (no AMA extension installed on VM)
  * Uses remote TF backend (azure blob storage) to store TF state
  * Stores generated SSH Key in Azure Key Vault
  * Creates INBOUND NSG rule for [TCP:22] fused to your WAN IP
  * Creates a V-NET Peer with the RHEL 8's V-NET
  * Syslog /etc/rsyslog.d/50-default.conf has been modified to send auth and authpriv facilities to RHEL 8's Private IP Address [10.120.1.4]
* Windows 10 - TBD
* Windows Sever - TBD

## To use this repo effectively, the following is required:
* Access and permissions to an [Azure subscription](https://azure.microsoft.com/en-us/free)
  * Obtain your Tenant ID
  * Obtain your Subscription ID
  * Create an [Azure Virtual Machine](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal) (VM)
  * Create a [User Assigned Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp#create-a-user-assigned-managed-identity)
  * Install the following on your Azure VM.
    * Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
    * Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
    * Install [Git](https://github.com/git-guides/install-git)
    * Install [VSCode](https://code.visualstudio.com/docs/setup/setup-overview)

## Login to your Azure subscription via Azure CLI
* Elevated priviledges are required
```console
az login
```
![AZ CLI Login](https://github.com/dcodev1702/azure_iac/assets/32214072/bbfff05e-1fee-482c-b681-d59e6d7b66ae)


## Fill in TenantID, SubscriptionID, and your User Assigned Managed Identity
![terraform.tfvars](https://github.com/dcodev1702/azure_iac/assets/32214072/550a9b2e-2b6d-4966-98cb-34446ab0c6f2)

## Provision Infrastructure in the following order:
* Azure Storage Backend [az_tf_backend]
  ```console
  terraform init
  ```
  ```console
  terraform plan
  ```
  ```console
  terraform apply -auto-approve
  ```
* Azure Key Vault [key_vault]
  * DEPENDS ON: [Azure Storage Backend]
  * fill in required values in terraform.tfvars
  * same as above
* Data Collection Rule [az_tf_syslog dcr]
  * DEPENDS ON: [Azure Storage Backend]
  * fill in required values in terraform.tfvars
  * same as above
* RedHat 8.8 VM [redhat/8] - Syslog Collector
  * DEPENDS ON: [Azure Storage Backend, Key Vault, and Data Collection Rule (Syslog)]
  * fill in required values in terraform.tfvars
  * same as above
  ```console
  ssh -i ssh/rhel88-rsyslog-azure.pem dcodev@<PUBLIC_IP_ADDRESS>
  ```
* Ubuntu 22.04 VM [ubuntu_linux] - Syslog Client
  * DEPENDS ON: [Azure Storage Backend, Key Vault, and RedHat 8.8 Syslog Collector]
  * fill in required values in terraform.tfvars
  * same as above
  ```console
  ssh -i ssh/secops-linux-tf.pem dcodev@<PUBLIC_IP_ADDRESS>
  ```
  
* Run the following command to destroy the provisioned infrastruture
  ```console
  terraform apply -destroy -auto-approve
  ```

# Terraform::Azure | Infrastructure as Code (IaC)
* Uses Managed Identities (User) to provision infrastructure
* Azure Blob Storage Account (Terraform Backend support for tfstate)
* Key Vault (VM SSH Key storage)
* RHEL 8 Linux (8.8) Syslog Collector (Forwarder) w/ Azure Monitor Agent (AMA)
  * w/ Remote TF backend, SSH Key stored in Key Vault
* Ubuntu Linux (22.04) as Syslog Client (no agent installed on VM)
  * w/ Remote TF backend, SSH Key stored in Key Vault
* Windows 10 - TBD
* Windows Sever - TBD

## To use this repo effectively, the following is required:
* Access and permissions to an [Azure subscription](https://azure.microsoft.com/en-us/free)
  * Obtain your Tenant ID
  * Obtain your Subscription ID
  * Create a [User Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp#create-a-user-assigned-managed-identity)
  * Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  * Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

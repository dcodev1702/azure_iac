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

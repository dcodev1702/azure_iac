# Data Collection Rule Variables
dcr_syslog_name     = "tf-dcr-syslog"
tag_env             = "tf_dcr_syslog"
dcr_syslog_location = "eastus"
cloud_environment   = "public"

# Log Analytics Workspace values
log_analytics_workspace_name = "aad-telem"
log_analytics_workspace_rg   = "sec_telem_law_1"

# User Assigned Identity (Managed Service Identity (MSI))
user_assigned_identity_name     = "AzureTerraformDev0ps"
user_assigned_identity_guid     = ""
user_assigned_identity_endpoint = "http://169.254.169.254/metadata/identity/oauth2/token"
uai_resource_group_name         = "sec_telem_law_1"

# Azure Login via Service Principal (SP)
# SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" --name="AzureTerraformDevOps"
azure_subscription_id = ""
azure_tenant_id       = ""

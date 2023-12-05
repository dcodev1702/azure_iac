# Define Terraform provider
terraform {
  required_version = "~> 1.6.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.83.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
  }
  backend azurerm {
    resource_group_name  = "rg-terraform-devops"
    storage_account_name = "satfdev0ps1775"
    container_name       = "tfstate"
    key                  = "dcr-syslog.tfstate"
  }
}

# Configure the Azure provider
provider azurerm {
  features {}
  use_msi         = true
  environment     = var.cloud_environment
  client_id       = var.user_assigned_identity_guid
  msi_endpoint    = var.user_assigned_identity_endpoint
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

# Generate a random vm name
resource random_string main {
  length  = 8
  numeric = true
  lower   = true
  upper   = false
  special = false
}


resource azurerm_resource_group main {
  name     = "rg-tf-dcr-syslog-${random_string.main.result}"
  location = var.dcr_syslog_location
  tags = {
    environment = var.tag_env
  }
}

# Obtain User Managed Identity to provision the Data Collection Rule
data azurerm_user_assigned_identity user_msi {
  name                = var.user_assigned_identity_name
  resource_group_name = var.uai_resource_group_name
}

# Obtain Log Analytics Workspace to provision the Data Collection Rule (destination)
data azurerm_log_analytics_workspace main {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_rg
}

# Provision Data Collection Rule
resource azurerm_monitor_data_collection_rule main {
  name                = "${var.dcr_syslog_name}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  data_sources {
    syslog {
      facility_names = ["*"]
      log_levels     = ["*"]
      name           = "tf-syslog-datasource-${random_string.main.result}"
      streams        = ["Microsoft-Syslog"]
    }
  }

  destinations {
    log_analytics {
      workspace_resource_id = data.azurerm_log_analytics_workspace.main.id
      name                  = "${data.azurerm_log_analytics_workspace.main.name}-${random_string.main.result}"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["${data.azurerm_log_analytics_workspace.main.name}-${random_string.main.result}"]
  }
  
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.user_msi.id]
  }

  description    = "Syslog Data Collection Rule [terraform]"
  tags = {
    environment  = var.tag_env
  }
}

resource random_string main {
  length  = 5
  upper   = false
  special = false
  numeric = true
  lower   = false
}

resource azurerm_resource_group main {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = var.tag_env
  }
}

resource azurerm_storage_account main {
  name = "${var.storage_account_name}${random_string.main.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS" 
}

resource azurerm_storage_container tfstate {
  name                  = var.sa_container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
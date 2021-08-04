provider "random" {

}

resource "random_string" "postgresql_username" {
  count   = var.postgresql_enabled
  length  = "15"
  special = false
}

provider "azurerm" {
  version         = "=1.44.0"
  alias           = "aks"
  environment     = var.aks_environment
  subscription_id = var.aks_subscribed_id
  username       = var.aks_username
  password   = var.aks_password
  tenant_id       = var.aks_tenant_id
}

data "azurerm_virtual_network" "aks" {
  provider            = "azurerm.aks"
  name                = "${var.aks_env}-vnet"
  resource_group_name = "${var.aks_env}-rg"
}
data "azurerm_virtual_network" "aks" {
  provider            = "azurerm.aks"
  name                = "${var.aks_env}-vnet"
  resource_group_name = "${var.aks_env}-rg"
}

data "azurerm_subnet" "aks_application" {
  provider            = "azurerm.aks"
  name                 = "${var.aks_env}-application"
  virtual_network_name = data.azurerm_virtual_network.aks.name
  resource_group_name  = data.azurerm_virtual_network.aks.resource_group_name
}

data "azurerm_subnet" "aks_kubernetes" {
  provider            = "azurerm.aks"
  name                 = "${var.aks_env}-kubernetes"
  virtual_network_name = data.azurerm_virtual_network.aks.name
  resource_group_name  = data.azurerm_virtual_network.aks.resource_group_name
}

provider "azurerm" {
  version         = "=1.44.0"
  alias           = "app"
  environment     = var.app_environment
  subscription_id = var.app_subscription_id
  username       = var.app_username
  password   = var.app_password
  tenant_id       = var.app_tenant_id
}

data "azurerm_client_config" "app" {
  provider = "azurerm.app"
}
resource "azurerm_container_registry" "app" {
  provider            = "azurerm.app"
  depends_on          = [
    azurerm_resource_group.app
  ]
  count                     = var.container_registry_enabled
  name                      = replace("${var.app_env}-${var.app_name}", "-", "")
  resource_group_name       = azurerm_resource_group.app.name
  location                  = azurerm_resource_group.app.location
  sku                       = var.container_registry_sku
  admin_enabled             = true
  georeplication_locations  = var.container_registry_replication
  tags                      = azurerm_resource_group.app.tags
}

resource "azurerm_postgresql_server" "app" {
  provider            = "azurerm.app"
  depends_on          = [
    azurerm_resource_group.app
  ]
  count               = var.postgresql_enabled
  name                = "${var.app_env}-${var.app_name}-pg"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  version             = var.postgresql_version
  storage_profile {
    storage_mb            = var.postgresql_size
    geo_redundant_backup  = var.postgresql_backup_geo
    backup_retention_days = var.postgresql_backup_days
  }
  ssl_enforcement               = var.postgresql_ssl
  administrator_login           = "u${random_string.postgresql_username[0].result}"
  administrator_login_password  = "PASS"
  tags                          = azurerm_resource_group.app.tags
}

resource "azurerm_postgresql_database" "app" {
  provider              = "azurerm.app"
  depends_on            = [
    azurerm_postgresql_server.app[0]
  ]
  count                 = var.postgresql_enabled
  name                  = var.postgresql_name
  resource_group_name   = azurerm_postgresql_server.app[0].resource_group_name
  server_name           = azurerm_postgresql_server.app[0].name
  charset               = "UTF8"
  collation             = "English_United States.1252"
}
resource "azurerm_key_vault" "app" {
  provider                    = "azurerm.app"
  depends_on                  = [
    azurerm_resource_group.app
  ]
  count                       = var.vault_enabled
  name                        = "DEPT"
  resource_group_name         = azurerm_resource_group.app.name
  location                    = azurerm_resource_group.app.location
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.app.tenant_id
  sku_name                    = "standard"
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
  tags = azurerm_resource_group.app.tags
}
resource "azurerm_key_vault_secret" "app_registry_name" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.container_registry_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "PASS"
}

resource "azurerm_key_vault_secret" "app_registry_url" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.container_registry_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "PASS"
}

resource "azurerm_key_vault_secret" "app_registry_username" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.container_registry_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "PASS"
}

resource "azurerm_key_vault_secret" "app_registry_password" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.container_registry_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "PASS"
}

resource "azurerm_key_vault_secret" "app_storage_name" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.storage_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "PASS"
}
resource "azurerm_key_vault_secret" "app_storage_key" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.storage_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "PASS"
}

resource "azurerm_key_vault_secret" "app_postgresql_host" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.postgresql_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "PASS"
}

resource "azurerm_key_vault_secret" "app_postgresql_port" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.postgresql_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "5432"
}

resource "azurerm_key_vault_secret" "app_postgresql_username" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.postgresql_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "PASS"
}

resource "azurerm_key_vault_secret" "app_postgresql_password" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.postgresql_enabled
  key_vault_id  = azurerm_key_vault.app[0].id
  name          = "DEPT"
  value         = "PASS"
}

resource "azurerm_key_vault_secret" "app_postgresql_database" {
  provider      = "azurerm.app"
  count         = var.vault_enabled * var.postgresql_enabled
  name          = "DEPT"
  value         = "PASS"
}

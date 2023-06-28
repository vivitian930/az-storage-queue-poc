module "naming" {
  source      = "git@github-vivi:vivitian930/tf-azurerm-naming?ref=v0.1.0"
  location    = var.location
  environment = var.environment
  channel     = var.channel
  project     = var.project_short
  solution    = var.solution
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.rg
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = module.naming.sa
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_queue" "queue" {
  name                 = "test"
  storage_account_name = azurerm_storage_account.sa.name
}

resource "azurerm_service_plan" "asp" {
  name                = module.naming.asp
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "fa" {
  name                = module.naming.func
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {}
}


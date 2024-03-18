terraform {
    required_providers {
      azurerm={
        source = "hashicorp/azurerm"
        version = "3.17.0"
      }
    }

  
}

provider "azurerm" {
    features {
    }
    
}

resource "azurerm_resource_group" "caprg" {
  name     = "Emmanuel_CAPSTONE_PROJECT-RG"
  location = "West Europe"
}

resource "azurerm_service_plan" "capplan" {
  name                = "capstone-plan"
  resource_group_name = azurerm_resource_group.caprg.name
  location            = azurerm_resource_group.caprg.location
  sku_name            = "P1v2"
  os_type             = "Linux"
}

resource "azurerm_windows_web_app" "capapp" {
  name                = "capstonewebapp"
  resource_group_name = azurerm_resource_group.caprg.name
  location            = azurerm_service_plan.capplan.location
  service_plan_id     = azurerm_service_plan.capplan.id

  site_config {
    always_on = false
    application_stack {
        current_stack = "dotnet"
        dotnet_version = "v6.0"
    }
  }
  depends_on = [
    azurerm_service_plan.capplan
   ]
}

resource "azurerm_mssql_server" "capsql1624" {
  name                         = "capstonesqlpro"
  resource_group_name          = azurerm_resource_group.caprg.name
  location                     = azurerm_resource_group.caprg.location
  version                      = "12.0"
  administrator_login          = "luniemma"
  administrator_login_password = "thisIsKat11"
  minimum_tls_version          = "1.2"


  tags = {
    environment = "production"
  }
}
resource "azurerm_mssql_database" "cap-db" {
  name           = "capstone-db"
  server_id      = azurerm_mssql_server.capsql1624.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  read_scale     = true
  sku_name       = "P1"
  depends_on = [ azurerm_mssql_server.capsql1624 ]
}
resource "azurerm_storage_account" "capstore1824" {
  name                     = "capstone031824"
  resource_group_name      = azurerm_resource_group.caprg.name
  location                 = azurerm_resource_group.caprg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }

}
resource "azurerm_storage_container" "capstone2024" {
  name                  = "capcontent"
  storage_account_name  = azurerm_storage_account.capstore1824.name
  container_access_type = "private"
}
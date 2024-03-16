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
  name     = "capstone-rg"
  location = "West Europe"
}

resource "azurerm_service_plan" "capplan" {
  name                = "capstone-plan"
  resource_group_name = azurerm_resource_group.caprg.name
  location            = azurerm_resource_group.caprg.location
  sku_name            = "P1v2"
  os_type             = "linux"
}

resource "azurerm_windows_web_app" "capapp" {
  name                = "capstone-web-app"
  resource_group_name = azurerm_resource_group.caprg.name
  location            = azurerm_service_plan.capplan.location
  service_plan_id     = azurerm_service_plan.capplan.id

  site_config {
    always_on = false
    application_stack {
        current_stack = "dotnet"
        dotnet_version = "v8.0"
    }
  }
  depends_on = [
    azurerm_service_plan.capplan
   ]
}

resource "azurerm_mssql_server" "cap-sql" {
  name                         = "capstone-sql-server"
  resource_group_name          = azurerm_resource_group.caprg.name
  location                     = azurerm_resource_group.caprg.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = "00000000-0000-0000-0000-000000000000"
  }

  tags = {
    environment = "production"
  }
}
resource "azurerm_mssql_database" "cap-db" {
  name           = "capstone-db"
  server_id      = azurerm_mssql_server.cap-sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  read_scale     = true
  sku_name       = "basic"
  depends_on = [ azurerm_mssql_server.cap-sql ]
}
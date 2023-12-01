terraform {  
  backend "azurerm" {
  resource_group_name  = "TerraformRG"
  storage_account_name = "tfstateshowrun"
  container_name       = "tfstate"
  key                  = "prod.terraform.tfstate"
  }
}

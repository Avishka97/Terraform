terraform {  
  backend "azurerm" {
  resource_group_name  = "TerraformRG"
  storage_account_name = "terraformstgavi1"
  container_name       = "terraformcontainer"
  key                  = "terraform.tfstate"
  }
}

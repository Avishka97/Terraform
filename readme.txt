https://techdufus.com/powershell/2021/05/31/testing-teraform-iac-with-pester-unit-tests.html
Please create the below resource before runinig the pipeline
terraform {  
  backend "azurerm" {
  resource_group_name  = "TerraformRG"
  storage_account_name = "terraformstgavi1"
  container_name       = "terraformcontainer"
  key                  = "terraform.tfstate"
  }
}

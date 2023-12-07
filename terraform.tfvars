prefix = "Terraform"

resourcegroup = "TerraformRG"

location = "EastUS"

resource_group_name = "Terraform-Resourcegroup"

vnet = {
  vms = {
    vnet_name = "Terraform-virtualnetwork"
    address_space = ["10.0.0.0/16"]
  }
}

subnet = {
  vms = {
    subnet_name      = "Terraform_subnet"
    address_prefixes = ["10.0.2.0/24"]
  }
}

admin_username = "Avishka"

admin_password = "Avi0766566578"

vm1_name = "Terraform-VM"

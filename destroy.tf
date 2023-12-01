# Destruction of all resources
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "null_resource" "destroy_resources" {
  triggers = {
    destroy = timestamp()
  }

  provisioner "local-exec" {
    command = "terraform destroy -auto-approve"
  }
}

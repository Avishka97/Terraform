resource "null_resource" "destroy_resources" {
  triggers = {
    destroy = timestamp()
  }

  provisioner "local-exec" {
    command = "terraform destroy -auto-approve"
  }
}

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  type = string
  description = "The prefix which should be used for all resources in this example"
}

variable "resourcegroup" {
  type = string
  description = "The resources group in this example"
}

variable "location" {
  type = string
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  type        = string
  description = "Declare the resource group for this environment"
}

variable "vnet" {
  type = object({
    address_space = list(string)
  })
}

variable "subnet" {
  type = map(object({
    subnet_name      = string
    address_prefixes = list(string)
  }))
  description = "Provide an object with the subnet type name and ip range"
}

variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
  sensitive   = false
}

variable "admin_password" {
  type        = string
  description = "Password must meet Azure complexity requirements"
  sensitive   = true
}

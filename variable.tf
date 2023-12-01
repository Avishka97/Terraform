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

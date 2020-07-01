/*
* Copyright (c) 2019, 2020, Oracle and/or its affiliates. 
 */

# OCI Service
variable "compartment_id" {
  description = "Compartment OCID where the VCN is created."
}

variable "vcn_cidr" {
  default = "10.1.0.0/16"
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
}

variable "dns_label" {
  description = "DNS Label for the vcn"
}

variable "create_private_subnet" {
  default = false
}

variable "network_enabled" {
  default = true
}

variable "bastion_enabled" {
  default = true
}


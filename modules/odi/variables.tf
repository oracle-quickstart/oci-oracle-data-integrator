/*
* Copyright (c) 2019, 2020, Oracle and/or its affiliates. 
 */

variable "image_id" {
  description = "The OCID of the Essbase node image"
}

variable "default_image_ids" {
  type = map(string)

  # essbase-19.3.0.0.0.247-1907022202
  default = {
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaazwuvyrlyxw5kfuuqa4gnlobuenamwjqdka6jckbwlx5td65dsva"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaaijye7ik2byo2nt2cddgb7i3qn6vi73dud7gj2maqg5xnghkx44ia"
  }
}

# OCI Service
variable "compartment_id" {
  description = "Target compartment OCID to deploy the essbase resources."
}

variable "region" {
  description = "Region"
}

variable "availability_domain" {
  description = "The availability domain for the Essbase node."
}

variable "subnet_id" {
  description = "The subnet id for the Essbase node."
}

variable "node_count" {
  description = "The number of nodes to create.  Only supports up to 1 node."
  default     = 1
}

variable "node_hostname_prefix" {
  description = "The hostname for the ODI node"
  default     = "odiinst"
}

variable "display_name_prefix" {
  description = "Display name prefix for the resources created."
}

variable "shape" {
  description = "Instance shape for the node instance to use."
  default     = "VM.Standard2.1"
}

variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address. Default 'true' assigns a public IP address."
  default     = true
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance."
}

variable "ssh_private_key" {
  description = "Private key to be used to access this instance"
}

variable "odi_vnc_password" {
  description = "VNC password for the ODI instance"
}

// Bastion host settings
variable "bastion_host" {
  default = ""
}

variable "adw_instance" {
  default = ""
}

variable "adw_username" {
  default = "admin"
}

variable "adw_password" {
  default = ""
}

variable "odi_password" {
  default = ""
}

variable "odi_schema_prefix" {
  default = ""
}

variable "odi_schema_password" {
  default = ""
}

variable "adw_creation_mode" {
  default = ""
}

variable "embedded_db" {
  default = false
}

variable "studio_mode" {
  default = "Web"
}

variable "db_tech" {
  default = "MYSQL"
}

variable "studio_name" {
  default = "ODI Studio"
}


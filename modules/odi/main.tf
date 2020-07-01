/*
* Copyright (c) 2019, 2020, Oracle and/or its affiliates. 
 */

// Random suffix to make things unique
resource "random_string" "instance_uuid" {
  length  = 4
  lower   = true
  upper   = false
  special = false
  number  = true
}

data "oci_core_subnet" "application" {
  subnet_id = var.subnet_id
}

data "template_file" "bootstrap" {
  template = file("${path.module}/userdata/odi-bootstrap.tpl")
  vars = {
    odi_vnc_password    = var.odi_vnc_password
    adw_instance        = var.adw_instance
    adw_username        = var.adw_username
    adw_password        = var.adw_password
    odi_password        = var.odi_password
    odi_schema_prefix   = var.odi_schema_prefix
    odi_schema_password = var.odi_schema_password
    adw_creation_mode   = var.adw_creation_mode
    embedded_db         = var.embedded_db
    studio_mode         = var.studio_mode
    db_tech             = var.db_tech
    studio_name         = var.studio_mode != "ADVANCED" ? "ODI Web Studio Administrator" : "ODI Studio"
  }
}

resource "oci_core_instance" "odi" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.display_name_prefix}-node-1"
  shape               = var.shape

  create_vnic_details {
    subnet_id = var.subnet_id

    # Temporary until we figure out how to update all of the metadata in the right order
    assign_public_ip = var.assign_public_ip
    hostname_label   = data.oci_core_subnet.application.dns_label != "" ? format("oracle-odi-inst-%s", random_string.instance_uuid.result) : var.node_hostname_prefix
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64encode(data.template_file.bootstrap.rendered)
  }

  timeouts {
    create = "60m"
  }

  connection {
    host         = var.assign_public_ip ? oci_core_instance.odi.public_ip : oci_core_instance.odi.private_ip
    private_key  = var.ssh_private_key
    type         = "ssh"
    user         = "opc"
    timeout      = "30m"
    bastion_host = var.bastion_host
  }

  preserve_boot_volume = false
}


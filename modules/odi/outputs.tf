/*
* Copyright (c) 2019, 2020, Oracle and/or its affiliates. 
 */

output "node_name" {
  value = oci_core_instance.odi.display_name
}

output "node_id" {
  value = oci_core_instance.odi.id
}

output "node_public_ip" {
  value = oci_core_instance.odi.public_ip
}

output "node_private_ip" {
  value = oci_core_instance.odi.private_ip
}


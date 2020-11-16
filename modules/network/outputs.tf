/*
* Copyright (c) 2019, 2020, Oracle and/or its affiliates. 
 */
locals {
  empty_list = [[""]]
}

output "application_subnet_id" {
  value = join(",", oci_core_subnet.application.*.id)
}

output "bastion_subnet_id" {
  value = join(",", oci_core_subnet.bastion.*.id)
}

output "vcn_id" {
  value = join(",", oci_core_vcn.vcn.*.id)
}


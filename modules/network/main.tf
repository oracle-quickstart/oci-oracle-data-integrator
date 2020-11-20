/*
* Copyright (c) 2019, 2020, Oracle and/or its affiliates. 
 */

locals {
  // If VCN is /16, each tier will get /20
  dmz_tier_prefix = cidrsubnet(var.vcn_cidr, 4, 0)
  app_tier_prefix = cidrsubnet(var.vcn_cidr, 4, 1)
  db_tier_prefix  = cidrsubnet(var.vcn_cidr, 4, 2)

  app_subnet_cidr     = cidrsubnet(local.app_tier_prefix, 4, 1)
  lb_subnet_cidr      = cidrsubnet(local.dmz_tier_prefix, 4, 1)
  bastion_subnet_cidr = cidrsubnet(local.dmz_tier_prefix, 4, 2)
  db_subnet_cidr      = cidrsubnet(local.db_tier_prefix, 4, 1)

  all_cidr = "0.0.0.0/0"
}

# ------------------------------------
resource "oci_core_vcn" "vcn" {
  count          = var.network_enabled != 0 ? 1 : 0
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-vcn"
  dns_label      = var.dns_label
}

resource "oci_core_internet_gateway" "internet_gateway" {
  count          = var.network_enabled != 0 ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-gateway"
  vcn_id         = oci_core_vcn.vcn[0].id
}

data "oci_core_services" "test_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "service_gateway" {
  count          = var.network_enabled != 0 ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-service-gateway"
  vcn_id         = oci_core_vcn.vcn[0].id

  services {
    service_id = data.oci_core_services.test_services.services[0]["id"]
  }
}

resource "oci_core_nat_gateway" "nat_gateway" {
  count          = var.create_private_subnet != 0 && var.network_enabled != 0 ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.display_name_prefix}-nat-gateway"
}

# Bastion
resource "oci_core_security_list" "bastion" {
  count          = var.create_private_subnet != 0 && var.network_enabled != 0 ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.display_name_prefix}-bastion-security-list"

  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_cidr
  }

  ingress_security_rules {
    protocol  = "6" // tcp
    source    = local.all_cidr
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    // Allow all outbound traffic
    destination      = local.app_subnet_cidr
    destination_type = "CIDR_BLOCK"
    protocol         = "6"

    tcp_options {
      // These values correspond to the destination port range.
      min = 22
      max = 22
    }
  }
}

resource "oci_core_subnet" "bastion" {
  count = var.create_private_subnet != 0 && var.network_enabled != 0 ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.display_name_prefix}-bastion-subnet"

  cidr_block = local.bastion_subnet_cidr

  security_list_ids = [
    oci_core_security_list.bastion[0].id,
  ]

  dhcp_options_id = oci_core_vcn.vcn[0].default_dhcp_options_id
  dns_label       = "bastion"
}

resource "oci_core_route_table" "bastion" {
  count          = var.create_private_subnet != 0 && var.network_enabled != 0 ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.display_name_prefix}-bastion-route-table"

  route_rules {
    destination       = local.all_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway[0].id
  }
}

resource "oci_core_route_table_attachment" "bastion" {
  count          = var.create_private_subnet != 0 && var.network_enabled != 0 ? 1 : 0
  subnet_id      = oci_core_subnet.bastion[0].id
  route_table_id = oci_core_route_table.bastion[0].id
}

# Application
resource "oci_core_security_list" "application" {
  count          = var.network_enabled != 0 ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.display_name_prefix}-app-security-list"

  ingress_security_rules {
    // Allow inbound traffic to WLS ports
    protocol  = "6" // tcp
    source    = local.lb_subnet_cidr
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = "80"
      max = "80"
    }
  }

  ingress_security_rules {
    // Allow inbound ssh traffic for now...
    protocol  = "6" // tcp
    source    = var.create_private_subnet ? local.bastion_subnet_cidr : local.all_cidr
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    // allow inbound icmp traffic of a specific type
    protocol  = 1
    source    = local.all_cidr
    stateless = false

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    // allow inbound icmp traffic of a specific type
    protocol  = "all"
    source    = local.all_cidr
    stateless = false
  }

  egress_security_rules {
    // Allow all outbound traffic
    destination      = local.all_cidr
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
}

resource "oci_core_subnet" "application" {
  count          = var.network_enabled != 0 ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.display_name_prefix}-app-subnet"

  cidr_block = local.app_subnet_cidr

  security_list_ids = [
    oci_core_security_list.application[0].id,
  ]

  dhcp_options_id = oci_core_vcn.vcn[0].default_dhcp_options_id
  dns_label       = "app"

  prohibit_public_ip_on_vnic = var.create_private_subnet ? true : false 
}

resource "oci_core_route_table" "application-public" {
  count          = var.create_private_subnet == false && var.network_enabled ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.display_name_prefix}-app-public-route-table"

  route_rules {
    destination       = local.all_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway[0].id
  }
}

resource "oci_core_route_table_attachment" "application-public" {
  count          = var.create_private_subnet == false && var.network_enabled ? 1 : 0
  subnet_id      = oci_core_subnet.application[0].id
  route_table_id = oci_core_route_table.application-public[0].id
}

resource "oci_core_route_table" "application-private" {
  count          = var.create_private_subnet && var.network_enabled ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn[0].id
  display_name   = "${var.display_name_prefix}-app-private-route-table"

  route_rules {
    destination       = local.all_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway[0].id
  }
}

resource "oci_core_route_table_attachment" "application-private" {
  count          = var.create_private_subnet && var.network_enabled  ? 1 : 0
  subnet_id      = oci_core_subnet.application[0].id
  route_table_id = oci_core_route_table.application-private[0].id
}


variable "enabled" {
  default = false
}

variable "compartment_id" {
}

variable "region" {
}

variable "display_name_prefix" {
}

variable "availability_domain" {
}

variable "instance_shape" {
  default = "VM.Standard2.1"
}

variable "ssh_authorized_keys" {
}

variable "subnet_id" {
  description = "The subnet id for the bastion node."
}

/*
* Using https://docs.cloud.oracle.com/iaas/images/image/66379f54-edd0-4294-895f-47291a3eb4ed/
* Oracle-provided image = Oracle-Linux-7.6-2019.02.20-0
*
* Also see https://docs.us-phoenix-1.oraclecloud.com/images/ to pick another image in future.
*/
variable "bastion_instance_image_ocid" {
  type = map(string)

  default = {
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaacss7qgb6vhojblgcklnmcbchhei6wgqisqmdciu3l4spmroipghq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaannaquxy7rrbrbngpaqp427mv426rlalgihxwdjrz3fr2iiaxah5a"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa527xpybx2azyhcz2oyk6f4lsvokyujajo73zuxnnhcnp7p24pgva"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaarruepdlahln5fah4lvm7tsf4was3wdx75vfs6vljdke65imbqnhq"
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaa7ac57wwwhputaufcbf633ojir6scqa4yv6iaqtn3u64wisqd3jjq"
  }
}


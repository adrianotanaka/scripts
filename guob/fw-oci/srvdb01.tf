resource "oci_core_instance" "srvdb01_instance" {
  #Required
  availability_domain = "${var.ad}"
  compartment_id      = "${var.compartimento}"
  shape               = "VM.Standard.E2.1"
  display_name        = "srvdb01"

  create_vnic_details {
    display_name           = "srvdb01-lan"
    assign_public_ip       = "false"
    private_ip             = "${var.ip_interno_srvdb01}"
    skip_source_dest_check = "true"
    subnet_id              = "${oci_core_subnet.subnet_priv.id}"

  }
  metadata = {
    ssh_authorized_keys = "${var.instance_console_connection_public_key}"
  }
  source_details {
    #Required
    source_id   = "${var.oracle_linux_6}"
    source_type = "image"

    #Optional
    boot_volume_size_in_gbs = "50"
  }
  preserve_boot_volume = false
}


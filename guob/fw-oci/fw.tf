resource "oci_core_instance" "fw_instance" {
  #Required
  availability_domain = "${var.ad}"
  compartment_id      = "${var.compartimento}"
  shape               = "${var.shape}"
  display_name        = "PFSENSE-TERRAFORM"

  create_vnic_details {


    display_name           = "PFSENSE-TERRAFORM"
    assign_public_ip       = "false"
    private_ip             = "${var.ip_interno_fw}"
    skip_source_dest_check = "true"
    subnet_id              = "${oci_core_subnet.subnet_pub.id}"

  }

  source_details {
    #Required
    source_id   = "${var.custom_img}"
    source_type = "image"

    #Optional
    boot_volume_size_in_gbs = "50"
  }
  preserve_boot_volume = false
}

#Adiciona a segunda placa de rede na maquina
resource "oci_core_vnic_attachment" "fw_vnic_attachment" {
  #Required
  create_vnic_details {

    #Optional
    assign_public_ip       = "false"
    display_name           = "VNIC-LAN"
    private_ip             = "10.69.2.2"
    skip_source_dest_check = "true"
    subnet_id              = "${oci_core_subnet.subnet_priv.id}"
  }
  instance_id = "${oci_core_instance.fw_instance.id}"



}


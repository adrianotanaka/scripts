##Cria VCN
resource "oci_core_vcn" "vcn_guob" {
  #Required
  cidr_block     = "${var.vcn_cidr_block}"
  compartment_id = "${var.compartimento}"
  display_name   = "VCN_GUOB_TERRAFORM"
}

##Cria IGW

resource "oci_core_internet_gateway" "igw_wan" {
  #Required
  compartment_id = "${var.compartimento}"
  vcn_id         = "${oci_core_vcn.vcn_guob.id}"

  #Optional
  enabled      = "true"
  display_name = "IGW-WAN"

}

##Cria reserva de IP para o FW

data "oci_core_vnic_attachments" "instance_vnics" {
  compartment_id = "${var.compartimento}"
  instance_id    = "${oci_core_instance.fw_instance.id}"
}

data "oci_core_vnic" "instance_vnic1" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.instance_vnics.vnic_attachments[0], "vnic_id")}"
}

data "oci_core_private_ips" "private_ips1" {
  vnic_id = "${data.oci_core_vnic.instance_vnic1.id}"
}

resource "oci_core_public_ip" "fw_ip_pub" {
  compartment_id = "${var.compartimento}"
  display_name   = "RESERVA-FIREWALL"
  lifetime       = "RESERVED"
  private_ip_id  = "${lookup(data.oci_core_private_ips.private_ips1.private_ips[0], "id")}"
}


data "oci_core_public_ip" "test_oci_core_public_ip_by_private_ip_id" {
  private_ip_id = "${lookup(data.oci_core_private_ips.private_ips1.private_ips[0], "id")}"
}

output "ip_pub_fw" {
  value = "${oci_core_public_ip.fw_ip_pub.ip_address}"

}

##Cria Tabelas de rota

resource "oci_core_route_table" "rt_wan" {
  compartment_id = "${var.compartimento}"
  vcn_id         = "${oci_core_vcn.vcn_guob.id}"


  display_name = "RT-WAN"
  route_rules {
    #Required
    network_entity_id = "${oci_core_internet_gateway.igw_wan.id}"

    #Optional
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}



data "oci_core_vnic" "instance_vnic2" {
  vnic_id = "${element(data.oci_core_vnic_attachments.instance_vnics.vnic_attachments.*.vnic_id, 1)}"
}

data "oci_core_private_ips" "private_ips2" {
  vnic_id = "${data.oci_core_vnic.instance_vnic2.id}"
}


resource "oci_core_route_table" "rt_lan" {
  compartment_id = "${var.compartimento}"
  vcn_id         = "${oci_core_vcn.vcn_guob.id}"


  display_name = "RT-LAN"
  route_rules {
    #Required
    network_entity_id = "${lookup(data.oci_core_private_ips.private_ips2.private_ips[0], "id")}"
    #Optional
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

  }

}



##Cria Subnet Publica

resource "oci_core_subnet" "subnet_pub" {
  #Required
  cidr_block                 = "${var.subnet_pub_cidr_block}"
  compartment_id             = "${var.compartimento}"
  vcn_id                     = "${oci_core_vcn.vcn_guob.id}"
  display_name               = "REDE-WAN"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = "${oci_core_route_table.rt_wan.id}"
  security_list_ids          = ["${oci_core_security_list.seclist_wan.id}"]

}

##Cria Subnet Privada


resource "oci_core_subnet" "subnet_priv" {
  #Required
  cidr_block                 = "${var.subnet_priv_cidr_block}"
  compartment_id             = "${var.compartimento}"
  vcn_id                     = "${oci_core_vcn.vcn_guob.id}"
  display_name               = "REDE-LAN"
  route_table_id             = "${oci_core_route_table.rt_lan.id}"
  prohibit_public_ip_on_vnic = "true"
  security_list_ids          = ["${oci_core_security_list.seclist_lan.id}"]

}

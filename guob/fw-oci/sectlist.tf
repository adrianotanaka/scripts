resource "oci_core_security_list" "seclist_wan" {
    #Required
    compartment_id = "${var.compartimento}"
    vcn_id = "${oci_core_vcn.vcn_guob.id}"


    display_name = "SEC-LIST-WAN"
    egress_security_rules {
        #Required
        destination = "0.0.0.0/0"
        protocol = "all"

    }

    ingress_security_rules {
        #Required
        protocol = "all"
        source = "0.0.0.0/0"
       
}
}


resource "oci_core_security_list" "seclist_lan" {
    #Required
    compartment_id = "${var.compartimento}"
    vcn_id = "${oci_core_vcn.vcn_guob.id}"


    display_name = "SEC-LIST-LAN"
    egress_security_rules {
        #Required
        destination = "0.0.0.0/0"
        protocol = "all"

    }

    ingress_security_rules {
        #Required
        protocol = "all"
        source = "0.0.0.0/0"
       
}
}
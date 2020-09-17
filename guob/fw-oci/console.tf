resource "oci_core_instance_console_connection" "fw_instance_console_connection" {
  #Required
  instance_id = "${oci_core_instance.fw_instance.id}"
  public_key  = "${var.instance_console_connection_public_key}"
}

data "oci_core_instance_console_connections" "fw_instance_console_connections" {
  #Required
  compartment_id = "${var.compartimento}"

  #Optional
  instance_id = "${oci_core_instance.fw_instance.id}"

}

output "linux_vnc" {
  value = "${oci_core_instance_console_connection.fw_instance_console_connection.vnc_connection_string}"
}

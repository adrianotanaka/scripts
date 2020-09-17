provider "oci" {
  version          = ">= 3.0.0"
  tenancy_ocid = "ocid1.tenancy.oc1..XXXXXXXXXXXXXXXX"
  user_ocid = "ocid1.user.oc1..XXXXXXXXXXXXXXXX"
  fingerprint = "XXXXXXXXXXXXXXXX"
  private_key_path = "C:\\path\\key.pem"
  region = "sa-saopaulo-1"
}

variable "compartimento" {
  default = "ocid1.compartment.oc1..XXXXXXXXXXXXXXXX"
}

variable "ad" {
  default = "SckX:SA-SAOPAULO-1-AD-1"
}

variable "shape" {

  default="VM.Standard2.1"
}

##Variaveis de rede
variable "vcn_cidr_block" {

    default="10.69.0.0/16"
}

variable "subnet_pub_cidr_block" {

default="10.69.1.0/28"

}

variable "subnet_priv_cidr_block" {

default="10.69.2.0/24"
}

variable "ip_interno_fw" {

default="10.69.1.2"
}

variable "ip_interno_srvdb01" {

default="10.69.2.3"
}


variable "custom_img" {
default ="ocid1.image.oc1.sa-saopaulo-1.XXXXXXXXXXXXXXXX"

}

variable "instance_console_connection_public_key" {

  default="XXXXXXXXXXXXXXXX"
}

variable "oracle_linux_6"{

  default="ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaqiwopxdrqyvsdyv3ylfboqx2ojb7dptf3wlty2yrc43xbpkonenq"
}
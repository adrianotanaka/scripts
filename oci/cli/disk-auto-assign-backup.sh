#!/bin/bash
#This script will enable Gold backup policy to all boot and block volume of an region/compartment
#Change the bellow variables and run the script
#If your disk already have one policy assigned this will be changed to Gold
#More info here: https://docs.cloud.oracle.com/en-us/iaas/Content/Block/Tasks/schedulingvolumebackups.htm#Oracle

OCI_AD="jJiL:SA-SAOPAULO-1-AD-1"
OCI_COMPARTMENT="ocid1.compartment.oc1..XXXXXXXXX"

#Return Gold policy ocid

funct_get_policy(){

OCI_POL_OCID=$(oci bv volume-backup-policy list | jq -r '.data[] | select(."display-name"|contains("gold"))' | jq -r '.id')

}

funct_boot_vol (){

#Create a file with all boot volume ocid
oci bv boot-volume list --availability-domain ${OCI_AD} -c  ${OCI_COMPARTMENT} | jq -r '.data[].id' > boot-vol.txt


while IFS="" read -r p || [ -n "$p" ]
do
  printf 'Seeting backup policy for %s\n' "$p"
  oci bv volume-backup-policy-assignment create  --asset-id  $p  --policy-id ${OCI_POL_OCID}
done < boot-vol.txt

}

funct_block_vol (){
#Create a file with all block volume ocid
oci bv volume list  -c ${OCI_COMPARTMENT} | jq -r '.data[].id' > block-vol.txt

while IFS="" read -r p || [ -n "$p" ]
do
  printf 'Seeting backup policy for %s\n' "$p"
  oci bv volume-backup-policy-assignment create  --asset-id  $p  --policy-id ${OCI_POL_OCID}
done < block-vol.txt

}

funct_get_policy
funct_boot_vol
funct_block_vol

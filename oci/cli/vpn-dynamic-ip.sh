#!/bin/bash 
#####################################################################
## This script get the Public IP from machine that is running and create a VPN and all related resources
## You will need jq and dig installed and oci-cli configured
## You will need VCN and DRG previously configured
## Edit func_vars with yout environment information
## For security purpose the script will exit if a CPE with the same IP was created by other tool than this script
## This script will create two files on the working directory to control the created resources
## DONT PUT YOUR EXISTING RESOURCES ID (ocid) INSIDE THE FILES OR THE SCRIPT WILL DELETE THEN
## Sugested configuration:
## 00 00 * * * /script-path/oci/vpn-random-ip/vpn-dynamic-ip.sh > /script-path/oci/vpn-random-ip/vpn-dynamic.log 2>&1
## Feel free to get in touch with me at adriano.tanakaa@gmail.com or adriano.tanaka@accerte.com.br
## To do:
## Notify changes trought e-mail



func_vars () {

var_compartment="ocid1.tenancy.xxxxxx" #Your compartment ocid
var_drg="ocid1.drg.oc1.xxxxxxxx" #Your drg ocid
var_routes=""'["10.0.0.0/16"]'"" #Your onp routes
var_list="10.0.0.0/16" #The same of route
var_vcnd_id="ocid1.xxxxxxxxx" #Your VCN ocid
var_dev_name="random" #Name of created resource, reused on all resources

}

func_get_pub_ip (){

if which dig > /dev/null  2>&1; then
	PUB_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
else
    echo "dig not found!"
	exit 1;
fi

}

func_exists () {
existe=$(oci network cpe list -c $var_compartment | jq '.data[]."ip-address" | contains("'$PUB_IP'")')

if [[ $existe == *"true"* ]]
	then
	echo "You already have an CPE with this IP"
	echo "delete this before runing the script!"
	exit 1
else 
	echo "Running the script!"
fi
}


func_create_cpe () {

exec_create_cpe=$(oci network cpe create --display-name cpe-$var_dev_name --ip-address $PUB_IP -c ${var_compartment} | jq '.data')

export get_cpe_ocid=$(jq -rc '."id"' <<< "${exec_create_cpe}")
echo "#************************************************************************"
echo $get_cpe_ocid >> $PWD/cpe_list
echo "Your CPE ocid is: " $get_cpe_ocid
echo "#************************************************************************"
}

func_create_ipsec () {
echo "Creating IPSEC connection"
exec_create_ipsec=$(oci network ip-sec-connection create --display-name vpn-$var_dev_name --static-routes $var_routes --cpe-id $get_cpe_ocid --drg-id ${var_drg} -c ${var_compartment} --wait-for-state AVAILABLE | jq '.data') #--wait-for-state AVAILABLE

echo "#************************************************************************"
export get_ipsec_ocid=$(jq -rc '."id"' <<< "${exec_create_ipsec}")
echo "#************************************************************************"
echo $get_ipsec_ocid >> $PWD/ipsec_list
echo "IPSEC OCID: " $get_ipsec_ocid
echo "#************************************************************************"


}


func_return_ipsec_config () {

exec_ipsec_config=$(oci network ip-sec-connection get-config --ipsc-id $get_ipsec_ocid | jq  -r '.data.tunnels' ) #$get_ipsec_ocid )  #| jq '.data')
echo "#************************************************************************"
echo "Tunel info: "

jq  <<< "${exec_ipsec_config}"

}

func_sec_list () {
echo "Adjusting Security List..."
oci network security-list create -c $var_compartment --egress-security-rules '[{"destination": "'"$var_list"'", "protocol": "6", "isStateless": false, "tcpOptions": {"destinationPortRange": {"max": 65535, "min": 1}, "sourcePortRange": {"max": 65535, "min": 1}}}]' --ingress-security-rules '[{"source": "'"$var_list"'", "protocol": "6", "isStateless": false, "tcpOptions": {"destinationPortRange": {"max": 65535, "min": 1}, "sourcePortRange": {"max": 65535, "min": 1}}}]' --vcn-id $var_vcnd_id > /dev/null 

echo "Done"

}

func_route () {

oci network route-table create -c $var_compartment --route-rules '[{"cidrBlock":"'"$var_list"'","networkEntityId":"'$var_drg'"}]' --vcn-id $var_vcnd_id > /dev/null 2>&1

}


func_clean_up () {
echo "Deleting previously created ipsec ..."
while read p; do
  echo "Deleting $p"
        oci network ip-sec-connection  delete --ipsc-id   $p --force --wait-for-state TERMINATED > /dev/null
done <ipsec_list
echo ''> ipsec_list
echo "Done!"
echo " "
echo "Deleting previously created ipsec ..."
while read p; do
  echo "Deleting $p"
	oci network cpe delete --cpe-id  $p --force
done <cpe_list
echo ''>cpe_list
echo "Done!"
}


func_clean_up
echo "Starting the script"
func_vars
func_get_pub_ip
func_exists
echo "Your public IP is: " $PUB_IP
func_create_cpe
func_create_ipsec
func_sec_list
func_route
func_return_ipsec_config

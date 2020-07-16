#ps1_sysnative

#This script is usefull when you have a gateway other than default oci subnet (the first usable ip) and want to provide the configuration at boot machine.
#Don't forget to put the same ip address at Network options when deploying the VM 

#Change the values:

$MACHINE_IP='192.168.0.10'
$MACHINE_GW='192.168.0.1'
$MACHINE_MASK='255.255.255.0'
$PRIMARY_DNS='1.1.1.1'
$SECOND_DNS='8.8.4.4'

#This command define the static ip of the network interface
New-NetIPAddress -IPAddress $MACHINE_IP -DefaultGateway $MACHINE_GW -PrefixLength $MACHINE_MASK -InterfaceIndex (Get-NetAdapter).InterfaceIndex

#This command define the dns of the network interface
Set-DNSClientServerAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ServerAddresses $PRIMARY_DNS,$SECOND_DNS, etc.

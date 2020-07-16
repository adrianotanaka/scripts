#ps1_sysnative

#This command changes the opc (default user of OCI Windows machine password)
#Pay atention to password requirements 

#Change the bellow variable:

$USER_PASSWD='passw0rd'

net user opc $USER_PASSWD

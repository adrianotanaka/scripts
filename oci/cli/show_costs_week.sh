#!/bin/bash 
set -e
############################################################################################################################
#DISCLAIMER - This is not an official Oracle application, It does not supported by Oracle Support, It should NOT be used for  calculation purposes.
#The objective of this script is to get the cost of a compartment using OCI API
#You need to create a file called comp.lst inside /home/opc or adjust the COMPFILE variable
#The comp.lst file must follow the LEVEL,COMPARTMENT_NAME pattern
#For eg. if you have root/compA/compB and want to get the compA cost the level should be 2, for compB the level should be 3
#And you file should be similar to :
#2,compA
#3,compB
#This script was created by Adriano Tanaka (adriano.tanakaa@gmail.com), feel free to get in touch
#How to run:
#./show_costs_week.sh PROFILE_NAME ocid1.tenancy.oc1..XXX HOME_REGION
############################################################################################################################

source ~/.bash_profile

############################################################################################################################
#Variables
#By default this script get the cost based on last Sunday, if you need a bigger time frime, adjust the STARTDATE and ENDDATE variables
#Dont change the OCIPROFILE,TENANCYOCID and HOMEREGION variables


OCIPROFILE=$1
TENANCYOCID=$2
HOMEREGION=$3
STARTDATE=`date --date 'last Sunday - 7 days' "+%Y-%m-%d"`
ENDDATE=`date --date 'last Sunday' "+%Y-%m-%d"`
LOGFILE=/home/opc/show_costs_week_`date "+%Y-%m-%d"`.log
COMPFILE=/home/opc/comp.lst


getValue(){
if [[ ! -e ${COMPFILE} ]]; then
   echo "Missing ${COMPFILE} file, you must creat it before running this script"
   exit 1
fi 
IFS=,
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Profile: ${OCIPROFILE}  | Begin Date: ${STARTDATE} | End Date: ${ENDDATE}"  
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
while read -r LEVEL COMPARTNAME 
do
echo  "Compartment:  ${COMPARTNAME}"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

oci usage-api usage-summary request-summarized-usages --granularity DAILY --tenant-id ${TENANCYOCID} --group-by '[ "compartmentName", "compartmentDepth"]' --compartment-depth ${LEVEL} --time-usage-started "${STARTDATE}T00:00:00Z" --time-usage-ended "${ENDDATE}T00:00:00Z" --region ${HOMEREGION} --profile ${OCIPROFILE} --filter '{"operator":"AND","dimensions":[{"value":"'"$OCIPROFILE"'","key":"tenantName"},{"key": "compartmentName", "value": "'"${COMPARTNAME}"'"}],"tags":[],"filters":[]}' --query "data.items[*].{CompartName:\"compartment-name\",CompPath:\"compartment-path\",Inicio:\"time-usage-started\",Fim:\"time-usage-ended\",Valor:\"computed-amount\"  } | sort_by([], &CompartName)" --output table 

#TODO : Run the sum and the report in just on command


TOTALCOMP=$(oci usage-api usage-summary request-summarized-usages --granularity DAILY --tenant-id ${TENANCYOCID} --group-by '[ "compartmentName", "compartmentDepth"]' --compartment-depth ${LEVEL} --time-usage-started "${STARTDATE}T00:00:00Z" --time-usage-ended "${ENDDATE}T00:00:00Z" --region ${HOMEREGION} --profile ${OCIPROFILE} --filter '{"operator":"AND","dimensions":[{"value":"'"$OCIPROFILE"'","key":"tenantName"},{"key": "compartmentName", "value": "'"${COMPARTNAME}"'"}],"tags":[],"filters":[]}' --query "data.items[*].{Valor:\"computed-amount\"  }  | sum ([].Valor)" )

printf "Total for $COMPARTNAME compartment: %.3f\n" "$TOTALCOMP"
done <${COMPFILE}
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}


getValue 2>&1 | tee -a  ${LOGFILE}

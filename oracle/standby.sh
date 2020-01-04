#!/bin/bash

#####################################
#Manual Standby
#First setup ssh trust between the two hosts
#You will need rsync installed on both servers
#Create an file on /home/oracle/scripts/ with the name env$ORACLE_SID.sh with enviroinment variables (ORACLE_HOME, ORACLE_SID,PATH)
#Create two tnsnames.ora entry:

#DB_PRD =
# (DESCRIPTION = 
#    (ADDRESS_LIST =
#         (ADDRESS = (PROTOCOL = TCP)(HOST = db-orig)(PORT = 1521))
#	    )
#	     (CONNECT_DATA =
#	        (SERVICE_NAME = dborcl)
#		 )
#		 )


#DB_STBY =
#  (DESCRIPTION = 
#     (ADDRESS_LIST =
#          (ADDRESS = (PROTOCOL = TCP)(HOST = db-dest)(PORT = 1521))
#	     )
#	      (CONNECT_DATA =
#	         (SERVICE_NAME = dborcl)
#		  )
#		  )




#After that, fill the variaveis() function with the correct information for your enviroinment
#Give execute permission: chmod +x standby.sh
#How to run the script: standby.sh ORACLE_SID 
#Created by Adriano Tanaka 12/15/2019 adriano.tanakaa@gmail.com


script_name=$(basename -- "$0")

if pidof -x "$script_name" -o $$ >/dev/null;then
   echo "An another instance of this script is already running!"
   exit 1
fi


export ORACLE_SID=$1
variaveis(){

	. /home/oracle/accerte/env$ORACLE_SID.sh

	echo "### Variaveis carregadas: "
	echo "### SID: " $ORACLE_SID
	echo "### ORIGEM: " $DIR_PRD
	echo "### DESTINO: " $DIR_STD
	echo "### IP PRD: " $IP_PRD
	echo "### IP STD: " $IP_STD
	echo "### RETENCAO: " $RETENCAO
}

rsync_prd(){

        rsync  -azvh $IP_PRD:$DIR_PRD/ $DIR_STD/ --partial-dir=$DIR_STD/partial/ --progress --ignore-existing  

}

cataloga() {

rman target=/ << EOF
RUN {
  catalog start with '\$DIR_STD' noprompt;
}
EXIT;
EOF


}


recupera_se(){

rman target=/ << EOF
RUN {
  recover database;
  }
EXIT;
EOF
}


recupera_ee(){

rman target=/ << EOF
RUN {
  allocate CHANNEL c1 DEVICE TYPE DISK;
  allocate CHANNEL c2 DEVICE TYPE DISK;
  allocate CHANNEL c3 DEVICE TYPE DISK;
  allocate CHANNEL c4 DEVICE TYPE DISK;
  recover database;
  }
EXIT;
EOF
}

runsql () {
sqlplus -S /nolog << EOF
CONNECT $1 as sysdba;
whenever sqlerror exit sql.sqlcode;
SET      pagesize 0
SET      heading OFF
SET      feedback OFF
SET      verify OFF
set 	echo off
$2
exit;
EOF
}


compara () {
ULT_STBY=$(runsql sys/$SYS_PASSWD@DB_STBY  "select max (sequence#) from v\$archived_log where APPLIED='YES' ;")
ULT_PRD=$(runsql sys/$SYS_PASSWD@DB_PRD  "select max (sequence#) from v\$log_history;")

diferenca=$(($ULT_PRD-$ULT_STBY))
echo $diferenca


}


variaveis

echo ----------------------------------------------------------------
echo "### Iniciando recuperacao do do banco " $ORACLE_SID " " $DATA $HORA
echo "### Iniciando recuperacao do do banco " $ORACLE_SID " " $DATA $HORA >> $LOG_DIR/$LOG_FILE.log
echo ----------------------------------------------------------------
echo "### Copiando archives de " $IP_PRD:$DIR_PRD " "  $DATA $HORA
echo "### Copiando archives de " $IP_PRD:$DIR_PRD " "  $DATA $HORA >> $LOG_DIR/$LOG_FILE.log
rsync_prd >> $LOG_DIR/$LOG_FILE.log
echo ----------------------------------------------------------------
echo "### Catalogando archives copiados" " "  $DATA $HORA
echo "### Catalogando archives copiados" " "  $DATA $HORA >> $LOG_DIR/$LOG_FILE.log
echo ----------------------------------------------------------------
cataloga >> $LOG_DIR/$LOG_FILE.log
echo "### Aplicando archives " " "  $DATA $HORA
echo "### Aplicando archives " " "  $DATA $HORA  >> $LOG_DIR/$LOG_FILE.log
echo ----------------------------------------------------------------
recupera_se >> $LOG_DIR/$LOG_FILE.log
#recupera_ee >> $LOG_DIR/$LOG_FILE.log
echo "### Archives aplicados " " "  $DATA $HORA
echo "### Archives aplicados " " "  $DATA $HORA >> $LOG_DIR/$LOG_FILE.log
echo ----------------------------------------------------------------
echo "### Diferenca " $compara  " "  $DATA $HORA >> $LOG_DIR/$LOG_FILE.log
echo "### Diferenca " $compara  #" -- "  $DATA $HORA >> $LOG_DIR/$LOG_FILE.log
echo ----------------------------------------------------------------
compara >>  $LOG_DIR/$LOG_FILE.log
compara
echo ----------------------------------------------------------------


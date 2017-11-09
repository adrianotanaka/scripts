#!/bin/bash
#Criado por Adriano Tanaka adriano.tanakaa@gmail.com
#09-11-2017
#Pega tickets onde a ultima atualizacao foi a mais de 12h
#########################################################

export EMAIL=XXX@XXXXX
export USER_MYSQL=XXXXXx
export SENHA_MYSQL=XXXXXXXXXXX
DATA=`date +%d-%m-%Y`
HORA=`date +%H:%M:%S`


export TOTAL_TICKETS=$( mysql -u$USER_MYSQL -p$SENHA_MYSQL -e "SELECT
   count(distinct(t.id)) as ''
FROM
    glpi.glpi_tickets t
     join
    glpi.glpi_tickets_users u
    on t.id=u.tickets_id
     join
    glpi.glpi_users gu
    on gu.id=u.users_id
WHERE
 t.is_deleted = 'false'
 and t.status=2
 and u.type=2
 and t.date_mod <= date_sub(curdate(),INTERVAL '12:00' HOUR)
order by 1"  2>/dev/null)

#echo $TOTAL_TICKETS

export CORPO_EMAIL=$( mysql -u$USER_MYSQL -p$SENHA_MYSQL -H -e "SELECT
    CONCAT('http://URL_GLPI/glpi/front/ticket.form.php?id=',t.id) as TICKET ,t.name as NOME_DO_TICKET,t.date_mod as 'ATUALIZACAO',
    gu.firstname as RESPONSAVEL
FROM
    glpi.glpi_tickets t
    left join
    glpi.glpi_tickets_users u
    on t.id=u.tickets_id
    left join
    glpi.glpi_users gu
    on u.users_id=gu.id
WHERE
 t.is_deleted = 'false'
 and t.status=2
 and u.type=2
 and t.date_mod <= date_sub(curdate(),INTERVAL '12:00' HOUR)
order by 1" 2>/dev/null)

#echo $CORPO_EMAIL

export RODAPE="<ul>
  <li>-</li>
  <li>-</li>
  <li>-</li>
</ul>  "


echo -e "<strong><h2>Favor verificar o motivo dos seguintes tickets não serem atualizados a mais de 12horas:</h2></strong>" \
"$RODAPE" \
"<br>$CORPO_EMAIL" \
"<br>Relatório gerado $DATA as $HORA "  | mutt -e "set content_type=text/html" -e " my_hdr From:USER" -s "$DATA IMPORTANTE - Existem $TOTAL_TICKETS  tickets com mais de 12 horas sem atualização  " $EMAIL

#!/bin/bash
### You need mutt installed and configured on the server to send the emails
### To run: ./bkp-report.sh AD COMPARTMENT_OCID COMPARTMENT_NAME EMAIL
### Created by Adriano Tanaka adriano.tanakaa@gmail.com
### Don't change the execution order!
### 25/02/2021

OCI_AD=$1
OCI_COMPARTMENT=$2
COMPARTMENT_NAME=$3
DATA=$(date +%d-%m-%Y)
HORA=$(date +%H:%M:%S)
EMAIL=$4

list_boot_vol() {
    oci bv boot-volume list --availability-domain ${OCI_AD} -c ${OCI_COMPARTMENT} | jq -r '.data[] | [(.id+","+."display-name")] | @tsv' >boot-vol.txt
}

list_block_vol() {
    oci bv volume list -c ${OCI_COMPARTMENT} | jq -r '.data[] | [(.id+","+."display-name")] | @tsv' >block-vol.txt
}

list_bkp_boot_html() {
    echo "<!DOCTYPE html>
            <html>
            <head>
            <meta http-equiv=\"Content-Type\" content=\"text/html charset=utf-8\" />
            <title>Backups no compartimento $COMPARTMENT_NAME</title>

            <style type=\"text/css\">
                    .alert {
                     position: relative;
                     padding: 1rem 1rem;
                     margin-bottom: 1rem;
                     border: 1px solid transparent;
                     border-radius: .25rem;
                     width: 100%
                    }

                    .alert-success {
                      color: #0f5132;
                      background-color: #d1e7dd;
                      border-color: #badbcc;
                      width: 100%
                    }

                    .alert-danger {
                      color: #842029;
                      background-color: #f8d7da;
                      border-color: #f5c2c7;
                      width: 100%
                    }
                    .card {
                      position: relative;
                      display: flex;
                      flex-direction: column;
                      word-wrap: break-word;
                      background-color: #fff;
                      background-clip: border-box;
                      border-radius: .25rem;
                      width: 100%
                    }

                    .card-body {
                      flex: 1 1 auto;
                      padding: 1rem 1rem
                    }

                    root {
                         --bs-blue: #0d6efd;
                         --bs-indigo: #6610f2;
                         --bs-purple: #6f42c1;
                         --bs-pink: #d63384;
                         --bs-red: #dc3545;
                         --bs-orange: #fd7e14;
                         --bs-yellow: #ffc107;
                         --bs-green: #198754;
                         --bs-teal: #20c997;
                         --bs-cyan: #0dcaf0;
                         --bs-white: #fff;
                         --bs-gray: #6c757d;
                         --bs-gray-dark: #343a40;
                         --bs-primary: #0d6efd;
                         --bs-secondary: #6c757d;
                         --bs-success: #198754;
                         --bs-info: #0dcaf0;
                         --bs-warning: #ffc107;
                         --bs-danger: #dc3545;
                         --bs-light: #f8f9fa;
                         --bs-dark: #212529;
                         --bs-gradient: linear-gradient(180deg, rgba(255, 255, 255, 0.15), rgba(255, 255, 255, 0))
                       }
                           .bg-body {
                         background-color: #fff !important
                       }

                       body {
                         margin: 0;
                         font-family: var(--bs-font-sans-serif);
                         font-size: 1rem;
                         font-weight: 400;
                         line-height: 1.5;
                         color: #212529;
                         background-color: #fff;
                         -webkit-text-size-adjust: 100%;
                         -webkit-tap-highlight-color: transparent
                       }
                        .tg  {border-collapse:collapse;border-color:#9ABAD9;border-spacing:0;}
                        .tg td{background-color:#EBF5FF;border-color:#9ABAD9;border-style:solid;border-width:1px;color:#444;
                          font-family:Arial, sans-serif;font-size:14px;overflow:hidden;padding:10px 5px;word-break:normal;}
                        .tg th{background-color:#409cff;border-color:#9ABAD9;border-style:solid;border-width:1px;color:#fff;
                          font-family:Arial, sans-serif;font-size:14px;font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
                        .tg .tg-0pky{border-color:inherit;text-align:left;vertical-align:top}
                        @media screen and (max-width: 767px) {.tg {width: auto !important;}.tg col {width: auto !important;}.tg-wrap {overflow-x: auto;-webkit-overflow-scrolling: touch;}}

                        .h1,.h2,.h3,.h4,.h5,.h6,h1,h2,h3,h4,h5,h6{
                            margin-top:0;
                            margin-bottom:.5rem;
                            font-weight:500;
                            line-height:1.2
                        }
                        .h1,h1{
                            font-size:calc(1.375rem + 1.5vw)
                        } </style><body>" >mail.html

    echo "<br><center><p class=\"h3\">Backups de discos de boot</p></center><br>" >>mail.html
    while IFS=',' read -r disk_id disk_name; do
        list_disk=$(oci bv boot-volume-backup list -c ${OCI_COMPARTMENT} --boot-volume-id ${disk_id} |
            jq -r '.data[] | [("<tr><td class=\"tg-0pky\">"+."display-name"+"</td><td class=\"tg-0pky\">"+."time-created"+"</td><td class=\"tg-0pky\">"+."expiration-time"+"</td><td class=\"tg-0pky\">"+."lifecycle-state"+"</td></tr>")]|@tsv')
        if [ $(echo -n "$list_disk" | wc -l) != 0 ]; then
            echo "<div class=\"card\"><div class=\"card-body\"><div class=\"alert alert-success\" role=\"alert\"><p><b>Disco:</b> $disk_name <br><b>OCID:</b> $disk_id <br><b>Quantidade de backups:</b> $(echo "$list_disk" | wc -l)</p></div>" >>mail.html
            echo "<table class=\"tg\">
            <tr>
              <th class=\"tg-0pky\">Backup</th>
              <th class=\"tg-0pky\">Criado em</th>
              <th class=\"tg-0pky\">Expira em</th>
              <th class=\"tg-0pky\">Status</th>
            </tr>
          </thead>
        <tbody>$list_disk</tbody>
        </table></div></div>" >>mail.html
        else
            echo "<div class=\"card\"><div class=\"card-body\"><p class=\"alert alert-danger\" role=\"alert\"> <b>Disco:</b> $disk_name <br><b style=\"color:red;\">OCID:</b> $disk_id <br><b style=\"color:red;\">Quantidade de backups:</b> $(echo -n "$list_disk" | wc -l)</p></div></div><br>" >>mail.html
        fi
    done <boot-vol.txt
}

list_bkp_vol_html() {
    echo "<br><center><p class=\"h3\">Backups de block volumes</p></center><br>" >>mail.html
    while IFS=',' read -r disk_id disk_name; do
        list_disk=$(oci bv backup list -c ${OCI_COMPARTMENT} --volume-id ${disk_id} | jq -r '.data[] | [("<tr><td>"+."display-name"+"</td><td>"+."time-created"+"</td><td>"+."expiration-time"+"</td><td>"+."lifecycle-state"+"</td></tr>")]|@tsv')
        if [ $(echo -n "$list_disk" | wc -l) != 0 ]; then
            echo "<div class=\"card\"><div class=\"card-body\"><div class=\"alert alert-success\" role=\"alert\"><p><b>Disco:</b> $disk_name <br><b>OCID:</b> $disk_id <br><b>Quantidade de backups:</b> $(echo "$list_disk" | wc -l)</p></div><br>" >>mail.html
            echo "<table class=\"tg\">
                  <tr>
                    <th class=\"tg-0pky\">Backup</th>
                    <th class=\"tg-0pky\">Criado em</th>
                    <th class=\"tg-0pky\">Expira em</th>
                    <th class=\"tg-0pky\">Status</th>
                  </tr>
                </thead>
                <tbody>$list_disk</tbody>
                </table></div></div>" >>mail.html
        else
            echo "<div class=\"card\"><div class=\"card-body\"><p class=\"alert alert-danger\" role=\"alert\"> <b>Disco:</b> $disk_name <br><b>OCID:</b> $disk_id <br><b>Quantidade de backups:</b> $(echo -n "$list_disk" | wc -l) </p></div></div><br>" >>mail.html
        fi
    done <block-vol.txt
    echo "<figure class=\"text-center\"><p class=\"h6\">Lista de discos e seus backups no compartimento $COMPARTMENT_NAME gerado em $DATA $HORA</p></figure>" >>mail.html
    echo "</body></html>" >>mail.html
}

send_mail() {
    cat mail.html | mutt -e "set content_type=text/html" -e " my_hdr From:bkp-report" -s "Backups do compartimento $COMPARTMENT_NAME $DATA" $EMAIL
}

list_boot_vol
list_bkp_boot_html
list_block_vol
list_bkp_vol_html
send_mail

DECLARE 
    c          utl_smtp.connection; 
    l_mailhost VARCHAR2 (64) := 'smtp.gmail.com'; -- Seu servidor de e-mail 
    l_from     VARCHAR2 (64) := 'adriano.tanakaa@gmail.com';     -- Conta que está mandando o e-mail 
    l_to       VARCHAR2 (64) := 'adriano.tanakaa@gmail.com';     -- Conta que vai receber o e-mail 
    l_subject  VARCHAR2 (64) := 'Mensagem de teste ';  -- Titulo do e-mail
    crlf       VARCHAR2(2) := utl_tcp.crlf; 
    corpo_mail VARCHAR2(32767); 
    l_boundary VARCHAR2(50) := '----=*#abc1234321cba#*='; 
	
BEGIN 
    c := utl_smtp.Open_connection(host => l_mailhost, port => 587, 
              wallet_path => 'file:/home/oracle/email_ssl/wallet_email', 
              wallet_password => 'Oracle123', 
         secure_connection_before_smtp => FALSE 
         ); 

    utl_smtp.Ehlo(c, 'smtp.gmail.com'); 
    utl_smtp.Starttls(c); 
    utl_smtp.Ehlo(c, 'smtp.gmail.com'); 
    utl_smtp.Auth(c, 'EMAIL', 'SENHA', utl_smtp.all_schemes); 
    utl_smtp.Mail (c, l_from); 
    utl_smtp.Rcpt (c, l_to); 
    utl_smtp.Open_data (c); 
    utl_smtp.Write_data (c, 'Date: ' 
                            || To_char (SYSDATE, 'DD-MON-YYYY HH24:MI:SS') 
                            || crlf); 
    utl_smtp.Write_data (c, 'From: ' 
                            || l_from 
                            || crlf); 

    utl_smtp.Write_data (c, 'Subject: ' 
                            || l_subject 
                            || SYSDATE 
                            || crlf); 

    utl_smtp.Write_data (c, 'To: ' 
                            || l_to 
                            || crlf); 

    utl_smtp.Write_data(c, 'MIME-Version: 1.0' 
                           || utl_tcp.crlf); 

    utl_smtp.Write_data(c, 'Content-Type: multipart/alternative; boundary="' 
                           || l_boundary 
                           || '"' 
                           || utl_tcp.crlf 
                           || utl_tcp.crlf); 

    utl_smtp.Write_data(c, 'Content-Type: text/html; charset="iso-8859-1"' 
                           || utl_tcp.crlf 
                           || utl_tcp.crlf); 

    utl_smtp.Write_data (c, '' 
                            || crlf); 

    corpo_mail := '<html>     <head>       <title>Você pode usar HTML em seus e-mails !!!</title>     </head>     <body>      <b> Você pode colocar um texto em negrito</b> <br>      <i> italico</i><br>      Entre outros !     </body>   </html>'; 

    utl_smtp.Write_raw_data (c, utl_raw.Cast_to_raw (utl_tcp.crlf || corpo_mail)); 

    utl_smtp.Close_data (c); 

    utl_smtp.Quit (c); 
EXCEPTION 
    WHEN utl_smtp.transient_error 
	OR 
	utl_smtp.permanent_error 
	THEN 
      utl_smtp.Quit(c); 

      Raise_application_error(-20001, 'Falha ao enviar e-mail devido ao seguite erro: ' 
      || SQLERRM); 
    WHEN OTHERS THEN 
      NULL; 
END; 

/ 

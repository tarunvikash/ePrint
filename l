● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Tue 2019-06-25 01:25:35 EDT; 13s ago
     Docs: man:httpd(8)
           man:apachectl(8)
  Process: 112497 ExecStop=/bin/kill -WINCH ${MAINPID} (code=exited, status=1/FAILURE)
  Process: 112493 ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND (code=exited, status=1/FAILURE)
 Main PID: 112493 (code=exited, status=1/FAILURE)

Jun 25 01:25:35 localhost.localdomain httpd[112493]: defined(@array) is deprecated at /home/eprint/code/Pinnacle/Reportindex.pm line 662.
Jun 25 01:25:35 localhost.localdomain httpd[112493]: (Maybe you should just omit the defined()?)
Jun 25 01:25:35 localhost.localdomain httpd[112493]: AH00526: Syntax error on line 60 of /etc/httpd/conf.d/perl.conf:
Jun 25 01:25:35 localhost.localdomain httpd[112493]: Bareword "ORA_RSET" not allowed while "strict subs" in use at /home/eprint/code/Pinnacle/Authorize/Banner.pm line 365.\nBareword "ORA_RSET" not allowed while "strict subs" in use at /home/eprint/code/Pinnacle/Authorize/Banner.pm line 367.\nCompilation failed in require at /home/eprint/cgi-bin/startup.pl line 167.\nCompilation failed in require at (eval 5) line 1.\n
Jun 25 01:25:35 localhost.localdomain systemd[1]: httpd.service: main process exited, code=exited, status=1/FAILURE
Jun 25 01:25:35 localhost.localdomain kill[112497]: kill: cannot find process ""
Jun 25 01:25:35 localhost.localdomain systemd[1]: httpd.service: control process exited, code=exited status=1
Jun 25 01:25:35 localhost.localdomain systemd[1]: Failed to start The Apache HTTP Server.
Jun 25 01:25:35 localhost.localdomain systemd[1]: Unit httpd.service entered failed state.
Jun 25 01:25:35 localhost.localdomain systemd[1]: httpd.service failed.

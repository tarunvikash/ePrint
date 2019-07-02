● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2019-07-01 04:44:07 EDT; 4s ago
     Docs: man:httpd(8)
           man:apachectl(8)
  Process: 113588 ExecStop=/bin/kill -WINCH ${MAINPID} (code=exited, status=1/FAILURE)
  Process: 113584 ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND (code=exited, status=1/FAILURE)
 Main PID: 113584 (code=exited, status=1/FAILURE)

Jul 01 04:44:07 localhost.localdomain httpd[113584]: defined(@array) is deprecated at /home/eprint/code/Pinnacle/Reportindex.pm line 662.
Jul 01 04:44:07 localhost.localdomain httpd[113584]: (Maybe you should just omit the defined()?)
Jul 01 04:44:07 localhost.localdomain httpd[113584]: AH00526: Syntax error on line 60 of /etc/httpd/conf.d/perl.conf:
Jul 01 04:44:07 localhost.localdomain httpd[113584]: Can't locate DBD/Oracle.pm in @INC (@INC contains: /home/eprint/code /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 . /etc/httpd) at /home/eprint/code/Pinnacle/Authorize/Banner.pm line 102.\nBEGIN failed--compilation aborted at /home/eprint/code/Pinnacle/Authorize/Banner.pm line 102.\nCompilation failed in require at /home/eprint/cgi-bin/startup.pl line 167.\nCompilation failed in require at (eval 5) line 1.\n
Jul 01 04:44:07 localhost.localdomain systemd[1]: httpd.service: main process exited, code=exited, status=1/FAILURE
Jul 01 04:44:07 localhost.localdomain kill[113588]: kill: cannot find process ""
Jul 01 04:44:07 localhost.localdomain systemd[1]: httpd.service: control process exited, code=exited status=1
Jul 01 04:44:07 localhost.localdomain systemd[1]: Failed to start The Apache HTTP Server.
Jul 01 04:44:07 localhost.localdomain systemd[1]: Unit httpd.service entered failed state.
Jul 01 04:44:07 localhost.localdomain systemd[1]: httpd.service failed.

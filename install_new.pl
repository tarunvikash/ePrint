#!/usr/bin/perl 

use strict;
use Getopt::Long;
use File::Slurp;
use FindBin qw($Bin);
use DBI;

my $installpath = "$Bin";
my $clear = `clear`;
my $user = '20eprint';
my $proc_oracle;

# get the processor architecture
my $proc = `uname -p`;
chop($proc);

if ($proc ne 'x86_64') {
    $proc = 'i686';
}

#print "proc = $proc \n";
#print "$clear \n";	

#&begmessage("	*****  Installing Redhat Packages  *****");
#&installpackages("$installpath/packages");

#&begmessage("	*****  Installing Perl Modules  *****");
#&installperlmodules("$installpath/perlmodules");

#&begmessage("	*****  Installing ePrint Groups  *****");
#&addeprintgroup("/usr/sbin/./groupadd");

#&begmessage("	*****  Installing ePrint User  *****");
#&eprint_user;

#&begmessage("	*****  Installing MySQL  *****");
#&installmysql("$installpath/mysql");

#&begmessage("	*****  Configuring MySQL  *****");
#&configmysql(); 

&begmessage("	*****  Installing Configiguration Files  *****");
&installconfig("$installpath/config");
exit;
#print "mysqld status:\n";
#system ( "systemctl status mariadb");
	
&begmessage("	*****  Creating prod database *****");
#&createprod();

&begmessage("	*****  Creating repository config table *****");
#&createmysqlrepositoryconf();

&begmessage("	*****  Creating security tables *****");
#&createmysqlsecurity();

&begmessage("	*****  Creating report config table *****");
#&createmysqlreportconf();

&begmessage("	*****  Creating disk usage table *****");
#&createmysqldiskusage();

&begmessage("	*****  Creating local defaults table *****");
#&createlocaldefaults("$installpath/localdefaults");

&begmessage("	*****  Creating scratch/*****");
#&createscratch();

&begmessage("	*****  Installing Banner ePrint rpm's  *****");
&installeprintrpms("$installpath/RPMS");

##### ePrint modules installation
#&begmessage("	*****  Installing Banner ePrint modules  *****");
#&installeprintmodules("$installpath" . "eprint");

##### ePrint demo rpms installation
#&begmessage("	*****  Installing Banner ePrint demo rpm's  *****");
#&installeprintdemorpms("$installpath/RPMS");

##### smarteprint rpms installation
#&begmessage("	*****  Export Complience  *****");
#&installsmarteprintrpms("$installpath/smarteprint");

###### Begin updated code 
#&begmessage("	*****  Installing post-build updates *****");
#&installpost_build("$installpath/post-build");

##### Begin add crontab entry 
#&begmessage("	*****  Add crontab entries *****");
#&addcrontabentry();

##### Setup time server
#&begmessage("   *****  Setting up time server *****");
#&setuptimeserver;

##### Begin backup install
#&begmessage("	*****  Configuring Backup  *****");
#&create_crontabentry;
#&create_logrotater;

##### Begin smarteprint gpg install
#&begmessage("	*****  Installing smarteprint gpg Modules  *****");
#&installgpg("$installpath/gpg");

##### Begin report encryption gpg install
#&begmessage("	*****  Installing report encryption gpg Modules  *****");
#&installreportgpg("$installpath/gpg");

##### Insert diskusage data
#&begmessage("   *****  Inserting diskusage data  *****");
#&insertdiskusage;

##### Setup super administrator password
#&begmessage("   *****  Setting up Super Admin password *****");
#&setupadmin;

##### Load the oracle client 
   #&begmessage("	*****  Installing Oracle Client  *****");
   #&install_oracle("$installpath/banner");


#print STDERR "\n\n Restarting the web server \n";
#system("service httpd restart");

##### Configuring services 
   #&begmessage("	*****  Configuring Services *****");
   #&config_services;

#&begmessage("\n		 ************ DONE ************ \n
#		*****  Installing Banner ePrint  *****\n ");
		
		
#&begmessage("	*****  Next Steps  *****");
#print STDERR " 1.) Local Default settings must be set to the client specifications: \n" .
#		"    WEBSERVER = hostname\n" .
#		"    EMAIL=  eprint" . "@" . "hostame\n" .
#		"    SFTP_USER =  setting\n"; 
#print STDERR " \n 2.) Reboot the server. \n" ;

############################ subprocedures

sub installpackages{
	my $path = "@_";
	my @files;
	my $file;

	system("rpm -Uhv $path/*$proc.rpm");

}


sub installperlmodules{
	my $path = "@_";

	system("rpm -Uhv --force @_/*$proc.rpm @_/*noarch.rpm");
	print "Done installing perl modules\n";
}


sub addeprintgroup{
	my $path = "@_";

	print "Adding eprint group\n";
	system("$path eprint");
	print "\n";

}

sub installmysql{
	my $path = "@_";
	
	system( "rpm -ihv --force $path/*$proc.rpm" );
	print "Done installing extra MySQL RPMS\n";
	
}

sub configmysql {		
	print "Configuring mysql \n\n";

	print "\n\nCreating the MySQL administrator \n\n";
	system ( "mysqladmin password redhat" );

	my $dbh;
	$dbh = DBI->connect( 'DBI:mysql:mysql', 'root', 'redhat')
		or die "Can't connect to DBI:mysql:mysql: $dbh->errstr\n";
		
	print "Creating the MySQL eprint user \n\n";
	my $ep_user = "GRANT ALL PRIVILEGES ON *.* TO 20eprint@\"localhost\" IDENTIFIED BY '20eprint' WITH GRANT OPTION ";
	my $sth = $dbh->prepare($ep_user);
	$sth->execute();
	$sth->finish;

	print "Removing the default users \n\n";	
	my $ep_user = "DELETE from user WHERE password = ''";
	my $sth2 = $dbh->prepare($ep_user);
	$sth2->execute();
	$sth2->finish;
	
	print "Removing the default test database \n\n";
	#my $drop_test = "Drop DATABASE test";
	#my $sth3 = $dbh->prepare($drop_test);
	#$sth3->execute();
	#$sth3->finish;

	my $del_test = "DELETE from db where Host =  '% '";
	my $sth4 = $dbh->prepare($del_test);
  $sth4->execute();
	$sth4->finish;
	
	$dbh->disconnect;
	
	
	system ("setenforce 0");
	print "Done configuring MySQL\n";
	  	
}


sub createprod {
  my $dbh;
	$dbh = DBI->connect( 'DBI:mysql:mysql', '20eprint', '20eprint')
		or die "Can not connect to mysql: $dbh->errstr\n";
	
	#create the eprint database
	my $eprint_db = "CREATE DATABASE ep_prod";
	my $sth = $dbh->prepare($eprint_db);

	eval{
		$sth->execute();
	};
	if( $@ ) {
		print "error in create prod  \n";
		die "Can not execute $eprint_db", $DBI::errstr, "\n";
	}

	$sth->finish;
	$dbh->disconnect;
	
	sleep 5;

  print " Testing connection to eprint prod\n";	
	$dbh = DBI->connect( 'DBI:mysql:ep_prod', '20eprint', '20eprint')
		or die "Can not connect to ep_prod: $dbh->errstr\n";
	print "\n";
  print " Connection to eprint prod passed\n";	

	$dbh->disconnect;	
	print "Done creating ep_prod\n";
}

sub installconfig{
    my $path = "@_";
    my @files;
    my $file;
    my $filename;
    my $backup;
   
    my @probablyok = qw ( dump_mysql.sh config webalizer.conf squid.conf python.conf manual.conf xx-local.conf iptables-config iptables backup eprint ftpaccess hosts.allow hosts.deny httpd.conf MD5.pm mysqld mysql-maint.sh clean-var-tmp.sh my.cnf vsftpd.chroot_list vsftpd.ftpusers vsftpd.user_list vsftpd.conf booleans perl.conf rc.local ssl.conf oracle-instantclient.conf oracle-instantclient64.conf logrotate.conf xfs.conf );

    opendir(FILES, $path);
    while ( defined ( $filename = readdir(FILES)) ) {
	if (($filename ne ".") && ($filename ne "..") && ($filename ne 'RCS')) {
		push(@files, $filename);
	}
    }
    foreach $file (@files) {
	my $install = 0;
	foreach my $ok( @probablyok ) {
		if( $file eq $ok ) {
			$install = 1;
		}
	}
        if( $install ) {
		print "Installing $file......\n";
		$backup = "eprint.".$file.".bak";
		if( $file eq 'httpd.conf' ) {
			system( "cp /etc/httpd/conf/$file /etc/httpd/conf/$backup");
			system( "cp $path/$file /etc/httpd/conf/.");
		} elsif( $file eq 'logrotate.conf' ) {
			system( "cp $path/$file /etc/.");
		} elsif( $file eq 'eprint' ) {
			system( "cp $path/$file /etc/logrotate.d/.");
		} elsif( $file eq 'mysqld' ) {
			system( "cp $path/$file /etc/logrotate.d/.");
		} elsif( $file eq 'booleans' ) {
			system( "cp $path/$file /etc/selinux/targeted/.");
		} elsif( $file eq 'config' ) {
			system( "cp $path/$file /etc/selinux/.");
		} elsif( $file eq 'xfs.conf' ) {
			system( "cp $path/$file /etc/httpd/conf.d/.");
		} elsif( $file eq 'perl.conf' ) {
			system( "cp $path/$file /etc/httpd/conf.d/.");
		} elsif( $file eq 'xx-local.conf' ) {
			system( "cp $path/$file /etc/httpd/conf.d/.");
		} elsif( $file eq 'manual.conf' ) {
			system( "cp $path/$file /etc/httpd/conf.d/.");
		} elsif( $file eq 'webalizer.conf' ) {
			system( "cp $path/$file /etc/httpd/conf.d/.");
		} elsif( $file eq 'squid.conf' ) {
			system( "cp $path/$file /etc/httpd/conf.d/.");
		} elsif( $file eq 'python.conf' ) {
			system( "cp $path/$file /etc/httpd/conf.d/.");
		} elsif( $file eq 'ssl.conf' ) {
			system( "cp $path/$file /etc/httpd/conf.d/.");
		} elsif( $file eq 'oracle-instantclient.conf' ) {
			if ($proc ne 'x86_64'){
				system( "cp $path/$file /etc/ld.so.conf.d/.");
			}
		} elsif( $file eq 'oracle-instantclient64.conf' ) {
			if ($proc eq 'x86_64'){
				system( "cp $path/$file /etc/ld.so.conf.d/.");
			}
		} elsif( $file eq 'iptables-config' ) {
			system( "cp $path/$file /etc/sysconfig/.");
		} elsif( $file eq 'iptables' ) {
			system( "cp $path/$file /etc/sysconfig/.");
		} elsif( $file eq 'mysql-maint.sh' ) {
			system ("mkdir /etc/cron.mysql");
			system( "cp $path/$file /etc/cron.mysql/." );
			system( "chmod 500 -R /etc/cron.mysql/" );
			system( "chmod 100 -R /etc/cron.mysql/*" );
			# Add entry for mysql maintenance script to cron
			print "Adding mysql entry to crontab \n";
			open(CRONTAB, ">>/etc/crontab") ;
			print  CRONTAB "\n";
			print  CRONTAB "02 2 * * 0 root run-parts /etc/cron.mysql\n";
			close(CRONTAB);     	          
		} elsif( $file eq 'clean-var-tmp.sh' ) {
			system( "cp $path/$file /etc/cron.daily/." );
			system( "chmod 755 -R /etc/cron.daily/$file" );
			system( "chown root.root /etc/cron.daily/$file" );
		} elsif( $file eq 'MD5.pm' ) {
			system( "cp $path/$file /usr/lib/perl5/site_perl/5.8.5/i386-linux-thread-multi/.");
		} elsif ( $file eq 'backup' ) {
			my $backupscript = "/etc/cron.backup/backup";
			system("mkdir /etc/cron.backup") if !-d "/etc/cron.backup";
			unlink( $backupscript ) if -e $backupscript;
			system("cp $path/$file /etc/cron.backup/.");
			system("chmod 755 $backupscript");
		} elsif ( $file eq 'vsftpd.conf' ) {
			my $vsftpdscript = "/etc/vsftpd/vsftpd.conf";
			system("mkdir /etc/vsftpd") if !-d "/etc/vsftpd";
			unlink( $vsftpdscript ) if -e $vsftpdscript;
			system("cp $path/$file /etc/vsftpd/.");
		} elsif ( $file eq 'vsftpd.chroot_list' || $file eq 'vsftpd.ftpusers' || $file eq 'vsftpd.user_list') {
			system("cp $path/$file /etc/.");
		} elsif ( $file eq 'ftpaccess' ) {
			system("cp -f $path/$file /etc/.");
		# Not needed, part of eprint RPM
		#} elsif( $file eq 'my.cnf2' ) {
		#	system( "cp $path/$file /etc/.my.cnf" );
		#	system( "chmod 600 /etc/.my.cnf" );
		#	system( "chown eprint.eprint /etc/.my.cnf" );
		} elsif( $file eq 'dump_mysql.sh' ) {
			system( "cp $path/$file /etc/cron.daily/." );
			system( "chmod 755 -R /etc/cron.daily/$file" );
			system( "chown root.root /etc/cron.daily/$file" );
			system("mkdir /home/dump_mysql");
		} else {
			system("cp /etc/$file /etc/$backup");
			system("cp $path/$file /etc/.");
		}
        } else {
		print "Skipping unknown file: $file\n";
        }
   }
   print "Done installing configuration files\n";
}

sub createmysqlrepositoryconf {
  #connect
  my $dbh;
	$dbh = DBI->connect( 'DBI:mysql:ep_prod', $user, $user)
		or die "Can't connect to mysql database: $dbh->errstr\n";

  #Drop the table if it exists
	my $sth = $dbh->prepare('DROP TABLE IF EXISTS repository_config');
	$sth->execute();
	$sth->finish;

	#make table
	my $sth1 = $dbh->prepare('create table repository_config(
		repository_id int not null auto_increment,
		sharedsecurity varchar(50),
		name varchar(50) not null,
		label varchar(50),
		defaultgroup varchar(50),
		superusergroup varchar(50),
		secredirescturl varchar(150),
		seccookie varchar(50),
		secdomain varchar(50),
		secsecret varchar(50),
		sectimeout varchar(50),
		coas CHAR(1),
		hostname varchar(50),
		sid varchar(50),
		port varchar(50),
		user varchar(50),
		password varchar(50),
		hidden varchar(50),
		passwordchange varchar(50),
		sortorder int,
		temp_sortorder int,
		portal varchar(50),
		vpdcode VARCHAR(6),
		`connection` varchar(50),
		tnsnameentry varchar(50),
		rptxfer VARCHAR(50),
		cas VARCHAR(50),
		casurl VARCHAR(150),
		casattr VARCHAR(50),
		`encryption` varchar(50),
		PRIMARY KEY (repository_id),
		INDEX name(name),
		INDEX sharedsecurity(sharedsecurity))');

	eval{
		$sth1->execute();
	};
	if( $@ ) {
		die "Can not create repository table", $DBI::errstr, "\n";
	}
	$sth1->finish;

	#Insert eprint demo record
	my $sql;
	my $SHAREDSECURITY = 'EPRINT';
	my $NAME = 'eprintdemo';
	my $LABEL = 'ePrint Demo';
	my $DEFAULTGROUP = 'users';
	my $SUPERUSERGROUP = 'superusers';			
	my $HIDDEN = 'NO';
	my $PASSWORDCHANGE = 'NO';
	my $SORTORDER = 1;
	my $TEMP_SORTORDER = 1;
	my $PORTAL = 'NO',
	my $VPDCODE = '';
	my $CONNECTION = 'DEFAULT';
	my $TNSNAMEENTRY = '';
	my $RPTXFER = 'NO';
	my $CAS = 'NO';
	my $CASURL = '';
	my $CASATTR = 'UDC_IDENTIFIER';
	my $ENCRYPTION = 'NO';	
	$sql = 'INSERT INTO repository_config (' .
			'sharedsecurity, name, label, ' .
			'defaultgroup, superusergroup, hidden, ' .
			'passwordchange, sortorder, temp_sortorder, ' .
			'portal, vpdcode, `connection`, ' .
			'tnsnameentry, rptxfer, cas, casurl, casattr, `encryption` )' .
	'VALUES (  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )';


	my $sth2 = $dbh->prepare($sql);

	eval {
		$sth2->execute($SHAREDSECURITY, $NAME, $LABEL,
		$DEFAULTGROUP, $SUPERUSERGROUP, $HIDDEN, 
		$PASSWORDCHANGE, $SORTORDER, $TEMP_SORTORDER, 
		$PORTAL, $VPDCODE, $CONNECTION,
		$TNSNAMEENTRY, $RPTXFER, $CAS, $CASURL, $CASATTR, $ENCRYPTION);
	};

	if( $@ ) {
		print STDERR "sql can not insert eprint demo record: $DBI::errstr, \n";
	}
  $sth2->finish;

	$dbh->disconnect;	
	print "Done creating repository config table\n";
}

sub createmysqlsecurity {
	 #connect
	 my $dbh;
	 $dbh = DBI->connect( 'DBI:mysql:ep_prod', $user, $user)
		 or die "Can not connect to ep_prod: $dbh->errstr\n";
		
   #create the userlocker table
   my $sth = $dbh->prepare( 'CREATE table userlocker_table(
      `userlocker_id` int not null auto_increment,
      `uid` varchar(20) not null,
      `attempts` varchar(15),
       PRIMARY KEY (`userlocker_id`),
       index `uid`(`uid`))');

     $sth->execute() or die "Error in creating userlocker table: $dbh->errstr\n";
     $sth->finish;

  ##############      
  #create usergroup table
	my $sth1 = $dbh->prepare( 'CREATE table usergroup_table(
     `usergroup_id` int not null auto_increment,
     `user` varchar(50) not null,
     `group` varchar(50),
			PRIMARY KEY (`usergroup_id`),
			INDEX `user`(`user`),
			INDEX `group`(`group`))');

		 $sth1->execute() or die "Error in creatinf user group table: $dbh->errstr\n";
		 $sth1->finish;
	
  #Add usergroup default admin record
  my $adminname = "ADMIN";
  my $groupname = "SUPERADMIN";
	my $sql = "INSERT INTO usergroup_table (`user`, `group`) VALUES ( ?, ? )";
	my $sth2 = $dbh->prepare($sql);

	  $sth2->execute($adminname, $groupname) or die "Error inserting admin record into usergroup table: $dbh->errstr\n";
    $sth2->finish;

  ##############      
  #create authentication table
	my $sth3 = $dbh->prepare( 'CREATE table authentication_table(
			`authentication_id` int not null auto_increment,
			`userid` varchar(50) not null,
			`password` varchar(50) not null,
			`email` varchar(50),
			`name` varchar(50),
			`eid` varchar(50),
			`lock` varchar(50),
			PRIMARY KEY (`authentication_id`),
			INDEX `userid`(`userid`),
			INDEX `name`(`name`))');

			$sth3->execute() or die "Error creating authentication table: $dbh->errstr\n";
			$sth3->finish;

  #Add authentication default admin record
  my $USERID = "ADMIN";
  my $PASSWORD = 'admin';
  my $EMAIL = "";
  my $NAME = "Super Administrator";
  my $EID = "";
  my $LOCK = 0;
  
  my $sql1 = 'INSERT INTO `authentication_table` (`userid`,  `password`, `name`, `email`, `eid`, `lock`) values  ( ?,?,?,?,?,? )';
				$sth = $dbh->prepare($sql1);
				$sth->execute($USERID, $PASSWORD, $NAME, $EMAIL, $EID, $LOCK) or die "Error inserting admin record into authentication table: $dbh->errstr\n"; 
  
   
	$dbh->disconnect;	
	print "Done creating security tables\n";
}

sub createmysqlreportconf {
	 #connect
	 my $dbh;
	 $dbh = DBI->connect( 'DBI:mysql:ep_prod', $user, $user)
		 or die "Can not connect to ep_prod: $dbh->errstr\n";
		
	my $sth = $dbh->prepare('create table report_config(
		report_config_id int not null auto_increment,
		id varchar(50) not null,
		description varchar(50),
		security varchar(150),
		param_type varchar(50),
		sortorder int,
		PRIMARY KEY (report_config_id),
		INDEX id(id))');

	$sth->execute() or die "Can not create report config table\n", $DBI::errstr, "\n";
	$sth->finish;

  #insert report report config records
 	my $sql = 'INSERT INTO report_config (' .
				'id, description, security, param_type, sortorder)' .
				'VALUES (?, ?, ?, ?, ?)';

	my $sth1 = $dbh->prepare($sql);
	
	$sth1->execute('epremal', 'Report / email Notification', 'ALL', 'no', 0);
  $sth1->execute('eprgusr', 'Group User', 'EPRINT~SINGLESIGNON', 'no', 1);	
	$sth1->execute('eprousr', 'Object User', 'BANNER~BANNERHR~BANNERST~BANNERGN', 'no', 10);
	$sth1->execute('eprrgrp', 'Report Group', 'EPRINT~SINGLESIGNON', 'no', 20);
  $sth1->execute('eprusgd', 'Usage Detail', 'ALL',  'start_end_date', 30);
  $sth1->execute('eprusgs', 'Usage Summary', 'ALL', 'start_end_date', 40);
	$sth1->execute('eprufos', 'User Fund Orgn Security', 'BANNER~BANNERHR', 'no', 50);
	$sth1->execute('eprugrp', 'User Group', 'EPRINT~SINGLESIGNON',  'no', 60);	
	$sth1->execute('epruobj','User Object', 'BANNER~BANNERHR~BANNERST~BANNERGN', 'no', 70);
	$sth1->execute('epruvbs','User VBS Security', 'EPRINT~SINGLESIGNON', 'no', 80);
	$sth1->execute('eprucds','User College Dept Security', 'BANNERST', 'no',51);
	$sth1->execute('epruecs','Employee Class Security', 'BANNERHR', 'no',11);
	$sth1->execute('eprusas','Employee Salary', 'BANNERHR', 'no',12);

	$sth1->finish;


	$dbh->disconnect;	
	print "Done creating report configuration table\n";
}

sub createscratch {

	system( "mkdir /home/scratch");
	system( "mkdir extract image /home/scratch");
	system( "ln -s /home/scratch /scratch");
	system( "chown eprint.eprint -R /home/scratch");
	print "Done creating scratch directory\n";
}

sub createmysqldiskusage {
	my ( $dbh ); 	
	
	#connect
	$dbh = DBI->connect( 'DBI:mysql:ep_prod', $user, $user)
		 or die "Can not connect to ep_prod: $dbh->errstr\n";
		
	my $sth = $dbh->prepare( 'CREATE table `diskusage`(
		 id int not null auto_increment,
		 repository varchar(50) not null,
		 label varchar(50),
		 bytes bigint(64),
		 date varchar(20),
		 PRIMARY KEY (id),
		 INDEX repository(repository))');
		
	$sth->execute or die "Can not create disk usage table\n", $DBI::errstr, "\n";;
	$sth->finish;

	print "Done creating disk usage table\n";

	$dbh->disconnect;	
}


sub createlocaldefaults {
	my $path = "@_"; 	
	print "mysql --user=$user --password=$user ep_prod < $path/ep_prod-local_defaults.sql\n";		
	#system("mysql --user=$user --password=$user ep_prod < $path/ep_prod-local_defaults.sql" );
	 
}

sub insertdiskusage{

	my ( $sth, @repos, $repo, $sql, $dbh );
	#connect
	$dbh = DBI->connect( 'DBI:mysql:ep_prod', $user, $user)
		or die "Can not connect to ep_prod: $dbh->errstr\n";

	#inserting table data for initialized repositories ( eprintdemo )
	$sql = "SELECT `name`,`label` from repository_config";
	$sth = $dbh->prepare( $sql );

	eval {
		$sth->execute;
	};

	my @labels;

	while( my $hashref = $sth->fetchrow_hashref) {
		push (@repos,$$hashref{name});
		push (@labels,$$hashref{label});
	}

	$sth->finish;
	my $count = 0;

	foreach $repo( @repos) {
		my $mysqldir = '/home/mysql/'.$repo;
		my $reposdir = '/home/eprint/prod/repository/'.$repo;
		my @array = `du -scb $mysqldir $reposdir`;
		my $date = `date`;
		my $repostotal = $array[2];
		my ($totalbytes,$remaining) = split (/\s/, $repostotal);
		$sql = "INSERT into `diskusage` SET `bytes` =?,`date`=?, `repository` =?, `label`=?";
		$sth = $dbh->prepare($sql);
		$sth->execute($totalbytes,$date, $repo,$labels[$count]);
		$sth->finish;
		$count++;
	}
	$dbh->disconnect;

}

sub installeprintrpms{
	my $path = "@_";
	system("rpm -ihv --force $path/eprint-4*.rpm");
   
	print "Done installing eprint rpm's\n";
}

sub installeprintmodules{
    my $frompath = "@_";
    my $eprinthome = "/home/eprint";
   
    my @paths = qw ( /cgi-bin/ /code/ /code/Local/ /code/Wizards /code/Pinnacle/ /code/Pinnacle/Authenticate/ /code/Pinnacle/Authorize/ /code/Pinnacle/Group/ /code/Pinnacle/Reportauth/ /code/Pinnacle/Wizard/ /tools/ /operator/ );
   
    foreach my $path (@paths) {
       print "\n\n$path\n";
       my $fromdir = $frompath .$path;
       my $todir = $eprinthome . $path;
       my @files;
       my $filename;
       opendir(FILES, $fromdir);
          while ( defined ( $filename = readdir(FILES)) ) {
             if (($filename ne ".") && ($filename ne "..")) {
           	    if ((substr($filename, -3) eq ".pl") || (substr($filename, -3) eq ".pm") || (substr($filename, -3) eq "cgi")) {
                   push(@files, $filename);
                   print "$filename\n";
                }
             }
          }
      
      foreach my $file( @files ) {
         print "Installing $file......\n";
         my $backup = "eprint.".$file.".bak";
                       
         system("cp $fromdir/$file $todir/$backup");
         system("cp -f $fromdir/$file $todir/.");        
      }
   }
   print "Done installing eprint perl modules\n";
}

sub installsmarteprintrpms{
     my $path = "@_";

     my $export;
     print "Export Compliance \n";
     print "Will this server reside in the US or Canada? \n";
     print STDOUT "Y or N: \n";	
     #chop($export = <STDIN>); 

     $export = read_file( 'exportcompliance.txt' ) ;
     $export = uc($export);

     if ( $export eq "N" ) {
          print "\nExport Complience Enforced \n Smarteprint was NOT installed\n\n";
     } else {
         #install rpm(s)
         system("rpm -ihv --force $path/smarteprint*"); 
         print "Done installing smarteprint \n";	 
  }





}

sub installeprintdemorpms{
	my $path = "@_";
	
	#install rpms
	system("rpm -ihv --force $path/eprint-initialprod*");
	system("rpm -ihv --force $path/eprint-demo*");
  
	print "Done installing eprint demo rpm's\n";
}

sub installgpg{
	my $path = "@_";

	system( "cp -r $path/root/.gnupg /root/" );
	print "Done installing gpg\n";
}

sub installreportgpg{
	my $path = "@_";

	system( "cp -a $path/gpg-eprint/.gnupg /home/eprint/." );
	#Set permission/ownership 
	system( "chown eprint.eprint -R /home/eprint/.gnupg" );
	system( "chmod 0700 /home/eprint/.gnupg" );
	system( "chmod 0600 /home/eprint/.gnupg/*" );
	
	# Store magic word
	system( "cp $path/gpgword /root/.gpgword" );
	system(  "chown root.root /root/.gpgword" );
	system(  "chmod 600 /root/.gpgword" );

	print "Done installing report encryption gpg\n";
}

sub eprint_user {
	my $eprint = "eprint";

	&message("Setting up the ePrint user");

	system("/usr/sbin/./useradd -d /home/$eprint -g eprint -r $eprint -m");

	# The -m means create the directory........

	print "Setting up the password for $eprint:\n\n";
#	system("passwd $eprint");
        system("echo '$eprint:eprint123!' | chpasswd");
	print "\n\n";


}

sub addcrontabentry {
	my @search = `grep smarteprint /etc/crontab`;
	
	if ($search[0] =~ /smarteprint/) {
		print "No Entry added to the /etc/crontab.\n\n";
	} else {
		open(CRONTAB, ">> /etc/crontab") or
		   die "Couldn't open crontab, do" .
		    "you have permissions to do so?";
		print CRONTAB "\n01 4 * * * root /home/eprint/updates/smarteprint.pl >& /dev/null";
		close(CRONTAB);
		print "Entry added to the /etc/crontab.\n\n";
	}
	
	my @dusearch = `grep du.pl /etc/crontab`;
	if( $dusearch[0] =~ /du.pl/) {
		print "No entry added to the /etc/crontab.\n\n";
	} else {
		open( CRONTAB, ">> /etc/crontab") or
			die "Couldn't open crontab, do you have permision to do so? \n";
		print CRONTAB "\n02 1 * * * root /home/eprint/code/du.pl&";
		close(CRONTAB);
		print "Entry added for du.pl to the /etc/crontab.\n\n";
	}
}

sub create_crontabentry {

	my @search = `grep backup /etc/crontab`;
	if( $#search > -1 ) {
		print "Entry already present in " .
			"/etc/crontab: \n@search\n";
	} else {
		open(CRONTAB, ">> /etc/crontab") or
		   die "Couldn't open crontab, " .
			"do you have permissions to do so?";
		my $backup = &getbackuppolicy;
		print CRONTAB "\n$backup root run-parts	/etc/cron.backup\n";
		close(CRONTAB);
		print "Entry added to the /etc/crontab.\n";
	}
}

sub getbackuppolicy {
	my $backup = "00 1 * * *";

	print << "DONE";
	Select a backup policy:
	1) Every day                     (00 1 * * *)  (default)
	2) Weekdays                      (00 1 * * 1-5)
	3) Once per week (what day?)     (00 1 * * <day>)
DONE


	print "\nEnter Choice: ";
#	my $key = getc;
        my $key = read_file( 'backuppolicy.txt' ) ;
	print "$key\n";

	if( $key == '1' ) {
		$backup = "00 1 * * *";
	} elsif( $key == '2' ) {
		$backup = "00 1 * * 1-5";
	} elsif( $key == '3' ) {
		my $day = -1;
		while( !($day >= 0 && $day <= 7) ) {
		   print "Which day of the week? (0 = Sun, 6 = Sat) ";
		   $day = getc;
		   print "$day\n";
		}
		$backup = "00 1 * * $day";
	} else {
		print "Using Default of Every day\n";

	}
	print "Using $backup\n";

	return $backup;
}

sub create_logrotater {
	my $rotater = "/etc/logrotate.d/backup";

	unlink( $rotater ) if -e $rotater;

	open(BACKUP, "> $rotater") ||
		die "Could not open: $rotater\n";

	print BACKUP << "END_SCRIPT";
"/var/log/backupfiles.log" {
	rotate 5
	daily
	missingok
	ifempty
}
"/var/log/backuperrors.log" {
	rotate 5
	daily
	missingok
	ifempty
}
END_SCRIPT

	close( BACKUP );

	system("chmod 644 $rotater");
	print "\n";
}

sub setuptimeserver {

	#add directory 
	system("mkdir /etc/cron.clocksync");

	#get ip address
	my $ip;
	print "Adding the IP address of the time server\n";
	print "Leave this blank if the ip address is not available\n";
	print STDOUT "Enter the ip address: \n";
#	chop($ip = <STDIN>);
	$ip = read_file( 'timeserverip.txt' ) ;
	$ip = $ip;
	
	print "\n using ip $ip\n\n";

	#make shell script clocksync.sh 
	system ("touch /etc/cron.clocksync/clocksync.sh");

	open(CLOCKSYNC, ">>/etc/cron.clocksync/clocksync.sh");  
	print CLOCKSYNC "#!/bin/bash\n";
	print CLOCKSYNC "ntpdate -b $ip\n";
	print CLOCKSYNC "hwclock --systohc";
	close (CLOCKSYNC);

	system("chmod 100 /etc/cron.clocksync/clocksync.sh");

	#Put an entry in the crontab to run the script
	print "Adding clock synch entry to crontab \n\n";
	open(CRONTAB, ">>/etc/crontab");
	print  CRONTAB "\n";
	print  CRONTAB "21 3 * * * root run-parts /etc/cron.clocksync\n";
	close(CRONTAB); 
  	
}

sub installpost_build{
   my $path = "@_";
   system("$path/installpost_build.pl $path");
   
}

sub install_oracle {
   my $path = "@_";

   if( $proc ne 'x86_64' ) {
	$proc_oracle = '*86';
   } else {
	$proc_oracle = $proc;
   }

   system("rpm -ihv --nodeps $path/*$proc_oracle.rpm $path/eprint-oracle*.rpm");	
   system( "cp -f $path/tnsping.sh /etc/profile.d/tnsping.sh");

   print "\n running updatedb ... please wait\n";
   system ( "updatedb");
	 sleep 30;
	
   # Don't need this on RHEL 5
   #system( "cp -f /etc/ld.so.conf /etc/ld.so.conf.bak");
   #system( "cp -f $path/ld.so.conf /etc");

   system( "/sbin/ldconfig");
	
	#Set the Oracle directory owner and permissions	
	#The path is created when eprint-oracle-extras-1.0-1 is installed
	system( "chown -R eprint.eprint /usr/local/oracle");
  system( "chmod 0755 /usr/local/oracle");
  system( "chmod 0755 /usr/local/oracle/network");
  system( "chmod 0755 /usr/local/oracle/network/admin");
  system( "chmod 0644 /usr/local/oracle/network/admin/*");

	 print "\n";
}


sub message {
	my $message = "@_";

	print"----------------------------------------------------" . 
		"----------------\n";
	print " $message \n";
	print"----------------------------------------------------" .
		"----------------\n";

	sleep 2;
}

sub setupadmin {
        system( "/home/eprint/tools/resetadmin.pl" );

}

sub config_services {
   system( "chkconfig NetworkManager off" );
   system( "chkconfig NetworkManagerDispatcher off" );
   system( "chkconfig acpid off" );
   system( "chkconfig anacron on" );
   system( "chkconfig apmd off" );
   system( "chkconfig atd off" );
   system( "chkconfig auditd off" );
   system( "chkconfig autofs off" );
   system( "chkconfig avahi-daemon off" );
   system( "chkconfig avahi-dnsconfd off" );
   system( "chkconfig bluetooth off" );
   system( "chkconfig capi off" );
   system( "chkconfig conman off" );
   system( "chkconfig cpuspeed off" );
   system( "chkconfig crond on" );
   system( "chkconfig cups off" );
   system( "chkconfig dc_client off" );
   system( "chkconfig dc_server off" );
   system( "chkconfig dhcdbd off" );
   system( "chkconfig dund off" );
   system( "chkconfig firstboot off" );
   system( "chkconfig gpm off" );
   system( "chkconfig haldaemon on" );
   system( "chkconfig hidd off" );
   system( "chkconfig httpd on" );
   system( "chkconfig ip6tables off" );
   system( "chkconfig ipmi off" );
   system( "chkconfig iptables on" );
   system( "chkconfig irda off" );
   system( "chkconfig irqbalance on" );
   system( "chkconfig isdn off" );
   system( "chkconfig kdump off" );
   system( "chkconfig kudzu on" );
   system( "chkconfig lvm2-monitor off" );
   system( "chkconfig mcstrans off" );
   system( "chkconfig mdmonitor on" );
   system( "chkconfig mdmpd on" );
   system( "chkconfig messagebus off" );
   system( "chkconfig microcode_ctl off" );
   system( "chkconfig multipathd off" );
   system( "chkconfig mysqld on" );
   system( "chkconfig netconsole off" );
   system( "chkconfig netfs off" );
   system( "chkconfig netplugd off" );
   system( "chkconfig network on" );
   system( "chkconfig nfs off" );
   system( "chkconfig nfslock off" );
   system( "chkconfig nscd off" );
   system( "chkconfig ntpd off" );
   system( "chkconfig pand off" );
   system( "chkconfig pcscd off" );
   system( "chkconfig portmap off" );
   system( "chkconfig psacct off" );
   system( "chkconfig rdisc off" );
   system( "chkconfig readahead_early off" );
   system( "chkconfig readahead_later off" );
   system( "chkconfig restorecond off" );
   system( "chkconfig rhnsd on" );
   system( "chkconfig rpcgssd off" );
   system( "chkconfig rpcidmapd off" );
   system( "chkconfig rpcsvcgssd off" );
   system( "chkconfig saslauthd off" );
   system( "chkconfig sendmail on" );
   system( "chkconfig setroubleshoot off" );
   system( "chkconfig smartd on" );
   system( "chkconfig smb off" );
   system( "chkconfig squid off" );
   system( "chkconfig sshd on" );
   system( "chkconfig syslog on" );
   system( "chkconfig tux off" );
   system( "chkconfig vncserver off" );
   system( "chkconfig vsftpd on" );
   system( "chkconfig winbind off" );
   system( "chkconfig wpa_supplicant off" );
   system( "chkconfig xfs off" );
   system( "chkconfig ypbind off" );
   system( "chkconfig yum-updatesd off" );

	system( "/etc/init.d/iptables restart" );

	#Set ownership
	system( "chown -R eprint.eprint /home/eprint/prod &");
}

sub begmessage {
	my $message = "@_";
	print " \n";	
	
	print"\n////////////////////////////////////////////////////" . 
		"////////////////\n";
	print " $message \n";
	print"////////////////////////////////////////////////////" .
		"///////////////\n";

	print " \n";	
	
}




#!/usr/bin/perl


use strict;
use warnings;


print "Locating ePrint package....\n";

my $package_path=system("locate -i eprint-4.4.1.RHEL6.tar.gz");
print  "Displaying RHEL version....\n";

system("cat /etc/redhat-release");

print "Listing yum repository and all the packages....\n";

system("yum repolist");
system("yum list all");

my $arch=system("uname -p");

print "Creating the /home/install directory....\n";
system("mkdir -p /home/install");

print "Changing to /home/install directory....\n";
system("cd /home/install");

print "Moving the package to /home/install directory....\n";
system("mv $package_path /home/install");

print "Untarring the zip package....\n";
system("tar -xvzf eprint-4.4.1.RHEL6.tar.gz");

print "Copying the install_new.pl and its input files to installdir : /home/install\n";
system("mv /root/install_new.pl /home/install/");

system("mv /root/exportcompliance.txt /home/install/");
system("mv /root/backuppolicy.txt /home/install/");
system("mv /root/timeserverip.txt /home/install/");

print "Changing the permissions of install_new.pl\n";

system("chmod 755 /home/install/install_new.pl");

print "Creating the directories for temp files used during migration....\n";
system("mkdir -p /home/install/migration/{install,1stphase,2ndphase}");
system("mkdir -p /home/install/migration/install/{perlmodules,packages,banner,updatepl}");
system("mkdir -p /home/install/migration/1stphase/{userentries,cron,updatepl,images}");
system("mkdir -p /home/install/migration/2ndphase/{cron,updatepl,images}");

system("yum install -y 'perl(File::Slurp)'");
system("yum install -y elinks*");


print "Starting ePrint installation....\n";
print "Changing to /home/install\n";

system("cd /home/install");

print "Executing the main ePrint install script\n";
#system("./install_new.pl");


__END__
#####################################################################################################################################################################################################
#Updating the update.pl variables

echo "##############################################################################################################################################################################################"

echo "Updating WEBSERVER, EMAIL, RHEL and SFTP_USER...."

echo "*****Updating Webserver*****"


#Use the actual FQDN to update the webserver
hostname -f > /home/install/migration/install/updatepl/hostname
#hostname  > /home/install/migration/install/updatepl/hostname

~eprint/tools/update_localdef.pl U WEBSERVER < /home/install/migration/install/updatepl/hostname

~eprint/tools/update_localdef.pl P | grep WEBSERVER > /home/install/migration/install/updatepl/hostname_tmp

cat /home/install/migration/install/updatepl/hostname_tmp | grep Yes

if [ $? -ne 0 ]
then
	~eprint/tools/update_localdef.pl U WEBSERVER < /home/install/migration/install/updatepl/hostname	
fi




echo "*****Updating Email*****"

echo "eprint@`hostname`" > /home/install/migration/install/updatepl/email

~eprint/tools/update_localdef.pl U EMAIL < /home/install/migration/install/updatepl/email

~eprint/tools/update_localdef.pl P | grep EMAIL > /home/install/migration/install/updatepl/email_tmp

cat /home/install/migration/install/updatepl/email_tmp | grep Yes

if [ $? -ne 0 ]
then
	~eprint/tools/update_localdef.pl U EMAIL < /home/install/migration/install/updatepl/email
fi



#Hardcding the RHEL version for now.

echo "*****Updating RHEL*****"

echo "6" > /home/install/migration/install/updatepl/rhel

~eprint/tools/update_localdef.pl U RHEL < /home/install/migration/install/updatepl/rhel

~eprint/tools/update_localdef.pl P | grep RHEL > /home/install/migration/install/updatepl/rhel_tmp

cat /home/install/migration/install/updatepl/rhel_tmp | grep Yes

if [ $? -ne 0 ]
then
	~eprint/tools/update_localdef.pl U RHEL < /home/install/migration/install/updatepl/rhel
fi


echo "*****Updating SFTP_USER*****"

echo "1" > /home/install/migration/install/updatepl/sftpuser

~eprint/tools/update_localdef.pl U SFTP_USER < /home/install/migration/install/updatepl/sftpuser

~eprint/tools/update_localdef.pl P | grep SFTP_USER > /home/install/migration/install/updatepl/sftpuser_tmp

cat /home/install/migration/install/updatepl/sftpuser_tmp | grep Yes

if [ $? -ne 0 ]
then
	~eprint/tools/update_localdef.pl U SFTP_USER < /home/install/migration/install/updatepl/sftpuser
fi


#####################################################################################################################################################################################################

#Checking if eprint is installed

echo "##############################################################################################################################################################################################"

echo "Checking if eprint is installed...."

rpm -q eprint

if [ $? -ne 0 ]
then
	echo "ePrint package is not installed and has a problem"
	exit 1
fi

#####################################################################################################################################################################################################
#Running the yum update.
echo "##############################################################################################################################################################################################"
#echo "Running the yum update...."
yum update -y

#####################################################################################################################################################################################################
#Verifying and starting the services
echo "##############################################################################################################################################################################################"

echo "Verifying and starting httpd...."

chkconfig httpd on

if [ $? -ne 0 ]
then
	echo "Problem checking the httpd service"
	exit 1
fi

service httpd status

if [ $? -ne 0 ]
then
	echo "The httpd service is stopped"
	
        service httpd start
        
	if [ $? -ne 0 ]
        then
		echo "Problem starting the httpd service"
	        exit 1
	fi
fi



echo "Verifying and starting crond...."

chkconfig crond on

if [ $? -ne 0 ]
then
	echo "Problem checking the crond service"
	exit 1
fi

service crond status

if [ $? -ne 0 ]
then
	echo "The crond service is stopped"
	
	service crond start
        
	if [ $? -ne 0 ]
        then
		echo "Problem starting the crond service"
	        exit 1
	fi
fi




echo "Verifying and starting mysqld...."

chkconfig mysqld on

if [ $? -ne 0 ]
then
	echo "Problem checking the mysqld service"
	exit 1
fi

service mysqld status

if [ $? -ne 0 ]
then
	echo "The mysqld service is stopped"
	
	service mysqld start
        
	if [ $? -ne 0 ]
        then
		echo "Problem starting the mysqld service"
	        exit 1
	fi
fi

#####################################################################################################################################################################################################






#####################################################################################################################################################################################################
#Backing up installed iptables and restoring original one


echo "***********************ePrint installation complete************************"

echo ""
echo ""
echo ""

echo "###################################################################################################################################################################################################################################################################################################################################################################################################"


#####################################################################################################################################################################################################
echo "###################################################################################################################################################################################################################################################################################################################################################################################################"
echo ""
echo ""
echo ""

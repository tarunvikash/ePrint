#!/usr/bin/perl

use strict;
use warnings;

my $install = "install";
my $group_install = "groupinstall";


print_message("Installing mlocate");
&install_packages("mlocate", $install, 1);

print_message("Installing VIM");
&install_packages("vim", $install, 1);

print_message("Group installing required packages");
&install_packages("\"server with gui\" \"Development tools\" \"base\" \"X window system\" \"perl support\" \"FTP server\" \"web server\" \"server with gui\"", $group_install, 1 );


print_message("Running Update");
&install_packages("update", , 1);


print_message("Installing MariaDB");
&install_packages("mariadb*", $group_install ,1 );

system("systemctl enable mariadb");
system("systemctl start mariadb");
system("mysql_secure_installation");
system("startx");

sub install_packages{
	my ($command, $type, $yes_flag) = @_;
	if ($yes_flag == 1){
		system("yum $type \-y $command");
	}else{
		system("yum $type $command");
	}
	return;
}

sub print_message{
	my ($message) = @_;
	print "~~" x 10 . " " . $message . " "  ."~~" x 10 . "\n";
	sleep(5);
}

#!/usr/bin/perl

use strict;

if( @ARGV < 1 ){
        print "Need 1 Input: <directory_of_cloud_user_logs>\n";
        exit(1);
};

my $data_dir = shift @ARGV;

my $data_name = "actual_cloud_display.log";
my $new_data_name = "accumul_actual_cloud_display.log";

my $input_file = $data_dir . "/" . $data_name;

open(DATA, "< $input_file") or die $!;

my $ts;
my $acct;
my $user;
my $password;
my $running_instances = 0;
my $volumes = 0;
my $snapshots = 0;
my $security_groups = 0;
my $keypairs = 0;
my $ip_addresses = 0;
my $is_populate_run = 0;

my $output_file = $data_dir . "/" . $new_data_name;

open(ACCUMUL, "> $output_file") or die $!;

my $line;
while($line=<DATA>){
	chomp($line);
#	print $line . "\n";
	if( $line =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/){
		if( $is_populate_run == 0 ){
			$is_populate_run = 1;
			$ts = $1;
			$acct = $2;
			$user = $3;
			$password = $4;
			$running_instances += $5;
			$volumes += $6;
			$snapshots += $7;
			$security_groups += $8 - 1;
			$keypairs += $9;
			$ip_addresses += $10;
			
			print ACCUMUL "$ts\t$acct\t$user\t$password\t$running_instances\t$volumes\t$snapshots\t$security_groups\t$keypairs\t$ip_addresses\n";
		}else{
			$is_populate_run = 0;
		};
	};
};

close(DATA); 

close(ACCUMUL);

exit(0);

1;


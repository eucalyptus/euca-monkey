#!/usr/bin/perl

use strict;
local $| = 1;

### STATIC VAR
my $POP_DIR = "../myworkspace";
my $CMD_PREFIX = "cd $POP_DIR; ./cloud-resource-populator.py";


### RESOURCE PARAMETERS
my $acct = "cloud-user-test-acct-00";
my $user = "cloud-user-00";
my $password = "mypassword00";

### SAMPLE PARAMETER
my $sample_rate = 5;

read_sampler_ini_file("./conf/sampler.ini");

print_sampler_parameters();

run_cloud_user_workload_sampler($sample_rate, $acct, $user, $password);

exit(0);

1;


################# SUBROUTINE #################################

sub read_sampler_ini_file{
	my $ini_file = shift @_;
	open(INI, "< $ini_file") or die $!;
	my $line;
	while($line = <INI>){
		chomp($line);
		if( $line =~ /^account:\s+(\S+)/ ){
			$acct = $1;
		}elsif( $line =~ /^user:\s+(\S+)/ ){
			$user = $1;
		}elsif( $line =~ /^password:\s+(\S+)/ ){
			$password = $1
		}elsif( $line =~ /^sample rate:\s+(\d+)/ ){
                        $sample_rate = $1
		}
	};
	close(INI);

	return;
};

sub print_sampler_parameters{

	print "\n";
	print "=================== SAMPLER PARAMETERS ==========================\n";
	print "\n";

	print "ACCOUNT: $acct\n";
	print "USER:  $user\n";
	print "PASSWORD: $password\n";
	print "\n";

	print "SAMPLE RATE: $sample_rate\n";
	print "\n";

        print "================== SAMPLER PARAMETERS: END ======================\n";
        print "\n";
        print "\n";
        print "\n";

	return;
};



sub construct_cmd_user_info{

	my $this_cmd_prefix = shift@_;
	my $this_acct = shift @_;
	my $this_user = shift @_;
	my $this_password = shift @_;

	my $cmd = $this_cmd_prefix . " --accountname $this_acct --username $this_user --password $this_password";

	return $cmd;
};

sub construct_cmd_populate_resources{

	my $this_cmd_user_info = shift @_;
	my $running_instances = shift @_;
	my $volumes = shift @_;
	my $snapshots = shift @_;
	my $security_groups = shift @_;
	my $keypairs = shift @_;
	my $ips = shift @_;
	
	my $cmd = $this_cmd_user_info . " --running-instance-count $running_instances --volume-count $volumes --snapshot-count $snapshots --keypair-count $keypairs --security-group-count $security_groups --ip-count $ips";

	return $cmd;
};

sub construct_cmd_display_resources{

        my $this_cmd_user_info = shift @_;

        my $cmd = $this_cmd_user_info . " --display-resources 1";

	return $cmd;
};

sub construct_cmd_clear_resources{

        my $this_cmd_user_info = shift @_;

        my $cmd = $this_cmd_user_info . " --clear-resources 2";

	return $cmd;
};


sub run_cloud_user_workload_sampler{
	my ($sample_minute, $acct, $user, $password) = @_;

	### CONSTRUCT COMMAND LINES
	my $cmd_user_info = construct_cmd_user_info($CMD_PREFIX, $acct, $user, $password);

	my $cmd_display = construct_cmd_display_resources($cmd_user_info);
	print "COMMAND_DISPLAY:\n";
	print $cmd_display . "\n";
	print "\n";

	my $ts = print_time_for_gnuplot();;
	my $log_dir = "./sample-ACCT-" . $acct . "-USER-" . $user . "-TS-" . $ts;
	system("mkdir -p $log_dir");

	while(1){
		$ts = print_time_for_gnuplot();
		print "\n";
		print "[$ts]\n";
		sample_actual_cloud_display($log_dir, $ts, $acct, $user, $password, $cmd_display);
		print "\n";
		print "SLEEPING FOR $sample_minute MIN.\n";
		sleep($sample_minute*60);
	};

	return 0;
};

sub record_cloud_user_input{
	my ($log_dir, $ts, $acct, $user, $password, $running_instances, $volumes, $snapshots, $security_groups, $keypairs, $ips) = @_;
	
	my $log_file_name = "cloud_user_input.log";
	open(LOG, ">> $log_dir/$log_file_name") or die $!;
	print LOG "$ts\t$acct\t$user\t$password\t$running_instances\t$volumes\t$snapshots\t$security_groups\t$keypairs\t$ips\n";
	close(LOG);

	return;	
};

sub sample_actual_cloud_display{
	my ($log_dir, $ts, $acct, $user, $password, $cmd) = @_;

	my $running_instances = -1;
	my $volumes = -1;
	my $snapshots = -1;
	my $security_groups = -1;
	my $keypairs = -1;
	my $ips = -1;

	my $buffer = `$cmd | grep RESOURCE`;
	my @array1 = split("\n", $buffer);

	foreach my $line (@array1){
		print $line . "\n";
		if( $line =~ /^\[RESOURCE] Running Instances: (\d+)/ ){
			$running_instances = $1;
		}elsif(  $line =~ /^\[RESOURCE] Volumes: (\d+)/ ){
                        $volumes = $1;
		}elsif(  $line =~ /^\[RESOURCE] Snapshots: (\d+)/ ){
                        $snapshots = $1;
		}elsif(  $line =~ /^\[RESOURCE] Security Groups: (\d+)/ ){
                        $security_groups = $1;
		}elsif(  $line =~ /^\[RESOURCE] Keypairs: (\d+)/ ){
                        $keypairs = $1;
		}elsif(  $line =~ /^\[RESOURCE] IP Addresses: (\d+)/ ){
                        $ips = $1;
		};
	};

	my $log_file_name = "sample_actual_cloud_display.log";
        open(LOG, ">> $log_dir/$log_file_name") or die $!;
        print LOG "$ts\t$acct\t$user\t$password\t$running_instances\t$volumes\t$snapshots\t$security_groups\t$keypairs\t$ips\n";
        close(LOG);

	return;
};
sub run_cmd{
	my $cmd = shift @_;

	print "\n";	
	print "COMMAND: $cmd\n";
	system($cmd);
	print "\n";

	return;
};

sub print_time{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
	my $this_time = sprintf "[%4d-%02d-%02d %02d:%02d:%02d]", $year+1900,$mon+1,$mday,$hour,$min,$sec;
	return $this_time;
};

sub print_time_for_gnuplot{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
	my $this_time = sprintf "%4d-%02d-%02d:%02d:%02d:%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec;
	return $this_time;
};




1



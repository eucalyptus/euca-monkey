#!/usr/bin/perl

use strict;


### STATIC VAR
my $POP_DIR = "../myworkspace";
my $CMD_PREFIX = "cd $POP_DIR; ./cloud-resource-populator.py";


### RESOURCE PARAMETERS
my $acct = "cloud-user-test-acct-00";
my $user = "cloud-user-00";
my $password = "mypassword00";

my $running_instances = 0;
my $volumes = 0;
my $snapshots = 0;
my $security_groups = 0;
my $keypairs = 0;
my $ips = 0;

### WORKLOAD PARAMETER
my $iterations = 0;


read_generator_ini_file("./conf/generator.ini");

print_generator_parameters();

run_cloud_user_workload_generator($iterations, $acct, $user, $password, $running_instances, $volumes, $snapshots, $security_groups, $keypairs, $ips);

exit(0);

1;


################# SUBROUTINE #################################

sub read_generator_ini_file{
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
		}elsif( $line =~ /^running instances:\s+(\d+)/ ){
			$running_instances = $1
		}elsif( $line =~ /^volumes:\s+(\d+)/ ){
                        $volumes = $1
		}elsif( $line =~ /^snapshots:\s+(\d+)/ ){
                        $snapshots = $1
		}elsif( $line =~ /^security groups:\s+(\d+)/ ){
                        $security_groups = $1
		}elsif( $line =~ /^keypairs:\s+(\d+)/ ){
                        $keypairs = $1
		}elsif( $line =~ /^ip addresses:\s+(\d+)/ ){
                        $ips = $1
		}elsif( $line =~ /^iterations:\s+(\d+)/ ){
                        $iterations = $1
		}
	};
	close(INI);

	return;
};

sub print_generator_parameters{

	print "\n";
	print "=================== GENERATOR PARAMETERS ==========================\n";
	print "\n";

	print "ACCOUNT: $acct\n";
	print "USER:  $user\n";
	print "PASSWORD: $password\n";
	print "\n";

	print "RUNNING INSTANCES: $running_instances\n";
	print "VOLUMES: $volumes\n";
	print "SNAPSHOTS: $snapshots\n";
	print "SECURITY GROUPS: $security_groups\n";
	print "KEYPAIRS: $keypairs\n";
	print "IP ADDRESSES: $ips\n";
	print "\n";

	print "ITERATIONS: $iterations\n";
	print "\n";

        print "================== GENERATOR PARAMETERS: END ======================\n";
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


sub run_cloud_user_workload_generator{
	my ($iteration, $acct, $user, $password, $running_instances, $volumes, $snapshots, $security_groups, $keypairs, $ips) = @_;

	### CONSTRUCT COMMAND LINES
	my $cmd_user_info = construct_cmd_user_info($CMD_PREFIX, $acct, $user, $password);

	my $cmd_pop = construct_cmd_populate_resources($cmd_user_info, $running_instances, $volumes, $snapshots, $security_groups, $keypairs, $ips);
	print "COMMAND_POPULATE:\n";
	print $cmd_pop . "\n";
	print "\n";

	my $cmd_display = construct_cmd_display_resources($cmd_user_info);
	print "COMMAND_DISPLAY:\n";
	print $cmd_display . "\n";
	print "\n";

	my $cmd_clear = construct_cmd_clear_resources($cmd_user_info);
	print "COMMAND_CLEAN:\n";
	print $cmd_clear . "\n";
	print "\n";

	my $ts = print_time_for_gnuplot();;
	my $log_dir = "./log-ACCT-" . $acct . "-USER-" . $user . "-TS-" . $ts;
	system("mkdir -p $log_dir");

	for(my $i=0; $i<$iteration; $i++){

		$ts = print_time_for_gnuplot();
		record_cloud_user_input($log_dir, $ts, $acct, $user, $password, $running_instances, $volumes, $snapshots, $security_groups, $keypairs, $ips);
		run_cmd($cmd_pop);

		$ts = print_time_for_gnuplot();
		scan_and_record_actual_cloud_display($log_dir, $ts, $acct, $user, $password, $cmd_display);
		
		$ts = print_time_for_gnuplot();
		record_cloud_user_input($log_dir, $ts, $acct, $user, $password, 0, 0, 0, 0, 0, 0);
		run_cmd($cmd_clear);

		$ts = print_time_for_gnuplot();
		scan_and_record_actual_cloud_display($log_dir, $ts, $acct, $user, $password, $cmd_display);	

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

sub scan_and_record_actual_cloud_display{
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

	my $log_file_name = "actual_cloud_display.log";
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



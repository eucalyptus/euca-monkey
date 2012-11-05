#!/usr/bin/perl

use strict;
local $| = 1;


### STATIC VAR
my $CLOUD_USER_GEN_DIR = "..";
my $PLOT_DIR = $CLOUD_USER_GEN_DIR . "/plot_cloud_user_data";
my $GRAPH_DIR = $PLOT_DIR . "/graphs";
my $HTML_GRAPH_DIR = "/var/www/html/graphs";

my $scan = `ls $CLOUD_USER_GEN_DIR | grep log-`;
my @array1 = split(" ", $scan);

@array1 = sort @array1;

my $latest_log_dir = $array1[@array1-1];

print $latest_log_dir . "\n";

my $render_cloud_input = "cd $PLOT_DIR; ./generate_cloud_user_data_graph.pl ../$latest_log_dir";
my $render_actual_resource = "cd $PLOT_DIR; ./generate_actual_cloud_data_graph.pl ../$latest_log_dir";

my $copy_graphs_over_to_html = "cp -f $GRAPH_DIR/* $HTML_GRAPH_DIR/.";

while(1){

	print "\n";
	print print_time();
	run_cmd($render_cloud_input);
	run_cmd($render_actual_resource);
	run_cmd($copy_graphs_over_to_html);

	print "\n";
	print "Sleeping for 2 Min..\n";
	sleep(120);
	print "\n";
};

exit(0);

1;

########### SUBROUTINE ##############

sub run_cmd{
	my $cmd = shift @_;
	print "\n";
	print "CMD: $cmd\n";
	system($cmd);
	print "\n";
	return;
};

sub print_time{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
	my $this_time = sprintf "[%4d-%02d-%02d %02d:%02d:%02d]", $year+1900,$mon+1,$mday,$hour,$min,$sec;
	return $this_time;
};



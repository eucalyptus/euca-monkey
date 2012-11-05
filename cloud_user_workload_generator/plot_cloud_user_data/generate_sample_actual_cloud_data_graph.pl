#!/usr/bin/perl

use strict;

my $this_dir = ".";

my $gnuplot_scripts_dir = $this_dir ."/gnuplot_scripts";
my $graphs_dir = $this_dir . "/graphs";

if( @ARGV < 1 ){
        print "Need 1 Input: <directory_of_cloud_user_logs>\n";
        exit(1);
};

my $data_dir = shift @ARGV;

my $scr_name = "gnuplot_script_sample_ctual_cloud_display.script";
my $data_name = "sample_actual_cloud_display.log";
my $png_name = "sample_actual_cloud_display.png";

my $scr_loc = $gnuplot_scripts_dir . "/" . $scr_name;
my $png_loc = $graphs_dir . "/" . $png_name;
my $data_loc = $data_dir . "/" . $data_name;

if( !(-e "$data_loc" ) ){
	print "[ERROR] Cannot locate data file $data_loc\n";
	exit(1);
};

print "\n";
print "================= PLOT SAMPLE OF ACTUAL CLOUD DISPLAY  =====================\n";
print "\n";

system("mkdir -p $gnuplot_scripts_dir");
system("mkdir -p $graphs_dir");

open( SCR, "> $scr_loc" ) or die $!;

print SCR "set title \"EUCA MONKEY: SAMPLE OF ACTUAL CLOUD DISPLAY\"\n";
print SCR "set key outside top\n";
print SCR "set border linewidth 2\n";
print SCR "set xdata time\n";
print SCR "set timefmt \"%Y-%m-%d:%H:%M:%S\"\n";
print SCR "set xlabel \"MINUTE\"\n";
print SCR "set format x \"%M\"\n";
print SCR "set ylabel \"COUNT\"\n";
print SCR "set ytics 0, 2\n";
print SCR "set terminal png size 1200, 800\n";
print SCR "set output \"" . $png_loc ."\"\n";
print SCR "plot \"" . $data_loc . "\" using 1:5 title \"Running Instances\" with lines,";
print SCR "\"" . $data_loc . "\" using 1:6 title \"Volumes\" with lines,";
print SCR "\"" . $data_loc . "\" using 1:7 title \"Snapshots\" with lines,";
print SCR "\"" . $data_loc . "\" using 1:8 title \"Security Groups\"with lines,";
print SCR "\"" . $data_loc . "\" using 1:9 title \"Keypairs\"with lines,";
print SCR "\"" . $data_loc . "\" using 1:10 title \"IP Addresses\"with lines\n";
print SCR "exit\n";

close( SCR );

system("gnuplot $scr_loc");

print "\n";
print "===================== DONE =====================\n";
print "\n";

exit(0);

1;


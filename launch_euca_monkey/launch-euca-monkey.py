#!/usr/bin/env python

import time
import sys
import os
from optparse import OptionParser

def run_cmd(command):
	print "CMD: " + command
	print
	os.system(command)
	print	
	time.sleep(1)
	return

def main():

	print
	print "===== LAUNCH EUCA MONKEY !! ======"
	print

	print
	print

	cmd = "cp -f ./conf/2b_tested.lst ../myworkspace/."
        run_cmd(cmd)

	cmd = "cp -f ./conf/*.ini ../cloud_user_workload_generator/conf/."
	run_cmd(cmd)

	cmd = "source ../myvirtualenv/bin/activate; cd ../cloud_user_workload_generator; nohup ./cloud-user-workload-generator.pl > workload.out 2> workload.out &"
	run_cmd(cmd)

	cmd = "mkdir -p /var/www/html/graphs"
	run_cmd(cmd)

	cmd = "cd ../cloud_user_workload_generator/plot_cloud_user_data; nohup ./plot-auto-renderer.pl > rendered.out 2> rendered.out &"
	run_cmd(cmd)

	print
	print "===== LAUNCH EUCA MONKEY : DONE ====="
	print


if __name__ == "__main__":
    main()
    exit



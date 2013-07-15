#!/usr/bin/env python

import os
import time

def run_cmd(command):

	print
	print "CMD: " + command
	os.system(command);
	print
	time.sleep(1)

def main():

	### INSTALL EUTESTER ENV
	run_cmd("./installer-eutester-env.py");

	### INSTALL GNUPLOT
	run_cmd("sudo yum -y install gnuplot");

	print
	print "==================================================================================="
	print "==================================================================================="
	print "==================================================================================="
	print 

	print "HOW TO RUN CLOUD-RESOURCE-POPULATOR"
	print
	print "Step 1. Activate Virtualenv"
	print
	print "source ./myvirtualenv/bin/activate"
	print

	print "Step 2. Go to the Directory ./myworkspace"
	print
	print "cd ./myworksapce"
	print

	print "Step 3. Download the Test Configuration File via 'wget'"
	print
	print "Ex."
	print "wget http://10.1.1.210/test_space/UI-src-centos6-01/1021/load_image_test/input/2b_tested.lst"
	print
 
	print "Step 4. Run cloud-resource-populator.py"
	print
	print "Ex."
	print "./cloud-resource-populator.py --accountname ui-test-acct-22 --username user22 --password mypassword22 --running-instance-count 2 --volume-count 2 --snapshot-count 2 --keypair-count 3 --security-group-count 2 --ip-count 2 --create-bfebs 0"
	print


if __name__ == '__main__':
    main()



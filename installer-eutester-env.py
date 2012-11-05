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

	this_virtenv = "myvirtualenv"

	### INSTALL DEPENDENCIES
	run_cmd("yum -y update");
	run_cmd("yum -y install git gcc python-paramiko python-devel");
	
	### NTP SYNC
	run_cmd("ntpdate 192.168.51.150");

	### SET UP VIRTUALENV
	run_cmd("yum -y install python-setuptools");
	run_cmd("easy_install virtualenv");
	run_cmd("mkdir -p " + this_virtenv);
	run_cmd("virtualenv " + this_virtenv);
	
	this_env = "cd " + this_virtenv + "/bin; source ./activate; cd ../..;";

	### INSTALL BOTO
#	run_cmd("wget http://192.168.51.136/deps/boto-2.5.2.tar.gz -O ./dependencies/boto-2.5.2.tar.gz");
	run_cmd("cd ./dependencies; tar zxvf boto-2.5.2.tar.gz")
	run_cmd(this_env + " cd ./dependencies/boto-2.5.2/; python setup.py install");

	### INSTALL ARGPARSE
#	run_cmd("wget http://192.168.51.136/deps/argparse-1.2.1.tar.gz -O ./dependencies/argparse-1.2.1.tar.gz");
	run_cmd("cd ./dependencies; tar zxvf argparse-1.2.1.tar.gz");
	run_cmd(this_env + " cd ./dependencies/argparse-1.2.1/; python setup.py install");

	### CLONE EUTESTER
	run_cmd("rm -fr ./eutester")
	run_cmd("git clone https://github.com/eucalyptus/eutester.git");
	run_cmd("cd eutester; git checkout testing");
	run_cmd(this_env + " cd ./eutester; python ./setup.py install");
	

if __name__ == '__main__':
    main()



#!/usr/bin/env python

import os
import time
import argparse
from eucaops import Eucaops


def create_new_account_if_needed(tester, accountname):
    print
    print "=== CREATE ACCOUNT ==="
    print
    exists_account = 0
    list_account = tester.get_all_accounts()
    for acct in list_account:
	if acct.account_name == accountname:
		exists_account = 1

    if exists_account is 0:
    	tester.create_account(accountname)
    else:
	print
	print "ACCOUNT " + accountname + " EXISTS ALREADY!"
    return exists_account


def create_new_policy_group_for_account_if_needed(tester, accountname, groupname):
    ### STATIC VARIABLE
    allow_all_policy = """{
          "Statement": [
            {
             "Action": "ec2:*",
              "Effect": "Allow",
              "Resource": "*"
            },
         {
              "Action": "s3:*",
              "Effect": "Allow",
              "Resource": "*"
            }
          ]
    }"""
    
    print
    print "=== CREATE POLICY GROUP ==="
    print
    exists_group = 0
    list_group = tester.get_all_groups()
    for group in list_group:
	if group.group_name == groupname:
		exists_group = 1

    if exists_group is 0:
	tester.create_group(groupname, "/", accountname)
	tester.attach_policy_group(groupname, "allow-all", allow_all_policy, accountname)
    else:
	print
	print "GROUP " + groupname + " EXISTS ALREADY!"
    return exists_group


def create_new_user_if_needed(tester, accountname, groupname, username):
    print
    print "=== CREATE USER ==="
    print
    exists_user = 0
    list_user = tester.get_all_users(account_name=accountname)
    for user in list_user:
	if user.user_name == username:
		exists_user = 1

    if exists_user is 0:
    	tester.create_user(username, "/", accountname)
    	tester.add_user_to_group(groupname, username, accountname)
    else:
	print
	print "USER " + username + " EXISTS ALREADY!"
    return exists_user


def set_password_for_user(tester, accountname, username, password):
    print
    print "=== SET PASSWORD ==="
    print
    ###	SOURCE-BUILD ONLY FOR NOW	102312
    admin_cred_dir = "ACCT-eucalyptus-USER-admin"
    tester.sys("/opt/eucalyptus/usr/sbin/euca_conf --get-credentials admin_creds.zip")
    tester.sys("mkdir -p " + admin_cred_dir)
    tester.sys("mv -f ./admin_creds.zip /root/" + admin_cred_dir + "/.; cd /root/ACCT-eucalyptus-USER-admin; unzip -o admin_creds.zip")
    tester.sys("source /root/" + admin_cred_dir + "/eucarc; euare-useraddloginprofile --delegate " + accountname + " -u " + username + " -p " + password)
    return;


def download_user_credentials(tester, accountname, username):
    print
    print "=== DOWNLOAD USER CREDENTIALS ==="
    print
    user_cred_dir = "ACCT-" + accountname + "-USER-" + username
    tester.sys("mkdir -p " + user_cred_dir)
    tester.create_credentials(user_cred_dir, accountname, username)
    os.system("mkdir -p ./" + user_cred_dir)
    tester.download_creds_from_clc(user_cred_dir)
    return user_cred_dir


def display_resources(user):
    print
    print "=== DISPLAY RESOURCES ==="
    print
    print "[RESOURCE] Time Stamp: " + time.strftime("%Y/%m/%d %H:%M:%S", time.localtime())
    keypairs = user.ec2.get_all_key_pairs()
    print "[RESOURCE] Keypairs: " + str(len(keypairs))
    ips = user.ec2.get_all_addresses()
    print "[RESOURCE] IP Addresses: " + str(len(ips))
    images = user.ec2.get_all_images()
    print "[RESOURCE] Images: " + str(len(images))
    snapshots = user.ec2.get_all_snapshots()
    print "[RESOURCE] Snapshots: " + str(len(snapshots))
    instances = user.get_instances(state='running')
    print "[RESOURCE] Running Instances: " + str(len(instances))
    volumes = user.ec2.get_all_volumes()
    print "[RESOURCE] Volumes: " + str(len(volumes))
    groups = user.ec2.get_all_security_groups()
    print "[RESOURCE] Security Groups: " + str(len(groups))
    print
    return


def clear_resources(user):
    print
    print "=== CLEAR ALL RESOURCES ==="
    print
    keypairs = user.ec2.get_all_key_pairs()
    for keypair in keypairs:
    	user.delete_keypair(keypair)
    ips = user.ec2.get_all_addresses()
    for ip in ips:
	user.release_address(ip)
    images = user.ec2.get_all_images()
    for image in images:  
	if image.root_device_type == "ebs":
		user.ec2.deregister_image(image.id)
    snapshots = user.ec2.get_all_snapshots()
    for snapshot in snapshots:
    	user.delete_snapshot(snapshot)
    user.terminate_instances()
    volumes = user.ec2.get_all_volumes()
    for volume in volumes:
	user.delete_volume(volume)
    groups = user.ec2.get_all_security_groups()
    for group in groups:
    	user.delete_group(group)
    return


def generate_keypairs_for_given_count(user, count):
    print
    print "=== GENERATE KEYPAIRS AS USER ==="
    print
    print "KEYPAIR COUNT: " + str(count)
    print
    keypair = ""
    for i in xrange(count):
	keypair_name = "my-keypair-" + str(i) + "t" + str(int(time.time()))
	keypair = user.add_keypair(key_name=keypair_name)
    return keypair


def generate_security_groups_for_given_count(user, count):
    print
    print "=== GENERATE SECURITY GROUPS AS USER ==="
    print
    print "SECURITY GROUP COUNT: " + str(count)
    print
    group = ""
    for i in xrange(count):
	security_group_name = "my-security-group-" + str(i) + "t" + str(int(time.time()))
	group = user.add_group(group_name=security_group_name)
	user.authorize_group(group)
    return group


def allocate_ip_addresses_for_given_count(user, count):
    print
    print "=== ALLOCATE IP AS USER ==="
    print
    print "IP COUNT: " + str(count)
    print
    for i in xrange(count):
	user.allocate_address()
    return


def get_name_of_availablity_zone_for_given_index(user, index):
    print
    print "=== GET AVAILABILITY ZONE ==="
    print
    zones = user.ec2.get_all_zones("verbose")
    this_zone = zones[index].name
    print "ZONE: " + this_zone
    return this_zone


def create_bfebs_image_as_user(user, keypair, security_group, zone):
    print
    print "=== CREATE BFEBS IMAGE AS USER ==="
    print
    this_image = ""
    bfebs_reservation = user.run_instance(keypair=keypair, group=security_group, zone=zone)
    this_instance = bfebs_reservation.instances[0]
    before_attach = this_instance.get_dev_dir()
    this_volume=user.create_volume(zone, 2)
    this_volume_device = "/dev/sdf"
    this_volume.attach(this_instance.id, this_volume_device)
    user.sleep(30)
    after_attach = this_instance.get_dev_dir()
    new_devices = user.diff(after_attach, before_attach)
    this_volume_device_after_attach = "/dev/" + new_devices[0].strip()
    this_bfebs_img_url = "http://mirror.qa.eucalyptus-systems.com/bfebs-image/vmware/bfebs_vmwaretools.img"
    this_instance.sys("curl " + this_bfebs_img_url + " > " + this_volume_device_after_attach, timeout=800)
    this_snapshot = user.create_snapshot(this_volume.id)
    this_image_id = user.register_snapshot(this_snapshot)
    this_image = user.get_emi(this_image_id)
    print
    print "CREATED BFEBS IMAGE: " + str(this_image)
    print
    return this_image


def create_volume_for_given_count(user, zone, count):
    print
    print "=== CREATE VOLUME AS USER ==="
    print
    volume = ""
    print "VOLUME COUNT: " + str(count)
    print "ZONE: " + zone
    print
    for i in xrange(count):
	volume = user.create_volume(zone)
    return volume


def run_instance_for_given_count(user, keypair, security_group, zone, count):
    print
    print "=== RUN INSTANCE AS USER ==="
    print
    print "INSTANCE COUNT: " + str(count)
    print
    reservation = ""
    for i in xrange(count):
	    reservation = user.run_instance(keypair=keypair.name, group=security_group.name, zone=zone, private_addressing=True)
    return reservation


def create_snapshot_for_given_count(user, instance, volume, count):
    print
    print "=== CREATE SNAPSHOT AS USER ==="
    print
    print "SNAPSHOT COUNT: " + str(count)
    print
    if count is not 0:
    	user.attach_volume(instance, volume, "/dev/sdb3")
    	for i in xrange(count):
		user.create_snapshot(volume.id)
    return


def main():

    print
    print "===== EUCA-POPULATE-RESOURCES ====="
    print

    ### PARSE ARGUEMENT
    parser = argparse.ArgumentParser(description='Populate User Resources on AWS-Compatible Cloud')
    parser.add_argument('--credpath', default="NONE")
    parser.add_argument("--accountname", default="ui-test-acct-00")
    parser.add_argument("--username", default="user00")
    parser.add_argument("--password", default="mypassword1")
    parser.add_argument("--running-instance-count", type=int, default=0)
    parser.add_argument("--volume-count", type=int, default=0)
    parser.add_argument("--snapshot-count", type=int, default=0)
    parser.add_argument("--keypair-count", type=int, default=1)
    parser.add_argument("--security-group-count", type=int, default=1)
    parser.add_argument("--ip-count", type=int, default=0)
    parser.add_argument("--create-bfebs", type=int, default=0)
    parser.add_argument("--clear-resources", type=int, default=0)
    parser.add_argument("--display-resources", type=int, default=0)
    args = parser.parse_args()
    
    ### PRINT ARGUMENT
    print
    print "=== INPUT ARGUMENT ==="
    print
    if args.credpath is not "NONE":
	print "CREDENTIALS PATH: " + args.credpath
	print
    print "ACCOUNTNAME: " + args.accountname
    print "USERNAME: " + args.username
    print "PASSWORD: " + args.password
    print
    print "RUNNING INSTANCE COUNT: " + str(args.running_instance_count)
    print "VOLUME COUNT: " + str(args.volume_count)
    print "SNAPSHOT COUNT: " + str(args.snapshot_count)
    print "KEYPAIR COUNT: " + str(args.keypair_count)
    print "SECURITY GROUP COUNT: " + str(args.security_group_count)
    print "IP COUNT: " + str(args.ip_count)
    print
    if args.create_bfebs is not 0:
	print "CREATE BFEBS: YES"
	print
    if args.clear_resources is not 0:
	print "CLEAR RESOURCES: YES"
	print
    if args.display_resources is not 0:
	print "DISPLAY RESOURCES: YES"
	print

    print
    print
    print

    ### INITIALIZE EUTESTER OBJECT
    print 
    print "=== INITIALIZE EUTEST OBJECT ==="
    print
#    CANNOT PULL USER CREDENTIALS WITH ONLY ADMIN CREDENTIALS, NEED TO LOG INTO CLC DIRECTLY
#    tester = Eucaops(credpath=args.credpath)
    tester = Eucaops(config_file='2b_tested.lst', password='foobar')

    ### CREATE NEW ACCOUNT IF NEEDED
    exists_account = create_new_account_if_needed(tester, args.accountname)

    ### CREATE GROUP IF NEEDED
    groupname = "allow-all-group-" + args.accountname
    exists_group = create_new_policy_group_for_account_if_needed(tester, args.accountname, groupname)

    ### CREATE USER IF NEEDED
    exists_user = create_new_user_if_needed(tester, args.accountname, groupname, args.username)

    ### CREATE PASSWORD IF NEEDED
    if exists_user is 0:
	set_password_for_user(tester, args.accountname, args.username, args.password)

    ### DOWNLOAD USER CREDENTIALS
    user_cred_dir = download_user_credentials(tester, args.accountname, args.username)

    print
    print
    print

    ### INITIALIZE EUTESTER OBJECT AS USER
    print
    print "=== INITIALIZE EUTESTER OBJECT AS USER ==="
    print
    user_tester = Eucaops(credpath=user_cred_dir)

    ### DISPLAY RESOURCES AND EXIT
    if args.display_resources is not 0:
    	display_resources(user_tester)
    	exit(0)

    ### CLEAR RESOURCES IF REQUESTED
    if args.clear_resources is not 0:
    	clear_resources(user_tester)
	if args.clear_resources is 2:
    		print
    		print "===== EUCA-POPULATE-RESOURCES: DONE ====="
    		print
		exit(0)

    ### GENERATE KEYPAIR AS USER
    this_keypair = generate_keypairs_for_given_count(user_tester, args.keypair_count)

    ### GENERATE SECURITY GROUPS AS USER
    this_security_group = generate_security_groups_for_given_count(user_tester, args.security_group_count)

    ### ALLOCATE IP AS USER
    allocate_ip_addresses_for_given_count(user_tester, args.ip_count)

    ### GET FIRST AVAILABILITY ZONE
    this_zone = get_name_of_availablity_zone_for_given_index(user_tester, 0)
    
    ### CREATE BFEBS IMAGE
    if args.create_bfebs is not 0:
	create_bfebs_image_as_user(user_tester, this_keypair, this_security_group, this_zone)

    ### CREATE VOLUME AS USER
    this_volume = create_volume_for_given_count(user_tester, this_zone, args.volume_count)

    ### RUN INSTANCE AS USER
    this_reservation = run_instance_for_given_count(user_tester, this_keypair, this_security_group, this_zone, args.running_instance_count)

    ### CREATE SNAPSHOT AS USER
    if args.running_instance_count is not 0:
    	create_snapshot_for_given_count(user_tester, this_reservation.instances[0], this_volume, args.snapshot_count)

    print
    print "===== EUCA-POPULATE-RESOURCES: DONE ====="
    print
    
    exit(0)

if __name__ == "__main__":
	main()
	exit


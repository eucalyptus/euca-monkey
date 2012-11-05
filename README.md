
# EUCA MONKEY

Eucalyptus Stress Tester with Webservice Rendering Support

## Requirement

  * Centos 6.3 Machine
  * Running Eucalyptus System Build by the QA System
    * Loaded with at least one Public Instance Image
    * URL to 2b_tested.list
      * ex.
<code>
http://10.1.1.210/test_space/UI-src-centos6-01/1021/load_image_test/input/2b_tested.lst
</code>

## INSTALLATION

On a Centos 6.3 Machine:

== Step 1. ==
Install GIT

<code>
yum -y install git
</code>

== Step 2. ==
Clone euca-monkey
  
<code>
git clone kyolee@git.eucalyptus-systems.com:/mnt/repos/qa/others/euca-monkey
</code>

== Step 3. ==
Go to the Directory "euca-monkey"

<code>
cd ./euca-monkey
</code>

== Step 4. ==
Run the Installer for cloud-resource-populator

<code>
./installer-cloud-resource-populator.py
</code>

== Step 5. ==
Run the Installer for euca-monkey-webserice

<code>
./installer-euca-monkey-webservice.py
</code>

== Step 6. ==

Go to the Directory "launch_euca_monkey"

<code>
cd ./launch_euca_monkey
</code>

== Step 7. ==

Configure the Euca Monkey Environement Files, "2b_tested.lst" and "generator.ini" in "./conf" Directory

<code>
cd ./conf
vim ./2b_tested.lst
vim ./generator.ini
</code>

Or, Download 2b_tested.lst File Directly

Ex.

<code>
wget http://10.1.1.210/test_space/UI-src-centos6-01/1021/load_image_test/input/2b_tested.lst
</code>


== Step 8. ==

Launch the Euca Monkey

<code>
cd ..
./launch-euca-monkey.py
</code>

== Step. 9 ==

Check out the Progress on the Browser

Ex.

<code>
http://192.168.51.84/euca-monkey.php
</code>

, where 192.168.51.84 is the IP of your Tester machine.


# EUCA MONKEY

**EUCA MONKEY** is Eucalyptus Stress Tester with Webservice Rendering Support.
  * **EUCA MONKEY** runs on **cloud-resource-populator**, which is based on **Eutester**.


## SYSTEM REQUIREMENT

  * 1 Tester Machine - Centos 6.3 Machine/VM
    * Port 80 Open         
  * Running Eucalyptus System
    * CLC machine needs to be accessble from the Tester Machine above, via **pub-key exchange**.
      * On Tester Machine,
<code>
cat ~/.ssh/id_rsa.pub
</code>
      * On CLC Machine,
<code>
vim ~/.ssh/authorized_keys
</code>
    * Eucalyptus must be Loaded with, at least, one Public Instance Image

## CONFIGURATION FILE

### ./launch_euca_monkey/conf/2b_tested.lst

  * Description of Eucalyptus Configuration
    * Format - the items need to be separated by tabs:
<pre>
192.168.51.37 CENTOS	6.3	64	BZR	[UI CC00 CLC SC00 WS]
192.168.51.38 CENTOS	6.3	64	BZR	[NC00]
</pre>

    * For internal QA machines, it can be easibly obtainable via test config URL:
      * Example.
<code>
wget http://10.1.1.210/test_space/UI-src-centos6-01/1021/load_image_test/input/2b_tested.lst
</code>

### ./launch_euca_monkey/conf/generator.ini

  * Description of Workload generation by cloud-resource-populator
    * Format:
<pre>
[USER INFO]
account: cloud-user-test-acct-00
user: cloud-user-00
password: mypassword00
[RESOURCES]
running instances: 2
volumes:  1
snapshots: 1
security groups: 3
keypairs: 7
ip addresses: 2
[ITERATIONS]
iterations: 200
</pre>

## INSTALLATION

On a Centos 6.3 Tester Machine:

### Step 1.
Install GIT

<code>
yum -y install git
</code>

### Step 2.
Clone euca-monkey
  
<code>
git clone git://github.com/eucalyptus/euca-monkey.git
</code>

### Step 3.
Go to the Directory "euca-monkey"

<code>
cd ./euca-monkey
</code>

### Step 4.
Run the Installer for cloud-resource-populator
  * Ignore the "next steps" instructions at the end of this script run.

<code>
./installer-cloud-resource-populator.py
</code>

### Step 5.
Run the Installer for euca-monkey-webserice

<code>
./installer-euca-monkey-webservice.py
</code>

### Step 6.
Check out **euca-monkey.php** page on a web-browser to ensure that httpd is running correctly.

<code>
http://192.168.51.84/euca-monkey.php
</code>
  * where 192.168.51.84 is the IP of your Tester machine.

If you cannot see the monkeys, check out your firewall setting and disable it:

<code>
system-config-firewall-tui
</code>

### Step 7.

Go to the Directory "launch_euca_monkey"

<code>
cd ./launch_euca_monkey
</code>

### Step 8.

Configure the Euca Monkey Environement Files, "2b_tested.lst" and "generator.ini" in "./conf" Directory
  * See the CONFIGURATION FILE section above

<code>
vim ./conf/2b_tested.lst
</code>

<code>
vim ./conf/generator.ini
</code>

### Step 9.

Launch the Euca Monkey

<code>
./launch-euca-monkey.py
</code>

### Step 10.

Watch the Progress on the Browser

<code>
http://192.168.51.84/euca-monkey.php
</code>
  * where 192.168.51.84 is the IP of your Tester machine.

## CONTACT

Please feel free to contact the contributors if you have any questions or issues with Euca Monkey:

Kyo Lee

kyo.lee@eucalyptus.com

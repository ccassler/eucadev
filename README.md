### **eucadev** ➠ _tools for Eucalyptus developers and testers_

These tools allow one to deploy a Eucalyptus cloud—in a Vagrant-provisioned VM or in a cloud instance from AWS or Eucalyptus—with minimal effort. Currently, only single-node installations in virtual resources are supported, but we have plans to support multiple nodes, bare-metal provisioining, and more.



### Dev/test environment in a VirtualBox VM

This method produces a dev/test environment in a single virtual machine, with all Eucalyptus components deployed in it. By default, components will be built from latest source, which can be modified and immediately tested on the VM.  The source will be located on a 'synced folder' (`eucalyptus-src`), which can be edited on the host system but built on the guest system. Alternatively, you can install from latest packages, saving time.

1. Install [VirtualBox](https://www.virtualbox.org)

2. Install [Vagrant](http://www.vagrantup.com/)

3. Install [git](http://git-scm.com)

4. Install vagrant plugins

        $ vagrant plugin install vagrant-berkshelf
        $ vagrant plugin install vagrant-omnibus
        $ vagrant plugin install vagrant-aws

5. Check out [eucadev](https://github.com/eucalyptus/eucadev) (ideally [fork](http://help.github.com/fork-a-repo/) it and clone the fork to your local machine, so you can contribute):

        $ git clone https://github.com/eucalyptus/eucadev.git

6. *Optionally:* Check the default parameters in `roles/cloud-controller-source.json` and `Vagrantfile`
  * `install-type` is `"source"` by default. Set the value to `"package"` for an RPM-based installation,  which can take less than half the time of a source install (e.g., 20 min instead of 48), but won't allow you to edit and re-deploy code easily.
  * In Vagrantfile, `memory` is 3GB (`3072`) by default. For a source-based install without a Web console, you may be able to get away with less, such as 1GB. Giving the VM more should improve performance.

7. Start the VM and wait for eucadev to install Eucalyptus in it (may take a long time, _20-60 min_ or more):

        $ cd eucadev; vagrant up
        
##### What now?

* If the test instance started successfully, you can try connecting to it via SSH:
  * Connect to the VM hosting the cloud: `$ vagrant ssh`
  * Become `root` to read the credentials: `$ sudo bash`
  * Source the Eucalyptus configuration file: `# source /root/eucarc`
  * Look up the IP of the running instnace: `# euca-describe-instances `
  * Connect to the instance from the VM: `# ssh -k /root/my-first-keypair root@PUBLIC-IP-OF-THE-INSTANCE`

* Connect to the Eucalyptus admin console: 
  * In a Web browser on your host, go to `https://localhost:8443`
  * Accept the untrusted server certificate
  * Use `admin` for _both_ login and password
  * After a forced change of the password to something other than `admin` you'll be good to go
  
* Install [euca2ools](https://github.com/eucalyptus/euca2ools) on your host and control the cloud from the command line:

        $ source creds/eucarc
        $ euca-describe-instances 
        RESERVATION	r-49C1448D	539043227142	default
        INSTANCE	i-E4C54166	emi-34793865	192.168.192.102	1.0.217.179	running	my-first-keypair	0		m1.small	2013-12-05T23:11:59.118Z	cluster1	eki-58DF396F	eri-BB603B1C		        monitoring-disabled	192.168.192.102	1.0.217.179			instance-store					paravirtualized				
        TAG	instance	i-E4C54166	euca:node	10.0.2.15
        
  * **Note:** you won't be able to connect to cloud instances from your host, only from inside the VM.
        
        
### Dev/test environment in AWS or Eucalyptus

This method produces a dev/test environment in a single cloud instance, with all components deployed in it. (Yes, you can run a Eucalyptus cloud in a Eucalyptus cloud or run a Eucalyptus cloud in an Amazon cloud. _Inception!_) By default, components will be built from latest source, which can be modified and immediately tested on the VM.  Alternatively, you can install from latest packages, saving time.

1. Install [Vagrant](http://www.vagrantup.com/)

2. Install the Vagrant-AWS plugin:

        $ vagrant plugin install vagrant-aws
        
3. Check out [eucadev](https://github.com/eucalyptus/eucadev) (ideally [fork](http://help.github.com/fork-a-repo/) it and clone the fork to your local machine, so you can contribute)

        $ git clone https://github.com/eucalyptus/eucadev.git
        
4. Edit the parameters in `eucadev/Vagrantfile` to suit your needs:
  * `method` of installation is `"source"` by default. Set the value to `"package"` for an RPM-based installation,  which can take less than half the time of a source install, but won't allow you to edit and re-deploy code easily.
  * `aws.instance_type` is `m1.medium` by default. Consider whether this instance type has sufficient memory for your Eucalyptus cloud. For a source-based install without a Web console, you may be able to get away with 1GB, but we recommend 3GB for a typical installation. Selecting a beefier instance should improve performance
  * Change the other variables to match the parameters of the cloud that you would like to use:

    ```     
    aws.access_key_id = "XXXXXXXXXXXXXXXXXX"
    aws.secret_access_key = "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
    aws.instance_type = "m1.medium"
    ## This CentOS 6 EMI needs to have the following commented out of /etc/sudoers,
    ## Defaults    requiretty
    aws.ami = "emi-1873419A"
    aws.security_groups = ["default"]
    aws.region = "eucalyptus"
    aws.endpoint = "http://10.0.1.91:8773/services/Eucalyptus"
    aws.keypair_name = "vic"
    override.ssh.username ="root"
    override.ssh.private_key_path ="/Users/viglesias/.ssh/id_rsa"
    ```
5. Install a "dummy" vagrant box file to allow override of the box with the ami/emi:

        $ vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
        
6. Start the VM and wait for eucadev to install Eucalyptus in it (may take a long time, _20-60 min_ or more):
        
        $ cd eucadev; vagrant up --provider=aws

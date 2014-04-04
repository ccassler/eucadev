#!/bin/bash
#
# Script to automate the install of vagrant plugins as well
# as Vagrantfile configuration.
#


# Configuration related files
license_file="license.lic"

# Vagrant checks
check_vagrant=$(vagrant -v | wc -l)

# Check if Vagrant is installed
if [ $check_vagrant -eq 0 ] ; then
    echo -e "\nVagrant not installed.  Please install vagrant and re-run script...exiting.\n"
    exit
else
    vagrant_loc=`which vagrant`
fi

# Vagrant plugin installs
vagrant_mod() {
    for val in ${plugin_checks[@]} ; do
        check_plugin=`$vagrant_loc plugin list | grep -c -i $val`
        if [ "$check_plugin" -eq "0" ] ; then
            echo -e "\nInstalling Vagrant Plugin $val..."
            if [ "$val" == "license" ] ; then
                    if [ -f $license_file ] ; then
                        $vagrant_loc plugin $val vagrant-vmware-fusion $license_file
                    else
                        echo -e "\nVMWARE $license_file file not found.  Please obtain valid VMWare license and re-run script...exiting.\n"
                        exit
                    fi
            else
                $vagrant_loc plugin install vagrant-$val
            fi
        fi
    done
    echo -e "\nDone!"
}
    

# Check and/or install vagrant plugins and modify Vagrantfile for VM instance.
case "$1" in
  # VirtualBox
  vbox)
        plugin_checks=("berkshelf" "omnibus")
        vagrant_mod
        vagrant up
        ;;
  # VMWare
  vmware)
        plugin_checks=("vmware-fusion" "license")
        vagrant_mod
        ;;
  # Amazon Web Service
  aws)
        plugin_checks=("berkshelf" "omnibus" "aws")
        vagrant_mod
        ;;
  *)
        echo -e "\nUsage: $0 {vbox|vmware|aws}" >&2
        exit 1
        ;;
esac

exit 0

#!/bin/bash
#
# Script to automate the install of vagrant plugins as well
# as Vagrantfile configuration.
#

# Plugin checks for various VM devices
vbox_checks=("berkshelf" "omnibus")
vmware_checks=("vmware-fusion" "license")
aws_checks=("berkshelf" "omnibus" "aws")

# Configuration related files
vagrant_file="Vagrantfile"
temp_file="Vagrant.temp"
license_file="license.lic"

# Remove Vagrant temp file if it already exists.
if [ -f $temp_file ] ; then
    rm -f $temp_file
fi

# Vagrant checks
check_vagrant=$(vagrant -v | wc -l)
vagrant_url="http://euca-vagrant.s3.amazonaws.com"
vagrant_file_url=$(grep u.vm.box_url Vagrantfile)

# Check if Vagrant is installed
if [ $check_vagrant -eq 0 ] ; then
    echo -e "\nVagrant not installed.  Please install vagrant and re-run script...exiting.\n"
    exit
else
    vagrant_loc=`which vagrant`
fi

# Replace vagrant url based on virtual machine used.
change_vagrant_url() {
    vmchoice="$1"
    while IFS= read line ; do
        echo "${line/u.vm.box_url = */u.vm.box_url = \"$vagrant_url/euca-deps-$vmchoice.box\"}" >> $temp_file
    done < $vagrant_file
    mv -f $temp_file $vagrant_file
}


# Check and/or install vagrant plugins and modify Vagrantfile for VM instance.
case "$1" in
  # VirtualBox
  vbox)
        for val in ${vbox_checks[@]} ; do
            check_plugin=`$vagrant_loc plugin list | grep -c -i $val`
            if [ "$check_plugin" -eq "0" ] ; then
                echo -e "\nInstalling Vagrant Plugin $val..."
                $vagrant_loc plugin install vagrant-$val
                echo -e "\nDone!"
            fi
        done
        change_vagrant_url virtualbox
        vagrant up
        ;;
  # VMWare
  vmware)
        for val in ${vmware_checks[@]} ; do
            check_plugin=`$vagrant_loc plugin list | grep -c -i $val`
            if [ "$check_plugin" -eq "0" ] ; then
                echo -e "\nInstalling Vagrant Plugin $val..."
                if [ "$val" == "license" ] ; then
                    if [ ! -f $license_file ] ; then
                        echo -e "\nVMWARE $val.lic file not found.  Please obtain valid VMWare license and re-run script...exiting.\n"
                        exit
                    else
                        $vagrant_loc plugin $val vagrant-$val license.lic
                    fi
                else
                    $vagrant_loc plugin install vagrant-$val
                fi
                echo -e "\nDone!"
            fi
        done
        change_vagrant_url vmware
        ;;
  # Amazon Web Service
  aws)
        for val in ${aws_checks[@]} ; do
            check_plugin=`$vagrant_loc plugin list | grep -c -i $val`
            if [ "$check_plugin" -eq "0" ] ; then
                echo -e "\nInstalling Vagrant Plugin $val..."
                $vagrant_loc plugin install vagrant-$val
                echo -e "\nDone!"
            fi
        done
        change_vagrant_url aws
        ;;
  *)
        echo -e "\nUsage: $0 {vbox|vmware|aws}" >&2
        exit 1
        ;;
esac

exit 0

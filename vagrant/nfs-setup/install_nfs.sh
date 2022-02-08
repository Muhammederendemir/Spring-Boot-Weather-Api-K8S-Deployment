#!/bin/bash

# install nfs server


# get some variables #####################################################################

IP_RANGE=192.168.50.0

NFS_PATH=/srv/kubedata


for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            IP_RANGE) IP_RANGE=${VALUE};;
            *)
    esac

done

echo "IP_RANGE =$IP_RANGE"


# Functions #####################################################################


prepare_directories(){
sudo mkdir -p ${NFS_PATH}
sudo chmod 777 -R ${NFS_PATH}
}

install_nfs(){

sudo apt-get install -y nfs-kernel-server 2>&1 > /dev/null

}

set_nfs(){
sudo echo "${NFS_PATH} ${IP_RANGE}/24(rw,sync,no_root_squash,no_subtree_check)">/etc/exports
}

run_nfs(){
sudo systemctl restart nfs-server rpcbind
sudo exportfs -a
}

# Let's go #######################################################################
prepare_directories
install_nfs
set_nfs
run_nfs
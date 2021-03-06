#!/bin/bash

source /vagrant/utils/common-functions

install_ovs

hostname=$(hostname)
ip=${!hostname}

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
/usr/share/openvswitch/scripts/ovn-ctl start_controller

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=tcp:192.168.50.10:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=$ip

ovs-vsctl --may-exist add-br br-ex
ovs-vsctl br-set-external-id br-ex bridge-id br-ex
ovs-vsctl br-set-external-id br-int bridge-id br-int
ovs-vsctl set open . external-ids:ovn-bridge-mappings=external:br-ex

# Add eth2 to br-ex
ovs-vsctl add-port br-ex eth2

sleep 3

# Add fake VMs
case "$HOSTNAME" in
    worker1)
        ovn_add_phys_port vm1 40:44:00:00:00:01 192.168.0.11 24 192.168.0.1
        ;;
    worker2)
        ovn_add_phys_port vm2 40:44:00:00:00:02 192.168.0.12 24 192.168.0.1
        ovn_add_phys_port vm3 40:44:00:00:00:03 192.168.1.13 24 192.168.1.1
        ;;
esac

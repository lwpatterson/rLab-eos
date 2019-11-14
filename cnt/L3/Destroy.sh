#!/bin/bash
sudo ovs-docker del-port l3leaf21leaf22 eth1 l3leaf21
sudo ovs-docker del-port l3spine1leaf21 eth2 l3leaf21
sudo ovs-docker del-port l3spine2leaf21 eth3 l3leaf21
sudo ovs-docker del-port l3leaf21host21 eth4 l3leaf21
docker stop l3leaf21
docker rm l3leaf21
sudo ovs-docker del-port l3leaf21leaf22 eth1 l3leaf22
sudo ovs-docker del-port l3spine1leaf22 eth2 l3leaf22
sudo ovs-docker del-port l3spine2leaf22 eth3 l3leaf22
sudo ovs-docker del-port l3leaf22host22 eth4 l3leaf22
docker stop l3leaf22
docker rm l3leaf22
sudo ovs-docker del-port l3leaf11leaf12 eth1 l3leaf11
sudo ovs-docker del-port l3spine1leaf11 eth2 l3leaf11
sudo ovs-docker del-port l3spine2leaf11 eth3 l3leaf11
sudo ovs-docker del-port l3leaf11host11 eth4 l3leaf11
sudo ovs-docker del-port l3leaf11host12 eth5 l3leaf11
docker stop l3leaf11
docker rm l3leaf11
sudo ovs-docker del-port l3leaf11leaf12 eth1 l3leaf12
sudo ovs-docker del-port l3spine1leaf12 eth2 l3leaf12
sudo ovs-docker del-port l3spine2leaf12 eth3 l3leaf12
docker stop l3leaf12
docker rm l3leaf12
sudo ovs-docker del-port l3leaf31leaf32 eth1 l3leaf32
sudo ovs-docker del-port l3spine1leaf32 eth2 l3leaf32
sudo ovs-docker del-port l3spine2leaf32 eth3 l3leaf32
docker stop l3leaf32
docker rm l3leaf32
sudo ovs-docker del-port l3leaf31leaf32 eth1 l3leaf31
sudo ovs-docker del-port l3spine1leaf31 eth2 l3leaf31
sudo ovs-docker del-port l3spine2leaf31 eth3 l3leaf31
sudo ovs-docker del-port l3leaf31host31 eth4 l3leaf31
sudo ovs-docker del-port l3leaf31host32 eth5 l3leaf31
docker stop l3leaf31
docker rm l3leaf31
sudo ovs-docker del-port l3spine1leaf11 eth1 l3spine1
sudo ovs-docker del-port l3spine1leaf12 eth2 l3spine1
sudo ovs-docker del-port l3spine1leaf21 eth3 l3spine1
sudo ovs-docker del-port l3spine1leaf22 eth4 l3spine1
sudo ovs-docker del-port l3spine1leaf31 eth5 l3spine1
sudo ovs-docker del-port l3spine1leaf32 eth6 l3spine1
sudo ovs-docker del-port l3spine1border1 eth7 l3spine1
sudo ovs-docker del-port l3spine1border2 eth8 l3spine1
docker stop l3spine1
docker rm l3spine1
sudo ovs-docker del-port l3spine2leaf11 eth1 l3spine2
sudo ovs-docker del-port l3spine2leaf12 eth2 l3spine2
sudo ovs-docker del-port l3spine2leaf21 eth3 l3spine2
sudo ovs-docker del-port l3spine2leaf22 eth4 l3spine2
sudo ovs-docker del-port l3spine2leaf31 eth5 l3spine2
sudo ovs-docker del-port l3spine2leaf32 eth6 l3spine2
sudo ovs-docker del-port l3spine2border1 eth7 l3spine2
sudo ovs-docker del-port l3spine2border2 eth8 l3spine2
docker stop l3spine2
docker rm l3spine2
sudo ovs-docker del-port l3spine1border1 eth1 l3border1
sudo ovs-docker del-port l3spine2border1 eth2 l3border1
docker stop l3border1
docker rm l3border1
sudo ovs-docker del-port l3spine1border2 eth1 l3border2
sudo ovs-docker del-port l3spine2border2 eth2 l3border2
docker stop l3border2
docker rm l3border2
sudo ovs-docker del-port l3leaf31host31 eth0 l3host31 --ipaddress=192.168.12.31/24 --gateway=192.168.12.1
docker stop l3host31
docker rm l3host31
sudo ovs-docker del-port l3leaf31host32 eth0 l3host32 --ipaddress=192.168.13.31/24 --gateway=192.168.13.1
docker stop l3host32
docker rm l3host32
sudo ovs-docker del-port l3leaf21host21 eth0 l3host21 --ipaddress=192.168.12.21/24 --gateway=192.168.12.1
docker stop l3host21
docker rm l3host21
sudo ovs-docker del-port l3leaf11host12 eth0 l3host12 --ipaddress=192.168.13.11/24 --gateway=192.168.13.1
docker stop l3host12
docker rm l3host12
sudo ovs-docker del-port l3leaf11host11 eth0 l3host11 --ipaddress=192.168.12.11/24 --gateway=192.168.12.1
docker stop l3host11
docker rm l3host11
sudo ovs-docker del-port l3leaf22host22 eth0 l3host22 --ipaddress=192.168.13.21/24 --gateway=192.168.13.1
docker stop l3host22
docker rm l3host22
sudo ovs-vsctl del-br l3spine1leaf11
sudo ovs-vsctl del-br l3spine1leaf12
sudo ovs-vsctl del-br l3spine1leaf21
sudo ovs-vsctl del-br l3spine1leaf22
sudo ovs-vsctl del-br l3spine1leaf31
sudo ovs-vsctl del-br l3spine1leaf32
sudo ovs-vsctl del-br l3spine1border1
sudo ovs-vsctl del-br l3spine1border2
sudo ovs-vsctl del-br l3spine2leaf11
sudo ovs-vsctl del-br l3spine2leaf12
sudo ovs-vsctl del-br l3spine2leaf21
sudo ovs-vsctl del-br l3spine2leaf22
sudo ovs-vsctl del-br l3spine2leaf31
sudo ovs-vsctl del-br l3spine2leaf32
sudo ovs-vsctl del-br l3spine2border1
sudo ovs-vsctl del-br l3spine2border2
sudo ovs-vsctl del-br l3leaf11leaf12
sudo ovs-vsctl del-br l3leaf11host11
sudo ovs-vsctl del-br l3leaf11host12
sudo ovs-vsctl del-br l3leaf21leaf22
sudo ovs-vsctl del-br l3leaf21host21
sudo ovs-vsctl del-br l3leaf22host22
sudo ovs-vsctl del-br l3leaf31leaf32
sudo ovs-vsctl del-br l3leaf31host31
sudo ovs-vsctl del-br l3leaf31host32

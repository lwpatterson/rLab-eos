#!/bin/bash

# Device Info Mapping
# =====================
# spine1 = l2eb58
# spine2 = l2ed8f
# leaf1 = l2404c
# leaf2 = l24533
# leaf3 = l29ad8
# host10 = l28112
# host11 = l28083
# host20 = l218f3
# host21 = l23005
# host30 = l2a963
# host31 = l23ef7

sudo sh -c 'echo "fs.inotify.max_user_instances = 50000" > /etc/sysctl.d/99-zceos.conf'
sudo sysctl -w fs.inotify.max_user_instances=50000 1> /dev/null 2> /dev/null
if [ "$(sudo podman image ls | grep ceosimage-64 | grep -c 4.28.0F)" == 0 ]
then
    echo "Podman image not found for ceosimage-64:4.28.0F, please build it first."
    exit
fi
if [ "$(sudo podman image ls | grep chost | grep -c 1.0)" == 0 ]
then
    echo "Podman image not found for chost:1.0, please build it first."
    exit
fi
sudo ip netns add L2
# Creating veths
sudo ip link add l2eb58et1 type veth peer name l2ed8fet1
sudo ip link add l2eb58et2 type veth peer name l2404cet1
sudo ip link add l2eb58et3 type veth peer name l24533et1
sudo ip link add l2eb58et4 type veth peer name l29ad8et1
sudo ip link add l2ed8fet2 type veth peer name l2404cet2
sudo ip link add l2ed8fet3 type veth peer name l24533et2
sudo ip link add l2ed8fet4 type veth peer name l29ad8et2
sudo ip link add l2404cet3 type veth peer name l28112et0
sudo ip link add l2404cet4 type veth peer name l28083et0
sudo ip link add l24533et3 type veth peer name l218f3et0
sudo ip link add l24533et4 type veth peer name l23005et0
sudo ip link add l29ad8et3 type veth peer name l2a963et0
sudo ip link add l29ad8et4 type veth peer name l23ef7et0
#
#
# Creating anchor containers
#
# Checking to make sure topo config directory exists
if ! [ -d "/home/luke/rLab-eos/configs/L2" ]; then mkdir /home/luke/rLab-eos/configs/L2; fi
echo "Racking and Stacking spine1"
# Checking for configs directory for each cEOS node
if ! [ -d "/home/luke/rLab-eos/configs/L2/spine1" ]; then mkdir /home/luke/rLab-eos/configs/L2/spine1; fi
if ! [ -f "/home/luke/rLab-eos/configs/L2/spine1/ceos-config" ]; then # Creating the ceos-config file.
echo "SERIALNUMBER=l2spine1" > /home/luke/rLab-eos/configs/L2/spine1/ceos-config
echo "SYSTEMMACADDR=00:1c:73:b0:c6:01" >> /home/luke/rLab-eos/configs/L2/spine1/ceos-config
fi
# Creating a bare startup configuration for spine1
echo "xxxx" > /home/luke/rLab-eos/configs/L2/spine1/token
echo "
service routing protocols model multi-agent
!
schedule tech-support interval 60 timeout 30 max-log-files 5 command show tech-support
!
hostname l2spine1
!
    
aaa authentication login default local
aaa authentication login console local
aaa authorization exec default local
aaa authorization commands all default local
!
no aaa root
!
username arista privilege 15 role network-admin secret sha512 \$6\$BSMT1WbtoeKM/hK4\$kJxcK/KXv4shkWUb9y5MOgNG6EUmmHR5fR4BM2e4uKtXB74lXL1fncHNC0d4xUcW86OJeYapbFZtBdjStkEqv.
!    
    
vrf instance MGMT
interface Management0
   description Management
   vrf MGMT
   ip address 192.168.50.21/24
!
ip routing
!
ip route vrf MGMT 0.0.0.0/0 192.168.50.1
!
management api http-commands
   no shutdown
   vrf MGMT
      no shutdown
!
    
daemon TerminAttr
   exec /usr/bin/TerminAttr -disableaaa -cvaddr=192.168.49.12:9910 -cvvrf=MGMT -taillogs -cvcompression=gzip -cvauth=token,/mnt/flash/token -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -ingestexclude=/Sysdb/cell/1/agent,/Sysdb/cell/2/agent
   no shutdown
!
    " > /home/luke/rLab-eos/configs/L2/spine1/startup-config
echo "Gathering patch cables for spine1"
# Getting spine1 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2spine1-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2spine1pid=$(sudo podman inspect --format '{{.State.Pid}}' l2spine1-net)
sudo ln -sf /proc/${l2spine1pid}/ns/net /var/run/netns/l2eb58
# Connecting cEOS containers together
echo "Plugged patch cable into spine1 port et1"
sudo ip link set l2eb58et1 netns l2eb58 name et1 up
echo "Plugged patch cable into spine1 port et2"
sudo ip link set l2eb58et2 netns l2eb58 name et2 up
echo "Plugged patch cable into spine1 port et3"
sudo ip link set l2eb58et3 netns l2eb58 name et3 up
echo "Plugged patch cable into spine1 port et4"
sudo ip link set l2eb58et4 netns l2eb58 name et4 up
sudo ip link add l2eb58-eth0 type veth peer name l2eb58-mgmt
sudo ip link set l2eb58-eth0 netns l2eb58 name eth0 up
sudo ip netns exec l2eb58 ip link set dev eth0 down
sudo ip netns exec l2eb58 ip link set dev eth0 address 00:1c:73:45:b4:a1
sudo ip netns exec l2eb58 ip link set dev eth0 up
sudo ip link set l2eb58-mgmt up
sleep 1
sudo brctl addif vmgmt l2eb58-mgmt
echo "Powering on spine1"
sudo podman run -d --name=l2spine1 --log-opt max-size=1m --net=container:l2spine1-net --privileged -v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro -v /home/luke/rLab-eos/configs/L2/spine1:/mnt/flash:Z -e INTFTYPE=et -e MGMT_INTF=eth0 -e ETBA=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -i -t ceosimage-64:4.28.0F /sbin/init systemd.setenv=INTFTYPE=et systemd.setenv=MGMT_INTF=eth0 systemd.setenv=ETBA=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker 1> /dev/null 2> /dev/null
echo "Racking and Stacking spine2"
# Checking for configs directory for each cEOS node
if ! [ -d "/home/luke/rLab-eos/configs/L2/spine2" ]; then mkdir /home/luke/rLab-eos/configs/L2/spine2; fi
if ! [ -f "/home/luke/rLab-eos/configs/L2/spine2/ceos-config" ]; then # Creating the ceos-config file.
echo "SERIALNUMBER=l2spine2" > /home/luke/rLab-eos/configs/L2/spine2/ceos-config
echo "SYSTEMMACADDR=00:1c:73:b1:c6:01" >> /home/luke/rLab-eos/configs/L2/spine2/ceos-config
fi
# Creating a bare startup configuration for spine2
echo "xxxx" > /home/luke/rLab-eos/configs/L2/spine2/token
echo "
service routing protocols model multi-agent
!
schedule tech-support interval 60 timeout 30 max-log-files 5 command show tech-support
!
hostname l2spine2
!
    
aaa authentication login default local
aaa authentication login console local
aaa authorization exec default local
aaa authorization commands all default local
!
no aaa root
!
username arista privilege 15 role network-admin secret sha512 \$6\$BSMT1WbtoeKM/hK4\$kJxcK/KXv4shkWUb9y5MOgNG6EUmmHR5fR4BM2e4uKtXB74lXL1fncHNC0d4xUcW86OJeYapbFZtBdjStkEqv.
!    
    
vrf instance MGMT
interface Management0
   description Management
   vrf MGMT
   ip address 192.168.50.22/24
!
ip routing
!
ip route vrf MGMT 0.0.0.0/0 192.168.50.1
!
management api http-commands
   no shutdown
   vrf MGMT
      no shutdown
!
    
daemon TerminAttr
   exec /usr/bin/TerminAttr -disableaaa -cvaddr=192.168.49.12:9910 -cvvrf=MGMT -taillogs -cvcompression=gzip -cvauth=token,/mnt/flash/token -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -ingestexclude=/Sysdb/cell/1/agent,/Sysdb/cell/2/agent
   no shutdown
!
    " > /home/luke/rLab-eos/configs/L2/spine2/startup-config
echo "Gathering patch cables for spine2"
# Getting spine2 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2spine2-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2spine2pid=$(sudo podman inspect --format '{{.State.Pid}}' l2spine2-net)
sudo ln -sf /proc/${l2spine2pid}/ns/net /var/run/netns/l2ed8f
# Connecting cEOS containers together
echo "Plugged patch cable into spine2 port et1"
sudo ip link set l2ed8fet1 netns l2ed8f name et1 up
echo "Plugged patch cable into spine2 port et2"
sudo ip link set l2ed8fet2 netns l2ed8f name et2 up
echo "Plugged patch cable into spine2 port et3"
sudo ip link set l2ed8fet3 netns l2ed8f name et3 up
echo "Plugged patch cable into spine2 port et4"
sudo ip link set l2ed8fet4 netns l2ed8f name et4 up
sudo ip link add l2ed8f-eth0 type veth peer name l2ed8f-mgmt
sudo ip link set l2ed8f-eth0 netns l2ed8f name eth0 up
sudo ip netns exec l2ed8f ip link set dev eth0 down
sudo ip netns exec l2ed8f ip link set dev eth0 address 00:1c:73:59:43:4f
sudo ip netns exec l2ed8f ip link set dev eth0 up
sudo ip link set l2ed8f-mgmt up
sleep 1
sudo brctl addif vmgmt l2ed8f-mgmt
echo "Powering on spine2"
sudo podman run -d --name=l2spine2 --log-opt max-size=1m --net=container:l2spine2-net --privileged -v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro -v /home/luke/rLab-eos/configs/L2/spine2:/mnt/flash:Z -e INTFTYPE=et -e MGMT_INTF=eth0 -e ETBA=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -i -t ceosimage-64:4.28.0F /sbin/init systemd.setenv=INTFTYPE=et systemd.setenv=MGMT_INTF=eth0 systemd.setenv=ETBA=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker 1> /dev/null 2> /dev/null
echo "Racking and Stacking leaf1"
# Checking for configs directory for each cEOS node
if ! [ -d "/home/luke/rLab-eos/configs/L2/leaf1" ]; then mkdir /home/luke/rLab-eos/configs/L2/leaf1; fi
if ! [ -f "/home/luke/rLab-eos/configs/L2/leaf1/ceos-config" ]; then # Creating the ceos-config file.
echo "SERIALNUMBER=l2leaf1" > /home/luke/rLab-eos/configs/L2/leaf1/ceos-config
echo "SYSTEMMACADDR=00:1c:73:b2:c6:01" >> /home/luke/rLab-eos/configs/L2/leaf1/ceos-config
fi
# Creating a bare startup configuration for leaf1
echo "xxxx" > /home/luke/rLab-eos/configs/L2/leaf1/token
echo "
service routing protocols model multi-agent
!
schedule tech-support interval 60 timeout 30 max-log-files 5 command show tech-support
!
hostname l2leaf1
!
    
aaa authentication login default local
aaa authentication login console local
aaa authorization exec default local
aaa authorization commands all default local
!
no aaa root
!
username arista privilege 15 role network-admin secret sha512 \$6\$BSMT1WbtoeKM/hK4\$kJxcK/KXv4shkWUb9y5MOgNG6EUmmHR5fR4BM2e4uKtXB74lXL1fncHNC0d4xUcW86OJeYapbFZtBdjStkEqv.
!    
    
vrf instance MGMT
interface Management0
   description Management
   vrf MGMT
   ip address 192.168.50.23/24
!
ip routing
!
ip route vrf MGMT 0.0.0.0/0 192.168.50.1
!
management api http-commands
   no shutdown
   vrf MGMT
      no shutdown
!
    
daemon TerminAttr
   exec /usr/bin/TerminAttr -disableaaa -cvaddr=192.168.49.12:9910 -cvvrf=MGMT -taillogs -cvcompression=gzip -cvauth=token,/mnt/flash/token -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -ingestexclude=/Sysdb/cell/1/agent,/Sysdb/cell/2/agent
   no shutdown
!
    " > /home/luke/rLab-eos/configs/L2/leaf1/startup-config
echo "Gathering patch cables for leaf1"
# Getting leaf1 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2leaf1-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2leaf1pid=$(sudo podman inspect --format '{{.State.Pid}}' l2leaf1-net)
sudo ln -sf /proc/${l2leaf1pid}/ns/net /var/run/netns/l2404c
# Connecting cEOS containers together
echo "Plugged patch cable into leaf1 port et1"
sudo ip link set l2404cet1 netns l2404c name et1 up
echo "Plugged patch cable into leaf1 port et2"
sudo ip link set l2404cet2 netns l2404c name et2 up
echo "Plugged patch cable into leaf1 port et3"
sudo ip link set l2404cet3 netns l2404c name et3 up
echo "Plugged patch cable into leaf1 port et4"
sudo ip link set l2404cet4 netns l2404c name et4 up
sudo ip link add l2404c-eth0 type veth peer name l2404c-mgmt
sudo ip link set l2404c-eth0 netns l2404c name eth0 up
sudo ip netns exec l2404c ip link set dev eth0 down
sudo ip netns exec l2404c ip link set dev eth0 address 00:1c:73:50:e3:f2
sudo ip netns exec l2404c ip link set dev eth0 up
sudo ip link set l2404c-mgmt up
sleep 1
sudo brctl addif vmgmt l2404c-mgmt
echo "Powering on leaf1"
sudo podman run -d --name=l2leaf1 --log-opt max-size=1m --net=container:l2leaf1-net --privileged -v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro -v /home/luke/rLab-eos/configs/L2/leaf1:/mnt/flash:Z -e INTFTYPE=et -e MGMT_INTF=eth0 -e ETBA=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -i -t ceosimage-64:4.28.0F /sbin/init systemd.setenv=INTFTYPE=et systemd.setenv=MGMT_INTF=eth0 systemd.setenv=ETBA=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker 1> /dev/null 2> /dev/null
echo "Racking and Stacking leaf2"
# Checking for configs directory for each cEOS node
if ! [ -d "/home/luke/rLab-eos/configs/L2/leaf2" ]; then mkdir /home/luke/rLab-eos/configs/L2/leaf2; fi
if ! [ -f "/home/luke/rLab-eos/configs/L2/leaf2/ceos-config" ]; then # Creating the ceos-config file.
echo "SERIALNUMBER=l2leaf2" > /home/luke/rLab-eos/configs/L2/leaf2/ceos-config
echo "SYSTEMMACADDR=00:1c:73:b3:c6:01" >> /home/luke/rLab-eos/configs/L2/leaf2/ceos-config
fi
# Creating a bare startup configuration for leaf2
echo "xxxx" > /home/luke/rLab-eos/configs/L2/leaf2/token
echo "
service routing protocols model multi-agent
!
schedule tech-support interval 60 timeout 30 max-log-files 5 command show tech-support
!
hostname l2leaf2
!
    
aaa authentication login default local
aaa authentication login console local
aaa authorization exec default local
aaa authorization commands all default local
!
no aaa root
!
username arista privilege 15 role network-admin secret sha512 \$6\$BSMT1WbtoeKM/hK4\$kJxcK/KXv4shkWUb9y5MOgNG6EUmmHR5fR4BM2e4uKtXB74lXL1fncHNC0d4xUcW86OJeYapbFZtBdjStkEqv.
!    
    
vrf instance MGMT
interface Management0
   description Management
   vrf MGMT
   ip address 192.168.50.24/24
!
ip routing
!
ip route vrf MGMT 0.0.0.0/0 192.168.50.1
!
management api http-commands
   no shutdown
   vrf MGMT
      no shutdown
!
    
daemon TerminAttr
   exec /usr/bin/TerminAttr -disableaaa -cvaddr=192.168.49.12:9910 -cvvrf=MGMT -taillogs -cvcompression=gzip -cvauth=token,/mnt/flash/token -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -ingestexclude=/Sysdb/cell/1/agent,/Sysdb/cell/2/agent
   no shutdown
!
    " > /home/luke/rLab-eos/configs/L2/leaf2/startup-config
echo "Gathering patch cables for leaf2"
# Getting leaf2 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2leaf2-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2leaf2pid=$(sudo podman inspect --format '{{.State.Pid}}' l2leaf2-net)
sudo ln -sf /proc/${l2leaf2pid}/ns/net /var/run/netns/l24533
# Connecting cEOS containers together
echo "Plugged patch cable into leaf2 port et1"
sudo ip link set l24533et1 netns l24533 name et1 up
echo "Plugged patch cable into leaf2 port et2"
sudo ip link set l24533et2 netns l24533 name et2 up
echo "Plugged patch cable into leaf2 port et3"
sudo ip link set l24533et3 netns l24533 name et3 up
echo "Plugged patch cable into leaf2 port et4"
sudo ip link set l24533et4 netns l24533 name et4 up
sudo ip link add l24533-eth0 type veth peer name l24533-mgmt
sudo ip link set l24533-eth0 netns l24533 name eth0 up
sudo ip netns exec l24533 ip link set dev eth0 down
sudo ip netns exec l24533 ip link set dev eth0 address 00:1c:73:ef:aa:94
sudo ip netns exec l24533 ip link set dev eth0 up
sudo ip link set l24533-mgmt up
sleep 1
sudo brctl addif vmgmt l24533-mgmt
echo "Powering on leaf2"
sudo podman run -d --name=l2leaf2 --log-opt max-size=1m --net=container:l2leaf2-net --privileged -v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro -v /home/luke/rLab-eos/configs/L2/leaf2:/mnt/flash:Z -e INTFTYPE=et -e MGMT_INTF=eth0 -e ETBA=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -i -t ceosimage-64:4.28.0F /sbin/init systemd.setenv=INTFTYPE=et systemd.setenv=MGMT_INTF=eth0 systemd.setenv=ETBA=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker 1> /dev/null 2> /dev/null
echo "Racking and Stacking leaf3"
# Checking for configs directory for each cEOS node
if ! [ -d "/home/luke/rLab-eos/configs/L2/leaf3" ]; then mkdir /home/luke/rLab-eos/configs/L2/leaf3; fi
if ! [ -f "/home/luke/rLab-eos/configs/L2/leaf3/ceos-config" ]; then # Creating the ceos-config file.
echo "SERIALNUMBER=l2leaf3" > /home/luke/rLab-eos/configs/L2/leaf3/ceos-config
echo "SYSTEMMACADDR=00:1c:73:b4:c6:01" >> /home/luke/rLab-eos/configs/L2/leaf3/ceos-config
fi
# Creating a bare startup configuration for leaf3
echo "xxxx" > /home/luke/rLab-eos/configs/L2/leaf3/token
echo "
service routing protocols model multi-agent
!
schedule tech-support interval 60 timeout 30 max-log-files 5 command show tech-support
!
hostname l2leaf3
!
    
aaa authentication login default local
aaa authentication login console local
aaa authorization exec default local
aaa authorization commands all default local
!
no aaa root
!
username arista privilege 15 role network-admin secret sha512 \$6\$BSMT1WbtoeKM/hK4\$kJxcK/KXv4shkWUb9y5MOgNG6EUmmHR5fR4BM2e4uKtXB74lXL1fncHNC0d4xUcW86OJeYapbFZtBdjStkEqv.
!    
    
vrf instance MGMT
interface Management0
   description Management
   vrf MGMT
   ip address 192.168.50.25/24
!
ip routing
!
ip route vrf MGMT 0.0.0.0/0 192.168.50.1
!
management api http-commands
   no shutdown
   vrf MGMT
      no shutdown
!
    
daemon TerminAttr
   exec /usr/bin/TerminAttr -disableaaa -cvaddr=192.168.49.12:9910 -cvvrf=MGMT -taillogs -cvcompression=gzip -cvauth=token,/mnt/flash/token -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -ingestexclude=/Sysdb/cell/1/agent,/Sysdb/cell/2/agent
   no shutdown
!
    " > /home/luke/rLab-eos/configs/L2/leaf3/startup-config
echo "Gathering patch cables for leaf3"
# Getting leaf3 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2leaf3-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2leaf3pid=$(sudo podman inspect --format '{{.State.Pid}}' l2leaf3-net)
sudo ln -sf /proc/${l2leaf3pid}/ns/net /var/run/netns/l29ad8
# Connecting cEOS containers together
echo "Plugged patch cable into leaf3 port et1"
sudo ip link set l29ad8et1 netns l29ad8 name et1 up
echo "Plugged patch cable into leaf3 port et2"
sudo ip link set l29ad8et2 netns l29ad8 name et2 up
echo "Plugged patch cable into leaf3 port et3"
sudo ip link set l29ad8et3 netns l29ad8 name et3 up
echo "Plugged patch cable into leaf3 port et4"
sudo ip link set l29ad8et4 netns l29ad8 name et4 up
sudo ip link add l29ad8-eth0 type veth peer name l29ad8-mgmt
sudo ip link set l29ad8-eth0 netns l29ad8 name eth0 up
sudo ip netns exec l29ad8 ip link set dev eth0 down
sudo ip netns exec l29ad8 ip link set dev eth0 address 00:1c:73:39:df:89
sudo ip netns exec l29ad8 ip link set dev eth0 up
sudo ip link set l29ad8-mgmt up
sleep 1
sudo brctl addif vmgmt l29ad8-mgmt
echo "Powering on leaf3"
sudo podman run -d --name=l2leaf3 --log-opt max-size=1m --net=container:l2leaf3-net --privileged -v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro -v /home/luke/rLab-eos/configs/L2/leaf3:/mnt/flash:Z -e INTFTYPE=et -e MGMT_INTF=eth0 -e ETBA=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -i -t ceosimage-64:4.28.0F /sbin/init systemd.setenv=INTFTYPE=et systemd.setenv=MGMT_INTF=eth0 systemd.setenv=ETBA=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker 1> /dev/null 2> /dev/null
echo "Waiting on the server team to get their servers up and running..."
# Getting host10 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2host10-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2host10pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host10-net)
sudo ln -sf /proc/${l2host10pid}/ns/net /var/run/netns/l28112
# Connecting host containers together
echo "Plugged patch cable into host10 port et0"
sudo ip link set l28112et0 netns l28112 name et0 up
echo "Powering on host10"
sleep 1
sudo podman run -d --name=l2host10 --privileged --log-opt max-size=1m --net=container:l2host10-net -e HOSTNAME=l2host10 -e HOST_IP=10.0.12.11 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.12.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
# Getting host11 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2host11-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2host11pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host11-net)
sudo ln -sf /proc/${l2host11pid}/ns/net /var/run/netns/l28083
# Connecting host containers together
echo "Plugged patch cable into host11 port et0"
sudo ip link set l28083et0 netns l28083 name et0 up
echo "Powering on host11"
sleep 1
sudo podman run -d --name=l2host11 --privileged --log-opt max-size=1m --net=container:l2host11-net -e HOSTNAME=l2host11 -e HOST_IP=10.0.13.11 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.13.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
# Getting host20 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2host20-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2host20pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host20-net)
sudo ln -sf /proc/${l2host20pid}/ns/net /var/run/netns/l218f3
# Connecting host containers together
echo "Plugged patch cable into host20 port et0"
sudo ip link set l218f3et0 netns l218f3 name et0 up
echo "Powering on host20"
sleep 1
sudo podman run -d --name=l2host20 --privileged --log-opt max-size=1m --net=container:l2host20-net -e HOSTNAME=l2host20 -e HOST_IP=10.0.12.21 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.12.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
# Getting host21 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2host21-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2host21pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host21-net)
sudo ln -sf /proc/${l2host21pid}/ns/net /var/run/netns/l23005
# Connecting host containers together
echo "Plugged patch cable into host21 port et0"
sudo ip link set l23005et0 netns l23005 name et0 up
echo "Powering on host21"
sleep 1
sudo podman run -d --name=l2host21 --privileged --log-opt max-size=1m --net=container:l2host21-net -e HOSTNAME=l2host21 -e HOST_IP=10.0.13.21 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.13.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
# Getting host30 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2host30-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2host30pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host30-net)
sudo ln -sf /proc/${l2host30pid}/ns/net /var/run/netns/l2a963
# Connecting host containers together
echo "Plugged patch cable into host30 port et0"
sudo ip link set l2a963et0 netns l2a963 name et0 up
echo "Powering on host30"
sleep 1
sudo podman run -d --name=l2host30 --privileged --log-opt max-size=1m --net=container:l2host30-net -e HOSTNAME=l2host30 -e HOST_IP=10.0.12.31 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.12.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
# Getting host31 nodes plumbing
sudo podman run -d --restart=always --log-opt max-size=10k --name=l2host31-net --net=none busybox /bin/init 1> /dev/null 2> /dev/null
l2host31pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host31-net)
sudo ln -sf /proc/${l2host31pid}/ns/net /var/run/netns/l23ef7
# Connecting host containers together
echo "Plugged patch cable into host31 port et0"
sudo ip link set l23ef7et0 netns l23ef7 name et0 up
echo "Powering on host31"
sleep 1
sudo podman run -d --name=l2host31 --privileged --log-opt max-size=1m --net=container:l2host31-net -e HOSTNAME=l2host31 -e HOST_IP=10.0.13.31 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.13.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
sudo podman exec -d l2host10 iperf3 -s -p 5010 1> /dev/null 2> /dev/null
sudo podman exec -d l2host30 iperf3 -s -p 5010 1> /dev/null 2> /dev/null
sudo podman exec -d l2host31 iperf3 -s -p 5010 1> /dev/null 2> /dev/null
sudo podman exec -d l2host11 iperf3client 10.0.12.31 5010 1000000 1> /dev/null 2> /dev/null
sudo podman exec -d l2host20 iperf3client 10.0.12.11 5010 1000000 1> /dev/null 2> /dev/null
sudo podman exec -d l2host21 iperf3client 10.0.13.31 5010 1000000 1> /dev/null 2> /dev/null

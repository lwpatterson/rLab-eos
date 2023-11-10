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
sudo ip netns add L2 1> /dev/null 2> /dev/null
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
sudo podman start l2spine1-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2spine1 1> /dev/null 2> /dev/null
sudo podman rm l2spine1 1> /dev/null 2> /dev/null
l2spine1pid=$(sudo podman inspect --format '{{.State.Pid}}' l2spine1-net)
sudo ln -sf /proc/${l2spine1pid}/ns/net /var/run/netns/l2eb58
sudo ip link set l2eb58et1 netns l2eb58 name et1 up
sudo ip link set l2eb58et2 netns l2eb58 name et2 up
sudo ip link set l2eb58et3 netns l2eb58 name et3 up
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
sudo podman start l2spine2-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2spine2 1> /dev/null 2> /dev/null
sudo podman rm l2spine2 1> /dev/null 2> /dev/null
l2spine2pid=$(sudo podman inspect --format '{{.State.Pid}}' l2spine2-net)
sudo ln -sf /proc/${l2spine2pid}/ns/net /var/run/netns/l2ed8f
sudo ip link set l2ed8fet1 netns l2ed8f name et1 up
sudo ip link set l2ed8fet2 netns l2ed8f name et2 up
sudo ip link set l2ed8fet3 netns l2ed8f name et3 up
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
sudo podman start l2leaf1-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2leaf1 1> /dev/null 2> /dev/null
sudo podman rm l2leaf1 1> /dev/null 2> /dev/null
l2leaf1pid=$(sudo podman inspect --format '{{.State.Pid}}' l2leaf1-net)
sudo ln -sf /proc/${l2leaf1pid}/ns/net /var/run/netns/l2404c
sudo ip link set l2404cet1 netns l2404c name et1 up
sudo ip link set l2404cet2 netns l2404c name et2 up
sudo ip link set l2404cet3 netns l2404c name et3 up
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
sudo podman start l2leaf2-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2leaf2 1> /dev/null 2> /dev/null
sudo podman rm l2leaf2 1> /dev/null 2> /dev/null
l2leaf2pid=$(sudo podman inspect --format '{{.State.Pid}}' l2leaf2-net)
sudo ln -sf /proc/${l2leaf2pid}/ns/net /var/run/netns/l24533
sudo ip link set l24533et1 netns l24533 name et1 up
sudo ip link set l24533et2 netns l24533 name et2 up
sudo ip link set l24533et3 netns l24533 name et3 up
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
sudo podman start l2leaf3-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2leaf3 1> /dev/null 2> /dev/null
sudo podman rm l2leaf3 1> /dev/null 2> /dev/null
l2leaf3pid=$(sudo podman inspect --format '{{.State.Pid}}' l2leaf3-net)
sudo ln -sf /proc/${l2leaf3pid}/ns/net /var/run/netns/l29ad8
sudo ip link set l29ad8et1 netns l29ad8 name et1 up
sudo ip link set l29ad8et2 netns l29ad8 name et2 up
sudo ip link set l29ad8et3 netns l29ad8 name et3 up
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
sudo podman start l2host10-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host10 1> /dev/null 2> /dev/null
sudo podman rm l2host10 1> /dev/null 2> /dev/null
l2host10pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host10-net) 1> /dev/null 2> /dev/null
sudo ln -sf /proc/${l2host10pid}/ns/net /var/run/netns/l28112 1> /dev/null 2> /dev/null
sudo ip link set l28112et0 netns l28112 name et0 up
echo "Powering on host10"
sleep 1
sudo podman run -d --name=l2host10 --privileged --log-opt max-size=1m --net=container:l2host10-net -e HOSTNAME=l2host10 -e HOST_IP=10.0.12.11 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.12.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
sudo podman start l2host11-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host11 1> /dev/null 2> /dev/null
sudo podman rm l2host11 1> /dev/null 2> /dev/null
l2host11pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host11-net) 1> /dev/null 2> /dev/null
sudo ln -sf /proc/${l2host11pid}/ns/net /var/run/netns/l28083 1> /dev/null 2> /dev/null
sudo ip link set l28083et0 netns l28083 name et0 up
echo "Powering on host11"
sleep 1
sudo podman run -d --name=l2host11 --privileged --log-opt max-size=1m --net=container:l2host11-net -e HOSTNAME=l2host11 -e HOST_IP=10.0.13.11 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.13.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
sudo podman start l2host20-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host20 1> /dev/null 2> /dev/null
sudo podman rm l2host20 1> /dev/null 2> /dev/null
l2host20pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host20-net) 1> /dev/null 2> /dev/null
sudo ln -sf /proc/${l2host20pid}/ns/net /var/run/netns/l218f3 1> /dev/null 2> /dev/null
sudo ip link set l218f3et0 netns l218f3 name et0 up
echo "Powering on host20"
sleep 1
sudo podman run -d --name=l2host20 --privileged --log-opt max-size=1m --net=container:l2host20-net -e HOSTNAME=l2host20 -e HOST_IP=10.0.12.21 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.12.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
sudo podman start l2host21-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host21 1> /dev/null 2> /dev/null
sudo podman rm l2host21 1> /dev/null 2> /dev/null
l2host21pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host21-net) 1> /dev/null 2> /dev/null
sudo ln -sf /proc/${l2host21pid}/ns/net /var/run/netns/l23005 1> /dev/null 2> /dev/null
sudo ip link set l23005et0 netns l23005 name et0 up
echo "Powering on host21"
sleep 1
sudo podman run -d --name=l2host21 --privileged --log-opt max-size=1m --net=container:l2host21-net -e HOSTNAME=l2host21 -e HOST_IP=10.0.13.21 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.13.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
sudo podman start l2host30-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host30 1> /dev/null 2> /dev/null
sudo podman rm l2host30 1> /dev/null 2> /dev/null
l2host30pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host30-net) 1> /dev/null 2> /dev/null
sudo ln -sf /proc/${l2host30pid}/ns/net /var/run/netns/l2a963 1> /dev/null 2> /dev/null
sudo ip link set l2a963et0 netns l2a963 name et0 up
echo "Powering on host30"
sleep 1
sudo podman run -d --name=l2host30 --privileged --log-opt max-size=1m --net=container:l2host30-net -e HOSTNAME=l2host30 -e HOST_IP=10.0.12.31 -e HOST_MASK=255.255.255.0 -e HOST_GW=10.0.12.1 chost:1.0 ipnet 1> /dev/null 2> /dev/null
sudo podman start l2host31-net 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host31 1> /dev/null 2> /dev/null
sudo podman rm l2host31 1> /dev/null 2> /dev/null
l2host31pid=$(sudo podman inspect --format '{{.State.Pid}}' l2host31-net) 1> /dev/null 2> /dev/null
sudo ln -sf /proc/${l2host31pid}/ns/net /var/run/netns/l23ef7 1> /dev/null 2> /dev/null
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

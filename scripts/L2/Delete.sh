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
echo "Pulling power and removing patch cables from spine1"
sudo podman stop -t 0 l2spine1 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2spine1-net 1> /dev/null 2> /dev/null
sudo podman rm l2spine1 1> /dev/null 2> /dev/null
sudo podman rm l2spine1-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from spine2"
sudo podman stop -t 0 l2spine2 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2spine2-net 1> /dev/null 2> /dev/null
sudo podman rm l2spine2 1> /dev/null 2> /dev/null
sudo podman rm l2spine2-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from leaf1"
sudo podman stop -t 0 l2leaf1 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2leaf1-net 1> /dev/null 2> /dev/null
sudo podman rm l2leaf1 1> /dev/null 2> /dev/null
sudo podman rm l2leaf1-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from leaf2"
sudo podman stop -t 0 l2leaf2 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2leaf2-net 1> /dev/null 2> /dev/null
sudo podman rm l2leaf2 1> /dev/null 2> /dev/null
sudo podman rm l2leaf2-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from leaf3"
sudo podman stop -t 0 l2leaf3 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2leaf3-net 1> /dev/null 2> /dev/null
sudo podman rm l2leaf3 1> /dev/null 2> /dev/null
sudo podman rm l2leaf3-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from host10"
sudo podman stop -t 0 l2host10 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host10-net 1> /dev/null 2> /dev/null
sudo podman rm l2host10 1> /dev/null 2> /dev/null
sudo podman rm l2host10-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from host11"
sudo podman stop -t 0 l2host11 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host11-net 1> /dev/null 2> /dev/null
sudo podman rm l2host11 1> /dev/null 2> /dev/null
sudo podman rm l2host11-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from host20"
sudo podman stop -t 0 l2host20 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host20-net 1> /dev/null 2> /dev/null
sudo podman rm l2host20 1> /dev/null 2> /dev/null
sudo podman rm l2host20-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from host21"
sudo podman stop -t 0 l2host21 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host21-net 1> /dev/null 2> /dev/null
sudo podman rm l2host21 1> /dev/null 2> /dev/null
sudo podman rm l2host21-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from host30"
sudo podman stop -t 0 l2host30 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host30-net 1> /dev/null 2> /dev/null
sudo podman rm l2host30 1> /dev/null 2> /dev/null
sudo podman rm l2host30-net 1> /dev/null 2> /dev/null
echo "Pulling power and removing patch cables from host31"
sudo podman stop -t 0 l2host31 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host31-net 1> /dev/null 2> /dev/null
sudo podman rm l2host31 1> /dev/null 2> /dev/null
sudo podman rm l2host31-net 1> /dev/null 2> /dev/null
sudo ip netns delete L2 1> /dev/null 2> /dev/null
sudo rm -rf /var/run/netns/l2eb58
sudo rm -rf /var/run/netns/l2ed8f
sudo rm -rf /var/run/netns/l2404c
sudo rm -rf /var/run/netns/l24533
sudo rm -rf /var/run/netns/l29ad8
sudo rm -rf /var/run/netns/l28112
sudo rm -rf /var/run/netns/l28083
sudo rm -rf /var/run/netns/l218f3
sudo rm -rf /var/run/netns/l23005
sudo rm -rf /var/run/netns/l2a963
sudo rm -rf /var/run/netns/l23ef7

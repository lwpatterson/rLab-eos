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
echo "Pulling power from spine1"
sudo podman stop -t 0 l2spine1 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2spine1-net 1> /dev/null 2> /dev/null
echo "Pulling power from spine2"
sudo podman stop -t 0 l2spine2 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2spine2-net 1> /dev/null 2> /dev/null
echo "Pulling power from leaf1"
sudo podman stop -t 0 l2leaf1 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2leaf1-net 1> /dev/null 2> /dev/null
echo "Pulling power from leaf2"
sudo podman stop -t 0 l2leaf2 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2leaf2-net 1> /dev/null 2> /dev/null
echo "Pulling power from leaf3"
sudo podman stop -t 0 l2leaf3 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2leaf3-net 1> /dev/null 2> /dev/null
echo "Pulling power from host10"
sudo podman stop -t 0 l2host10 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host10-net 1> /dev/null 2> /dev/null
echo "Pulling power from host11"
sudo podman stop -t 0 l2host11 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host11-net 1> /dev/null 2> /dev/null
echo "Pulling power from host20"
sudo podman stop -t 0 l2host20 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host20-net 1> /dev/null 2> /dev/null
echo "Pulling power from host21"
sudo podman stop -t 0 l2host21 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host21-net 1> /dev/null 2> /dev/null
echo "Pulling power from host30"
sudo podman stop -t 0 l2host30 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host30-net 1> /dev/null 2> /dev/null
echo "Pulling power from host31"
sudo podman stop -t 0 l2host31 1> /dev/null 2> /dev/null
sudo podman stop -t 0 l2host31-net 1> /dev/null 2> /dev/null

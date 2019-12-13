#!/usr/bin/env python

import argparse
from ruamel.yaml import YAML
from os import getcwd, mkdir, makedirs
from os.path import isdir

BASE_PATH = getcwd()
CONFIGS = BASE_PATH + "/configs"

OVS_BRIDGES = []
NODES = {}
HOSTS = {}
CMDS_CREATE = []
CMDS_START = []
CMDS_STOP = []
CMDS_DESTROY = []
CMDS = {}

def openTopo(topo):
    try:
        tmp_topo = open(BASE_PATH + "/topologies/{}.yaml".format(topo), 'r')
        tmp_yaml = YAML().load(tmp_topo)
        tmp_topo.close()
        return(tmp_yaml)
    except:
        return(False)

def checkBridge(dev1, dev2, _tag):
    global OVS_BRIDGES
    _addBr = True
    name_len = len(dev1 + dev2 + _tag)
    for _br in OVS_BRIDGES:
        if dev1 in _br and dev2 in _br and len(_br) == name_len:
            _addBr = False
            return({'status': _addBr, 'name': _br})
    return({'status': _addBr, 'name':''})

def checkBridgeNameLength(brName):
    """
    Function to check if length of bridge name is over
    characters.
    """
    if len(brName) <= 15:
        return(True)
    else:
        return(False)


def main(args):
    global OVS_BRIDGES, NODES
    topo_yaml = openTopo(args.type)
    ceos_img = topo_yaml['images']['ceos']
    host_img = topo_yaml['images']['host']
    if topo_yaml:
        _tag = topo_yaml['topology']['name']
        for _node in topo_yaml['nodes']:
            intf = 0
            NODES[_node] = {
                "intfs": {},
                "name": _tag.lower() + _node
            }
            for _peer in topo_yaml['nodes'][_node]['links']:
                intf += 1
                _brCheck = checkBridge(_node, _peer, _tag)
                if _brCheck['status']:
                    _brName = _tag.lower() + _node + _peer
                    if not checkBridgeNameLength(_brName):
                        print("Alert! Bridge name {0} is longer than the allowed 15 characters.\nThere maybe ovs build errors.".format(_brName))
                    OVS_BRIDGES.append(_brName)
                    NODES[_node]['intfs']['eth{}'.format(intf)] = _brName
                else:
                    NODES[_node]['intfs']['eth{}'.format(intf)] = _brCheck['name']
        # Section to parse hosts
        if topo_yaml['hosts']:
            for _host in topo_yaml['hosts']:
                intf = 0
                HOSTS[_host] = {
                    'intfs': {},
                    'name': _tag.lower() + _host
                }
                for _peer in topo_yaml['hosts'][_host]['links']:
                    _brCheck = checkBridge(_host, _peer, _tag)
                    HOSTS[_host]['intfs']['eth{}'.format(intf)] = _brCheck['name']
                    intf += 1
            
    # Create commands to create Open vSwitch bridges
    for _br in OVS_BRIDGES:
        CMDS_CREATE.append("sudo ovs-vsctl add-br {}".format(_br))
        CMDS_CREATE.append("sudo ovs-vsctl set bridge {} other-config:forward-bpdu=true".format(_br))
    
    # Create commands to create cEOS containers:
    for _node in NODES:
        _name = NODES[_node]['name']
        CMDS_CREATE.append("docker create --name={0} --net=none --privileged -v $(pwd)/configs/{1}/{2}/:/mnt/flash:Z -e INTFTYPE=et -e MGMT_INTF=et0 -e ETBA=1 -e SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 -e CEOS=1 -e EOS_PLATFORM=ceoslab -e container=docker -i -t ceosimage:{3} /sbin/init systemd.setenv=INTFTYPE=et systemd.setenv=MGMT_INTF=et0 systemd.setenv=ETBA=1 systemd.setenv=SKIP_ZEROTOUCH_BARRIER_IN_SYSDBINIT=1 systemd.setenv=CEOS=1 systemd.setenv=EOS_PLATFORM=ceoslab systemd.setenv=container=docker".format( _name, topo_yaml['topology']['name'], _node, ceos_img))
        CMDS_CREATE.append("docker start {}".format(_name))
        CMDS_START.append("docker start {}".format(_name))
        for eindex in range(1, len(NODES[_node]['intfs']) + 1):
            CMDS_CREATE.append("sudo ovs-docker add-port {0} et{1} {2} --macaddress={3}".format(NODES[_node]['intfs']['eth{}'.format(eindex)], eindex, _name, topo_yaml['nodes'][_node]['mac']))
            CMDS_START.append("sudo ovs-docker add-port {0} et{1} {2} --macaddress={3}".format(NODES[_node]['intfs']['eth{}'.format(eindex)], eindex, _name, topo_yaml['nodes'][_node]['mac']))
            CMDS_DESTROY.append("sudo ovs-docker del-port {0} et{1} {2}".format(NODES[_node]['intfs']['eth{}'.format(eindex)], eindex, _name))
            CMDS_STOP.append("sudo ovs-docker del-port {0} et{1} {2}".format(NODES[_node]['intfs']['eth{}'.format(eindex)], eindex, _name))
        CMDS_DESTROY.append("docker stop {}".format(_name))
        CMDS_STOP.append("docker stop {}".format(_name))
        CMDS_DESTROY.append("docker rm {}".format(_name))
        # Create a system_mac_address file in /mnt/flash
        ceos_flash = CONFIGS + "/{0}/{1}".format(_tag, _node)
        if not isdir(ceos_flash):
            makedirs(ceos_flash)
        with open(ceos_flash + '/system_mac_address', 'w') as cmac:
            cmac.write(topo_yaml['nodes'][_node]['mac'])
    # Create commands to create host containers
    for _host in HOSTS:
        _hname = HOSTS[_host]['name']
        CMDS_CREATE.append("docker create --name={0} --hostname={0} --net=none chost:{1}".format(_hname, host_img))
        CMDS_CREATE.append("docker start {}".format(_hname))
        CMDS_START.append("docker start {}".format(_hname))
        for eindex in range(0, len(HOSTS[_host]['intfs'])):
            CMDS_CREATE.append("sudo ovs-docker add-port {0} eth{1} {2} --ipaddress={3}/{4} --gateway={5}".format(HOSTS[_host]['intfs']['eth{}'.format(eindex)], eindex, _hname, topo_yaml['hosts'][_host]['ipaddress'], topo_yaml['hosts'][_host]['mask'], topo_yaml['hosts'][_host]['gateway']))
            CMDS_DESTROY.append("sudo ovs-docker del-port {0} eth{1} {2} --ipaddress={3}/{4} --gateway={5}".format(HOSTS[_host]['intfs']['eth{}'.format(eindex)], eindex, _hname, topo_yaml['hosts'][_host]['ipaddress'], topo_yaml['hosts'][_host]['mask'], topo_yaml['hosts'][_host]['gateway']))
            CMDS_START.append("sudo ovs-docker add-port {0} eth{1} {2} --ipaddress={3}/{4} --gateway={5}".format(HOSTS[_host]['intfs']['eth{}'.format(eindex)], eindex, _hname, topo_yaml['hosts'][_host]['ipaddress'], topo_yaml['hosts'][_host]['mask'], topo_yaml['hosts'][_host]['gateway']))
            CMDS_STOP.append("sudo ovs-docker del-port {0} eth{1} {2} --ipaddress={3}/{4} --gateway={5}".format(HOSTS[_host]['intfs']['eth{}'.format(eindex)], eindex, _hname, topo_yaml['hosts'][_host]['ipaddress'], topo_yaml['hosts'][_host]['mask'], topo_yaml['hosts'][_host]['gateway']))
        CMDS_DESTROY.append("docker stop {}".format(_hname))
        CMDS_DESTROY.append("docker rm {}".format(_hname))
        CMDS_STOP.append("docker stop {}".format(_hname))
    
    # Check for iPerf3 configurations
    if topo_yaml['iperf']:
        _iperf = topo_yaml['iperf']
        _port = _iperf['port']
        _brate = _iperf['brate']
        for _server in _iperf['servers']:
            CMDS_CREATE.append("docker exec -d {0} iperf3 -s -p {1}".format(HOSTS[_server]['name'], _port))
            CMDS_START.append("docker exec -d {0} iperf3 -s -p {1}".format(HOSTS[_server]['name'], _port))
        for _client in _iperf['clients']:
            _target = topo_yaml['hosts'][_client['target']]['ipaddress']
            CMDS_CREATE.append("docker exec -d {0} iperf3client {1} {2} {3}".format(HOSTS[_client['client']]['name'], _target, _port, _brate))
            CMDS_START.append("docker exec -d {0} iperf3client {1} {2} {3}".format(HOSTS[_client['client']]['name'], _target, _port, _brate))

    # Check and create topo commands
    if topo_yaml['commands']:
        for _cmd in topo_yaml['commands']:
            CMDS[_cmd] = []
            if topo_yaml['nodes']:
                for _node in topo_yaml['nodes']:
                    _name = NODES[_node]['name']
                    if 'ratd' in _name:
                        CMDS[_cmd].append("docker exec -it {0} Cli -p 15 -c \"configure replace flash:/cfgs/{1}_{2} ignore-errors\" > /dev/null 2>&1".format(_name, topo_yaml['commands'][_cmd]['pre'], _node.upper()))
                    else:
                        CMDS[_cmd].append("docker exec -it {0} Cli -p 15 -c \"configure replace flash:/cfgs/{1}-{2} ignore-errors\" > /dev/null 2>&1".format(_name, topo_yaml['commands'][_cmd]['pre'], _node))
                    if 'reboot' in topo_yaml['commands'][_cmd]:
                        CMDS[_cmd].append("docker exec -it {0} Cli -p 15 -c \"write\" > /dev/null 2>&1".format(_name))
                        CMDS[_cmd].append("docker exec -it {0} bash -c 'pkill -9 Sysdb'".format(_name))
    # Check to see if dest dir is created
    if not isdir(BASE_PATH + "/cnt/{0}".format(_tag)):
        makedirs(BASE_PATH + "/cnt/{0}".format(_tag))
    if CMDS_CREATE:
        with open(BASE_PATH + "/cnt/{0}/Create.sh".format(_tag), 'w') as fout:
            fout.write("#!/bin/bash\n")
            for _cmd in CMDS_CREATE:
                fout.write(_cmd + "\n")
        with open(BASE_PATH + "/cnt/{0}/Destroy.sh".format(_tag), 'w') as fout:
            fout.write("#!/bin/bash\n")
            for _cmd in CMDS_DESTROY:
                fout.write(_cmd + "\n")
            for _br in OVS_BRIDGES:
                fout.write("sudo ovs-vsctl del-br {}\n".format(_br))
        with open(BASE_PATH + "/cnt/{0}/Start.sh".format(_tag), 'w') as fout:
            fout.write("#!/bin/bash\n")
            for _cmd in CMDS_START:
                fout.write(_cmd + "\n")
        with open(BASE_PATH + "/cnt/{0}/Stop.sh".format(_tag), 'w') as fout:
            fout.write("#!/bin/bash\n")
            for _cmd in CMDS_STOP:
                fout.write(_cmd + "\n")
        if CMDS:
            for _cmd in CMDS:
                _tmp = CMDS[_cmd]
                with open(BASE_PATH + "/cnt/{0}/CMD-{1}.sh".format(_tag, _cmd), 'w') as fout:
                    fout.write("#!/bin/bash\n")
                    for _ncmd in _tmp:
                        fout.write(_ncmd + "\n")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--type", type=str, help="Topology to build", default=None, required=True)
    args = parser.parse_args()
    main(args)

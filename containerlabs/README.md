# K3d Cluster with 1-Master, 1 Worker nodes
```
k3d cluster create clab --config k3d-cluster-clab-1M_1W.yaml --k3s-arg '--disable=metrics-server@server:0' --k3s-arg '--disable=servicelb@server:0' --k3s-arg '--disable=traefik@server:0'
```

# K3d cluster with 1-MAster, 3 Worker nodes

```
k3d cluster create --config k3d-cluster-clab-1M_3W.yaml
```

[Containerlab BGP topo](https://gist.github.com/anande/2e2c15215b904a116ff03521d1fb3213)

```
router0# show bgp summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.0.0.0, local AS number 65000 vrf-id 0
BGP table version 8
RIB entries 15, using 2760 bytes of memory
Peers 2, using 1433 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
tor0(net0)      4      65010       226       226        0    0    0 00:10:52            3        9 N/A
tor1(net1)      4      65011       225       225        0    0    0 00:10:51            3        9 N/A

Total number of neighbors 2

docker exec -ti clab-bgp-topo-tor0 bash
bash-5.1# vtysh

Hello, this is FRRouting (version 8.2.2_git).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

tor0# show bgp summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.0.0.1, local AS number 65010 vrf-id 0
BGP table version 9
RIB entries 15, using 2760 bytes of memory
Peers 3, using 2149 KiB of memory
Peer groups 2, using 128 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
router0(net0)   4      65000       212       213        0    0    0 00:10:13            6        9 N/A
10.0.1.2        4          0         0         0        0    0    0    never       Active        0 N/A
10.0.2.2        4          0         0         0        0    0    0    never       Active        0 N/A

Total number of neighbors 3

docker exec -ti clab-bgp-topo-tor1 bash
root@tor1/ vtysh

Hello, this is FRRouting (version 8.2.2_git).
Copyright 1996-2005 Kunihiro Ishiguro, et al.


tor1# show version
FRRouting 8.2.2_git (tor1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.
configured with:
    '--prefix=/usr' '--sbindir=/usr/lib/frr' '--sysconfdir=/etc/frr' '--libdir=/usr/lib' '--localstatedir=/var/run/frr' '--enable-rpki' '--enable-vtysh' '--enable-multipath=64' '--enable-vty-group=frrvty' '--enable-user=frr' '--enable-group=frr' 'CC=gcc' 'CXX=g++'


tor1# show bgp summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.0.0.2, local AS number 65011 vrf-id 0
BGP table version 9
RIB entries 15, using 2760 bytes of memory
Peers 3, using 2149 KiB of memory
Peer groups 2, using 128 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
router0(net0)   4      65000       158       159        0    0    0 00:07:33            6        9 N/A
10.0.3.2        4          0         0         0        0    0    0    never       Active        0 N/A
10.0.4.2        4          0         0         0        0    0    0    never       Active        0 N/A

Total number of neighbors 3
```
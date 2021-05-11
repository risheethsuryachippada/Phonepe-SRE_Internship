># Tasks - Week 10 & 11

```
Topic : Advanced Networking
```
Below is the topology needed for all the tasks for this week.

Topology description:
1. R1, R2, R3, R4: Could be cumulus VX or Ubuntu with Frr ( either is fine )
2. Host 1 , 2,3 : Ubuntu with FRR
3. R1, R2, R3 will form BGP with R4

* Task 1: EVPN / Vxlan

    * Create L2 connectivity between host 1, host 2, host 3
    * Test case: 
    
Node-name | IP address
:--: | :--:
`Host 1 ` | 10.3.1.1/24
`Host 2 ` | 10.3.1.2/24
`Host 3 ` | 10.3.1.3/24

All the hosts should be able to ping each other
(Hint / Tip: Hosts will not form BGP with R1, R2, and R3)

* Task 2: L3 + GRE Tunnel

    * Create L3 connectivity between all 3 Hosts, Each host will form BGP with its corresponding router and advertise its own loopback ip

Node-name | IP address loopback
:--: | :--:
`Host 1 ` | 10.10.1.1/32
`Host 2 ` | 10.10.1.2/32
`Host 3 ` | 10.10.1.3/32

    * Verify the ping between each hosts

        1. Setup a GRE tunnel between Host 1 and Host 3
        2. Set 192.168.100.1/24 on Host 1 tunnel interface
        3. Set 192.168.100.2/24 on Host 3 Tunnel interface
        4. Test the ping between 192.168.100.1 and 100.2

* Task 3: VRF

    * All 3 Hosts will form BGP with its corresponding Routers
    * Host 1 and Host 2 will belong to VRF1
    * Host 3 will belong to VRF 2

    * Test case: ( Hosts within the same vrf will be able to ping each other )
        1. Host 1 will be able to ping the loopback IP of Host 2 and vice versa
        2. Host 3 will not be reachable from host 1 and host 2

        * Move host 2 to VRF 2, and repeat the tests
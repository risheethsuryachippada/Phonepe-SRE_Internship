### Adv Networking Tasks

Task 1-VxLAN / EVPN

1. Cumulus VX Install & Configuration

    * Download & Install Cumulus Vx from [Nvidia Cumulus Vx](https://www.nvidia.com/en-us/networking/ethernet-switching/cumulus-vx/)
    * Import Appliance by clicking on the ova file.
    * Login with username `cumulus` & password `cumulus`

2. Setting up the network interfcaes
    
    * We can create a net interface using
    ```bash
    $ net add interface swp1
    $ net pending
    $ net commit
    ```

    *The VM configuration
    Host | adapter | IP/mask
        :--: | :--: | :--:
        R1 | `swp1` | `10.9.1.2/30`
        R2 | `swp2` | `10.9.1.6/30`
        R3 | `swp3` | `10.9.1.10/30`
        R4 | `swp1`<br>`swp2`<br>`swp3` | `10.9.1.1/30` <br> `10.9.1.5/30`<br>`10.9.1.9/30`

    * Edit the `/etc/network/interfaces` file and it should seem like this
    In `R4`
    ```bash
    auto swp1
    iface swp1
        address 10.9.1.1/30

    auto swp2
    iface swp2
        address 10.9.1.5/30

    auto swp3
    iface swp3
        address 10.9.1.9/30    
    ```
    * Command to make the changes made in `interfaces conf`
    ```bash
    ifreload -a
    ```

3. Setting up the BGP among the R1,R2,R3 with R4

    * We use `NCLU` commands to set it up and it gets saved to the `/etc/frr/frr.conf` file, [Cumulus BGP Setup](https://docs.nvidia.com/networking-ethernet-software/cumulus-linux-41/Layer-3/Border-Gateway-Protocol-BGP/Basic-BGP-Configuration/).

    In `R4`
    ```bash
    $ net add bgp autonomous-system 111
    $ net add bgp neighbor 10.9.1.2 remote-as 11
    $ net add bgp neighbor 10.9.1.6 remote-as 22
    $ net add bgp neighbor 10.9.1.10 remote-as 33
    $ net pending
    $ net commit
    ```

    In `R1`
    ```bash
    $ net add bgp autonomous-system 11
    $ net add bgp neighbor 10.9.1.1 remote-as 111
    $ net add bgp ipv4 unicast network 10.9.1.0/30
    $ net pending
    $ net commit
    ```

    In `R2`
    ```bash
    $ net add bgp autonomous-system 22
    $ net add bgp neighbor 10.9.1.5 remote-as 111
    $ net add bgp ipv4 unicast network 10.9.1.4/30
    $ net pending
    $ net commit
    ```

    In `R3`
    ```bash
    $ net add bgp autonomous-system 33
    $ net add bgp neighbor 10.9.1.9 remote-as 111
    $ net add bgp ipv4 unicast network 10.9.1.8/30
    $ net pending
    $ net commit
    ```
    
    * BGP is set up and can be verified with `ping` and `traceroute`
    
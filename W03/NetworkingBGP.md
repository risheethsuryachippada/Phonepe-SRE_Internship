# Networking-BGP

* We need an Internal network with VMs to establish 2 LANs and communicate among them.

* Configure VM1 and VM3 as end hosts and VM2 as router by making required settings like

* For later versions of Ubuntu, we use `netplan` network configurations to configure all network interfaces and routes we require, for that we need to edit the `/etc/netplan/<yaml file>`, here the yaml file's name is different for different versions of ubuntu using

* The yaml configurations we need to make for each VM are:
    
    VM1:
    static IP: 192.168.10.4
    gateway: 192.168.10.1
    Routes: 
        packets
            * to: 192.168.20.0/24 network
            * through hop: 192.168.10.5
    ```yaml
    network:
        version: 2
        renderer: networkd
        ethernets:
            enp0s8:             #interface with intnet_a internal network
                dhcp4: no
                addresses:
                    - 192.168.10.4/24
                gateway4: 192.168.10.1
                routes:
                    - to: 192.168.20.0/24
                      via: 192.168.10.5
                      metric: 100
    ```
    VM2:
    static IP: 
        enp0s3 
            * adapter : 192.168.10.5
            * gateway : 192.168.10.1
        enp0s8 
            * adapter : 192.168.20.5
            * gateway : 192.168.20.1
    Routes: 
        VM1 packets
            * from: 192.168.10.1 gateway
            * to: 192.168.20.0/24 network
        VM3 packets
            * from: 192.168.20.1 gateway
            * to: 192.168.10.0/24 network
    ```yaml
    network:
        renderer: networkd
        version: 2
        ethernets:
            enp0s3:             #interface with intnet_a internal network
                dhcp4: no
                addresses:
                    - 192.168.10.5/24
                gateway4: 192.168.10.1
                routes:
                    - to: 192.168.10.0/24
                      via: 192.168.20.1
                      metric: 100
            enp0s8:             #interface with intnet_b internal network
                dhcp4: no
                addresses:
                    - 192.168.20.5/24
                gateway4: 192.168.20.1
                routes:
                    - to: 192.168.20.0/24
                      via: 192.168.10.1
                      metric: 100
    ``` 

    VM3:
    static IP: 192.168.10.4
    gateway: 192.168.10.1
    Routes: 
        packets
            * to: 192.168.10.0/24 network
            * through hop: 192.168.20.5
    ```yaml
    network:
        renderer: networkd
        version: 2
        ethernets:
            enp0s8:             #interface with intnet_b internal network
                dhcp4: no
                addresses:
                    - 192.168.20.4/24
                gateway4: 192.168.20.1
                routes:
                    - to: 192.168.10.0/24
                      via: 192.168.20.5
                      metric: 100
    ```

* To make them work, save the files & apply the settings using
    ```bash
    sudo netplan apply
    ``` 
    command and restart the network service with
    ```bash
    service systemd-networkd restart
    ```
    command and check whether the routes are added correctly using
    ```bash
    route -n
    or
    ip route
    ```
    command.
    
* Now, edit `/etc/sysctl.conf` file and uncomment a line with
    ```bash
    net.ipv4.ip_forward=1
    ```
    and save & load the changes using 
    ```bash
    sudo sysctl -p /etc/sysctl.conf
    ```

* Now verify the host reachability using `ping` command using VMs IP addresses as per needed connectivity:
    * VM1 <-> VM2(router)
    VM1 : `ping 192.168.10.5`
    VM2 : `ping 192.168.10.4`

    * VM2 (router) <-> VM3
    VM2 : `ping 192.168.20.4`
    VM3 : `ping 192.168.20.5`

    * VM1 <-> VM3 through Router VM2
    VM1 : `ping 192.168.20.4`
    VM3 : `ping 192.168.10.4`

    check whether all the ping commands return no packet loss and receives all packets.


* Port Forwarding using NAT table can be achieved by 2 ways:
    * editing `/etc/iptables/rules.v4` file
    * running `iptables` commands

* We initially need to have a tool called `iptables-persistent` for having the table persistent across reboots, for installing the tool, run
    ```bash
    sudo apt install -y iptables-persistent
    ```
    this tools also creates a file for specifying all the rules we need to set or modify at `/etc/iptables/` both for IPv4 & IPv6.

* In VM2 (router), I want to make the interface `enp0s8` to forward traffic received from VM1 through VM2's PORT `2222` , for that I need to have chains specified in NAT table

* We can add required rules as chains in NAT table using `iptables` command or edit `/etc/iptables/rules.v4` (as version4 addresses are used here)

* We have 3 main chains to be added in our router 
    ```md
    * PREROUTING
    * FORWARD
    * POSTROUTING
    ```
    the commands used and changes made to `rules.v4` file are:
    ```bash
    -A FORWARD -i enp0s3 -o enp0s8 -p tcp --syn -n conntrack --ctstate NEW -j ACCEPT
    -A FORWARD -i enp0s3 -o enp0s8 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    -A FORWARD -i enp0s8 -o enp0s3 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    COMMIT

    *nat
    :PREROUTING ACCEPT [0:0]
    :INPUT ACCEPT [0:0]
    :OUTPUT ACCEPT [0:0]
    :POSTROUTING ACCEPT [0:0]

    -A PREROUTING -i enp0s3 -p tcp -j DNAT --to-destination 192.168.20.5:2222
    -A POSTROUTING -d 192.168.20.0/24 -o enp0s8 -p tcp --dport 2222 -j SNAT --to-source 192.168.20.5:2222
    ```
    here, 
    * `enp0s3` : network interface to receive/send traffic from VM1
    * `enp0s8` : network interface to receive/send traffic from VM2
    * `-p` is used to specify the protocol, here it's `tcp`
    * `DNAT` (Destination NAT) is to change the destination address for the packet that VM2 receives from VM1, and we specify `--to-destination` for specifying the IP address / network / with port
    * PREROUTING works when interface sends the packets to modify the destination
    * POSTROUTING works when the packet returns from the destination to the source, here we need to change the source into destination and vice-versa, so we specify it using `SNAT` - Source NAT. This can also be achieved using `MASQUEARADE` by changing line into:
        ```bash
        -A POSTROUTING ! -d 192.168.20.0/24 -o enp0s8 -j MASQUERADE
        ```

* After the changes are made, run
    ```bash
    iptables restore -t < /etc/iptables/rules.v4
    ```
    command, if this returns no syntactical errors, then we can verify the results using 
    ```bash
    iptables -S                 #shows rules
    or 
    iptables -L                 #shows rules in table format 
    or
    iptables -t nat             #shows rules from only NAT table
    or
    iptables -t nat -vnL        #shows rules with many metrics
    ```
    commands.


## BGP setup

* Install `frr` software in all 3 VMs and edit `/etc/netplan/<yaml-file>` in each VM according to the IP addresses assigned in above topology, my netplan configuration has:
    ```
    * vm-router :
        * Interfaces : 
            * lo - 10.1.1.1/32
            * enp0s3 - 172.10.0.1/30
            * enp0s8 - 172.10.0.5/30
            * enp0s9 - 172.10.0.9/30    
    * vm-1 : 
        * Interfaces :
            * lo - 10.1.1.2/32
            * enp0s3 - 172.10.0.2/30
    * vm-2 : 
        * Interfaces :
            * lo - 10.1.1.3/32
            * enp0s3 - 172.10.0.6/30
    * vm-3 : 
        * Interfaces :
            * lo - 10.1.1.4/32
            * enp0s3 - 172.10.0.10/30
    ```

* Edit the daemons fileat `/etc/frr/daemons` and make `bgp=yes` for all vms, and also make ipv4 forwarding true at `etc/sysctl.conf` and make `net.ipv4.ip_forward=1` (remove the # infront of the statement).

* To establish BGP sessions, ensure `frr` is running and for confirmation, run `systemctl restart frr.service` this makes both `zebra` and `bgpd` daemons to run (should be done in all 4 vms), then configure BGP session by,
    * In `vm-router` :
        * Go to `vtysh` and `conf` and enter the commands :
            ```
            (config)#router bgp 10
            (config-router)#neighbor 172.10.0.2 remote-as 1
            (config-router)#neighbor 172.10.0.6 remote-as 2
            (config-router)#neighbor 172.10.0.10 remote-as 3
            (config-router)#address-family ipv4
            (config-router-af)#neighbor 172.10.0.2 activate
            (config-router-af)#neighbor 172.10.0.6 activate
            (config-router-af)#neighbor 172.10.0.10 activate
            ```
    * In `vm-1` :
        * Go to `vtysh` and `conf` and enter the commands :
            ```
            (config)#router bgp 1
            (config-router)#neighbor 172.10.0.1 remote-as 10
            (config-router)#address-family ipv4
            (config-router-af)#neighbor 172.10.0.1 activate
            ```
    * In `vm-2` :
        * Go to `vtysh` and `conf` and enter the commands :
            ```
            (config)#router bgp 2
            (config-router)#neighbor 172.10.0.5 remote-as 10
            (config-router)#address-family ipv4
            (config-router-af)#neighbor 172.10.0.5 activate
            ```
    * In `vm-3` :
        * Go to `vtysh` and `conf` and enter the commands :
            ```
            (config)#router bgp 3
            (config-router)#neighbor 172.10.0.9 remote-as 10
            (config-router)#address-family ipv4
            (config-router-af)#neighbor 172.10.0.9 activate
            ```
    now if you check the BGP session by running `sh ip bgp sum`, you can see under each neighbor's state is changed it into a number (mine was `0`), this was achieved as we used `activate` command to start exchanging the details from specified address.

* For Filters, we have 3 of them to do
    1. vm-router orginates and sends default route to vm-1 , vm-2 and vm-3
        * In vm-router :
        ```
        (config)#router bgp 10
        (config-router)#address-family ipv4
        (config-router-af)#neighbor 172.10.0.2 default-originate
        (config-router-af)#neighbor 172.10.0.6 default-originate
        (config-router-af)#neighbor 172.10.0.10 default-originate
        ```
        * Now verify the routes using
        ```
        # sh ip bgp
        or
        # sh ip route
        ```
        here you can see new default root got added showing `0.0.0.0/0` next hop is address of router's interface connected this machine and in case of command 2, it shows the Code from which the connection got established check for `B`, if found then default route is successfully advertised.
    
    2. Each of the vms ( vm1, 2, 3 ) will accept only default route from its bgp peer ( vm-router) and advertise their own loopback(IP on its lo interface ) to vm-router. 
        We use prefix-list for this purpose
        * In each VM :
        ```
        (config)#ip prefix-list IN_FIL seq 10 permit 0.0.0.0/0
        (config)#router bgp <ASN>
        (config-router)#neighbor <vm-router interface IP> prefix-list IN_FIL in
        ```
        this makes the VMs to receive the default routes advertised by `vm-router`. For advertising own loopback IPs, in each VM (vm-1 is considered):
        ```
        (config)#router bgp 1
        (config-router)#network 10.1.1.2/32 
        ```
        this command advertises the loopback interface IP into the `vm-router` from there, BGP takes care to inject into the BGP routes table. To verify, run
        ```
        #sh ip bgp
        or
        #sh ip route
        ```
        in `vm-router` to see all the routes that it learnt through the vms advertisements.
    
    3. vm-router to accept /32 IPs that belong to subnet (10.1.1.0/24) and reject all other routes.
        * In `vm-router` :
        ```
        (config)#ip prefix-list IN_RFIL seq 10 permit 10.1.1.0/24 le 32
        (config)#ip prefix-list IN_RFIL seq 5 deny any
        (config)#router bgp <ASN>
        (config-router)#neighbor 172.10.0.2 prefix-list IN_RFIL in
        (config-router)#neighbor 172.10.0.2 prefix-list IN_RFIL in
        (config-router)#neighbor 172.10.0.2 prefix-list IN_RFIL in
        ```

   
* Finally to verify our complete task, test using `ping` between
    * `vm-1` : 
        ```
        ping 10.1.1.3
        ping 10.1.1.4
        ```
    * `vm-2` : 
        ```
        ping 10.1.1.2
        ping 10.1.1.4
        ```
    * `vm-3` : 
        ```
        ping 10.1.1.3
        ping 10.1.1.2
        ```
    these commands should return no packet loss, then the task is completed successfully.
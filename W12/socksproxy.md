# SOCKS PROXY

1. Enable TCP forwarding on one of the vms(say mesos-master)

    ```
    nano /etc/ssh/sshd_config
    ```
2. Uncomment

    ```
    AllowTcpForwarding yes
    ```

3. save the file and restart the ssh service

    ```
    service ssh restart
    service ssh status
    ```

4. Add an entry to hosts file for the app domain.
    ```
    nano /etc/hosts
    ```

5. add the following line
    ```
    172.10.1.10 helloworld.traefik.phonepe.lc1
    ```

6. From  mac host ssh into the master vm where tcp forwarding is allowed

    ```
    ssh -D 8888 risheeth@192.168.0.112
    ```

7. Install firefox

8. Add foxyproxy as extension

9. Configure socks proxy on foxyproxy:  

    a. Click on the foxyproxy extension

    b. go to options

    c. add

    d. Fill out the following options:

    ```
    Title: <anyname>
    Proxy Type: SOCKS5
    Proxy IP address or DNS name: 127.0.0.1
    Port: 8888  # the one given with ssh -D option
    ``` 

10. Select the newly created proxy in the extension and browse the following pages:

    ```
    http://172.10.1.2:5050      # mesos dashboard
    http://172.10.1.2:8080      # marathon dashboard
    http://172.10.1.10:8080     # traefik dashboard
    https://172.10.1.14/        # nginx
    https://nginx.mesos.com
    http://helloworld.traefik.phonepe.lc1
    ```

11. On mac you can go to https://nginx.mesos.com which is configure to bridged ip of nginx box to see the application page.

12. The mac hosts file contains these domains:

```
nano /private/etc/hosts
```

```
192.168.0.102 nginx.mesos.com
```
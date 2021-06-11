
># Mesos-Marathon , Traefik & Nginx

## Complete app deployment using Mesos - Marathon 

Overall deployment and setup will look somewhat like this:

We will break it down into multiple small tasks

1. Create a Docker container running a python webserver, that listens on port 80 and returns the string "Hello world" for any requests

2. Create three VMs and setup the following,

    a. Mesos master, Marathon, and Zookeeper on VM1
    
    b. Mesos slave and Docker on VM2
    
    c. Traefik on VM3

3. Configure Traefik to get its data from Marathon

4. Deploy the docker container that you created in #1 to run as a Marathon app and it should be reachable using the Traefik

5. Setup VM4, install Nginx on it. Create a self-signed SSL Certificate and set up a proxy using Nginx which listens on port 443 with SSL enabled and forwards the requests to Traefik

> P.S:  All the 4 VMs will be connected to using BGP and will talk to each other using their loopback ips. This is how VMs will be connected

HELPFUL COMMANDS:

```
curl -v helloworld.traefik.phonepe.lc1
```

[Chrome cheat-code](https://dev.to/gautamkrishnar/quickbits-1-skipping-the-chrome-your-connection-is-not-private-warning-4kp1)

Mesos in action : https://livebook.manning.com/book/mesos-in-action/chapter-7/24
# Mesos Cluster Setup

## 1. Install dependencies

    sudo apt-get update
    sudo apt install -y openjdk-11-jre-headless

## 2. Install mesos

[mesos installation using .deb](http://mesos.apache.org/documentation/latest/building/)

> Get the env ready
```
sudo apt-get -y install build-essential python3-dev python3-six python3-virtualenv libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev iputils-ping
    
sudo apt-get install -y libcurl4-openssl-dev
    
sudo apt install -y libevent-dev
```

> Install mesos from .deb file provided
 
    sudo dpkg -i mesos-1.9.0-0.1.20200901105608.deb

> Confirm installation

    apt-cache policy mesos

## 3. Install Zookeeper

    apt-cache policy zookeeper
    
    sudo apt-get install zookeeper

## 4. Install Marathon

> setup deb repo (using xenial as focal version doesn't exist/work)

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
    
    DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    
    CODENAME=xenial

> add repo

    echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
    
    sudo apt-get -y update

> check version and install

    apt-cache policy marathon

    sudo apt-get install marathon

## 5. CLUSTER SETUP

##### https://www.bogotobogo.com/DevOps/DevOps_Mesos_Install.php


### 5.1 ZOOKEEPER CONFIG

> **STEP 1(masters+slaves):** Configure ZooKeeper connection info to point to the master servers:


     sudo nano /etc/mesos/zk

replace localhost with IP address of our mesos master servers:

    zk://172.10.1.2:2181/mesos

> **STEP 2:** Give each master server a unique id from 1 to 255

   sudo nano /etc/zookeeper/conf/myid


    1

>**STEP 3:** Specify all zookeeper server in the following file

sudo nano /etc/zookeeper/conf/zoo.cfg

    server.1=172.10.1.2:2888:3888

### 5.2 MESOS CONFIG ON MASTER SERVERS

> **STEP 1:** set it to over 50% of master members 

sudo nano /etc/mesos-master/quorum

    1  

> **STEP 2:** setup ip

sudo nano /etc/mesos-master/ip

    172.10.1.2

> **STEP 3:** setup hostname

sudo nano /etc/mesos-master/hostname

    172.10.1.2

### 5.3 MARATHON CONFIG ON MASTER  

Marathon doesn’t read command line arguments from config file anymore so specify them in default file.

> **STEP 1:**

<br>

sudo nano /etc/default/marathon

    MARATHON_MESOS_USER=root
    MARATHON_MASTER="zk://172.10.1.2:2181/mesos"     
    MARATHON_ZK="zk://172.10.1.2:2181/marathon"
    MARATHON_HOSTNAME="172.10.1.2”

## RESTART SERVICES  

  

> **STEP 1:** we need to make sure that our master servers are only running the Mesos master process, and not running the slave process. We can ensure that the server doesn't start the slave process at boot by creating an override file:

    echo manual | sudo tee /etc/init/mesos-slave.override

  

> **STEP 2:** Now, all we need to do is restart zookeeper, which will set up our master elections. We can then start our Mesos master and Marathon processes:

start zookeeper

    cd /usr/share/zookeeper/bin  
    ./zkServer.sh status    
    ./zkServer.sh start

start mesos-master

    sudo service mesos-master restart

start marathon

    sudo service marathon restart

## Check mesos dashboard
<br>

go to http://\<master-ip\>:5050

<br>

## Check marathon dashboard
<br>

go to http://\<master-ip\>:8080
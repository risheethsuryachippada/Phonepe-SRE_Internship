
# MESOS SLAVE


## 1. DOCKER APP



### 1.1 Install Docker


https://linuxize.com/post/how-to-install-and-use-docker-on-ubuntu-20-04/

First, update the packages index and install the dependencies necessary to add a new HTTPS repository:
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```

Import the repository’s GPG key using the following `curl` command:

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Add the Docker APT repository to your system:

```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

Install latest version on docker (community edition i.e. CE)

```
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```

```
sudo systemctl status docker
```

### 1.2 Create sample flask application

https://docs.docker.com/language/python/build-images/

Directory structure

```
python-docker
|____ app.py
|____ requirements.txt
|____ Dockerfile
```

```
mkdir ~/python-docker
cd /home/risheeth/python-docker
pip3 install Flask
pip3 freeze > requirements.txt
```

> Note: Edit the requirements.txt file to keep only Flask

```
touch app.py
```

add the code to app.py:

```
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, Docker!'
```

### 1.3 Test the app

```
python3 -m flask run --host 0.0.0.0 --post 80
```

### 1.4 Create a Dockerfile for Python

```
nano Dockerfile
```

paste the following code inside Dockerfile

```
# syntax=docker/dockerfile:1

FROM python:3.8-slim-buster

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
```

### 1.5 Build an image

```
docker build --tag python-docker .
```

### View local images

```
docker images
```

### 1.6 Run the image as a container
\
https://docs.docker.com/language/python/run-containers/

\
Run the container in detach mode (--detach or -d) and map the default flask port 5000 inside the container to port 80 on host using -p or --publish

```
docker run -d -p 80:5000 python-docker
```

other helpful commands

```
docker ps -a
docker restart <container_name>
```

## 2. Configure Mesos-Slave

\
https://www.bogotobogo.com/DevOps/DevOps_Mesos_Install.php

\
Install only mesos package on slaves

> Get the env ready

	sudo apt-get update

	sudo apt install -y openjdk-11-jre-headless

	sudo apt-get -y install build-essential python3-dev python3-six python3-virtualenv libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev iputils-ping

	sudo apt-get install -y libcurl4-openssl-dev

	sudo apt install -y libevent-dev

> Install mesos from .deb file provided

```
sudo dpkg -i mesos-1.9.0-0.1.20200901105608.deb
```
 
> Confirm installation
 
```
apt-cache policy mesos
```

> Configure ZooKeeper connection info to point to the master servers:

```
sudo nano /etc/mesos/zk
```
> replace localhost with IP address of our mesos master servers:

```
zk://172.10.1.2:2181/mesos
```

Since the slaves do not need to run their own zookeeper instances, we may want to stop any zookeeper process currently running on our slave nodes and create an override file so that it won't automatically start when the server reboots:

```
sudo service zookeeper stop
sudo sh -c "echo manual > /etc/init/zookeeper.override"
```
Then, we want to create another override file to make sure the Mesos master process doesn't start on our slave servers. We will also ensure that it is stopped currently:

```
sudo service mesos-master stop
sudo sh -c "echo manual > /etc/init/mesos-master.override"
```
set the IP address and hostname in /etc/mesos-slave dir

```
echo \<slave-private-ip\> | sudo tee /etc/mesos-slave/ip
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname
```

restart service and check slave entry on mesos dashboard at http://\<master-ip\>:5050/
```
sudo service mesos-slave restart
```

## 3. MAKING THE DOCKER APP RUN AS MARATHON APPLICATION
\
http://www.thedevpiece.com/deploying-and-running-docker-containers-on-marathon/

https://blog.couchbase.com/docker-apache-mesos-marathon/

\
create an account on docker-hub
```
docker login
docker tag python-docker:latest robsteneha/python-docker:latest
```
push image to docker hub
https://docs.docker.com/docker-hub/repos/

```
docker push risheethsuryachippada/python-docker:latest
```
  

  
```
echo 'docker,mesos' > /etc/mesos-slave/containerizers
echo '10mins' > /etc/mesos-slave/executor_registration_timeout
```
  
```
restart mesos-slave
```

create an app file somewhere

```
mkdir ~/json-apps
cd ~/json-apps
nano basic-app.json
```

> Note: 1. The ip provided here is the traefik's ip.
> 
> 2. Make sure the cpus of all the applications running on marathon never crosses


```
{
	"id": "basic-5",
	"cmd": "while [ true ] ; do echo 'Hello!!!' ; sleep 5 ; done",
	"cpus": 0.1,
	"mem": 10.0,
	"instances": 1,
	"labels":
	{
		"traefik.enable": "true",
		"traefik.http.routers.router0.rule": "Host(`192.168.0.107:80`)"
	}
}
```

Push the app to marathon

> Note: The ip provided is master's ip
```
curl -X POST http://192.168.0.112:8080/v2/apps -d @basic_app.json -H "Content-type: application/json"
```
OR
```
curl -d @basic_app.json -X POST -H "Content-type: application/json" http://192.168.0.112:8080/v2/apps
```

deploy second app

 ```
 nano app.json
 ```
 
```
{
  "id": "helloworld",
  "instances": 1,
  "cpus": 0.5,
  "mem": 256,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "robsteneha/python-docker",
      "network": "BRIDGE",
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 0,
          "protocol": "tcp"
        }
      ]
    }
  },
  "labels": {
    "traefik.http.routers.helloworld.service": "helloworld",
    "traefik.http.routers.helloworld.rule": "Host(`helloworld.traefik.phonepe.lc1`)",
    "traefik.backend": "helloworld",
    "traefik.host": "helloworld",
    "traefik.enable": "true",
    "traefik.portIndex": "0",
    "traefik.frontend.rule=Host": "helloworld.traefik.phonepe.lc1"
  }
}
```
  
Push
```
curl -X POST http://192.168.0.112:8080/v2/apps -d @app.json -H "Content-type: application/json"
```
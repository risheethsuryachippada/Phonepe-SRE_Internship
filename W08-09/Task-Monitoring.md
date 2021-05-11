
# Week8
## Task 1 : Setup collectd to monitor various metrics for operating system and one of the following datastores ES/RMQ/AS 
[Collectd influxd graphana](http://www.inanzzz.com/index.php/post/ms6c/collectd-influxdb-and-grafana-integration)

### Step1: Installation of collectd 

```bash 
sudo apt-get update
sudo apt-get install collectd collectd-utils
```

### Step2: Configure collectd 

```bash 
sudo nano /etc/collectd/collectd.conf
```
Now uncomment the plugins 
1.  LoadPlugin cpu
2.  LoadPlugin disk
3.  LoadPlugin load
4.  LoadPlugin memory
5.  LoadPlugin processes
6.  LoadPlugin swap
7.  LoadPlugin user

In addition to above, enable  `LoadPlugin network`  then add block below to the bottom of the page. [more about network](https://collectd.org/wiki/index.php/Networking_introduction)
```xml
  <Plugin  "network">    
      Server "ip of influxd" "port"
  </Plugin>    
```
Star service 

```bash
sudo systemctl start collectd
```

## Task2: Setup influxdb on a vm

### Installing influxd
```bash
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

sudo apt-get update && sudo apt-get install influxdb
sudo systemctl start influxdb.service
sudo systemctl start influx
```

### Create user along with influxd configuration 

```
1.  infludbVm:~$ influx
2.  Connected to http://localhost:8086 version 1.3.5
3.  InfluxDB shell version:  1.3.5
4.  >
5.  > CREATE USER risheeth WITH PASSWORD 'risheeth' WITH ALL PRIVILEGES
6.  >
7.  > SHOW USERS
8.  user    admin
9.  ----  -----
10.  risheeth true
11.  >
12.  > EXIT

```
  
  #### restart the service

```
1.  influxdVm:~$ sudo systemctl restart influxdb

```
  

#### Verify database

  ```

1.  influxdbVm:~$ influx -username risheeth -password risheeth 
2.  Connected to http://localhost:8086 version 1.3.5
3.  InfluxDB shell version:  1.3.5
4.  > CREATE DATABASE collectd 
5.  > SHOW DATABASES
6.  name: databases
7.  name
8.  ----
9.  _internal
10.  collectd
11.  >

```  

#### Configuration for collectd

  

Find  `[[collectd]]`  in  `/etc/influxdb/influxdb.conf`  file and make it match settings below.

  ```

1.  [[collectd]]
2.   enabled =  true
3.   bind-address =  ":25826"
4.   database =  "collectd"
5.   retention-policy =  ""
6.   typesdb =  "/usr/local/share/collectd/types.db"
7.   batch-size =  5000
8.   batch-pending =  10
9.   batch-timeout =  "10s"
10.   read-buffer =  0

  ```

#### Download types.db

```  

sudo mkdir /usr/local/share/collectd
sudo wget -P /usr/local/share/collectd https://raw.githubusercontent.com/collectd/collectd/master/src/types.db

```
## Task3: send metrics to influxdb

###  check the metrc in influxdb
```
1.  influxdbVm:~$ influx -username risheeth -password risheeth
2.  Connected to http://localhost:8086 version 1.3.5
3.  InfluxDB shell version:  1.3.5
4.  >
5.  > USE collectd
6.  Using database collectd
7.  >
8.  > SHOW MEASUREMENTS
9.  name: measurements
10.  name
11.  ----
12.  cpu_value
13.  memory_value
14.  >
15.  >
16.  > SELECT * FROM cpu_value LIMIT 5
17.  name: cpu_value
18.  time host instance type type_instance value
19.  ----  ----  --------  ----  -------------  -----
20.  1504974634305158622 other 0 cpu user 2711
21.  1504974634305164974 other 0 cpu nice 0
22.  1504974634305167452 other 0 cpu system 2448
23.  1504974634305167969 other 0 cpu idle 2227665
24.  1504974634305168533 other 0 cpu wait 372
25.  >
26.  > SELECT * FROM memory_value LIMIT 5
27.  name: memory_value
28.  time host type type_instance value
29.  ----  ----  ----  -------------  -----
30.  1504974634305230505 other memory used 190013440
31.  1504974634305231222 other memory buffered 16171008
32.  1504974634305231662 other memory cached 265412608
33.  1504974634305232101 other memory free 42156032

```

## Task4 : plot these metrics on grafana dashboard 

### Step1: Installing graphan server [reference](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-grafana-on-ubuntu-18-04) 

```bash
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

```
```bash
echo "deb https://packages.grafana.com/enterprise/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
```
```bash
sudo apt-get update
sudo apt-get install grafana-enterprise
```
Run the server
```bash
sudo systemctl start grafana-server
```
### Step2: adding data source
1. Click on configuration
2. Data source
3. Click on add data source and select influxdb
[see here for further configuration of data source](https://drive.google.com/file/d/1mphfLs3hK-Z2DdkXIQcxqP2QHYC16Kht/view?usp=sharing) 

### Step3: adding dashboard 
1. Click '+' and select dashboard 
2. add new panel and select edit
3. select the data source and the select the required measurement to see in the graph


## Task5: Setup riemann on a vm 

### Step1: installation [reference ](https://riemann.io/quickstart.html)

```bash
$ wget https://github.com/riemann/riemann/releases/download/0.3.6/riemann-0.3.6.tar.bz2
$ tar xvfj riemann-0.3.6.tar.bz2
$ cd riemann-0.3.6 
```
Create a file config.rb 
```bash
sudo nano riemann-0.3.6/etc/config.rb
```
now add the followin
```
set :port, 4567
set :bind, "0.0.0.0"
```
Edit the host addres on riemann.config  as shown
```
; Listen on the local interface over TCP (5555), UDP (5555), and websockets
; (5556)
(let [host "ip of riemann-installed machine"]
```

Start the server
```bash
bin/riemann etc/riemann.config
```
install riemann tools
```bash
sudo apt-get install rubygems ruby-dev
sudo gem install riemann-client riemann-tools riemann-dash
```
Start the dashboard with the server running .  
```bash
riemann-dash riemann-0.3.6/etc/config.rb
```
[follow this after running the dash rieman](https://www.betsol.com/blog/build-your-own-monitoring-system/)

## Task6: Write a script to collect the metrics previously collected by collectd and send it to Riemann

### Step1 : install librarie
1. **riemann-client** [reference](https://pypi.org/project/riemann-client/) : to communicate with riemann dash board
```bash
pip install riemann-client
```

2. **psutil** [reference ](https://psutil.readthedocs.io/en/latest/)
```bash
pip install psutil
```
other references
1. Rieman-client : https://github.com/gleicon/pyriemann/blob/master/examples/riemann_health.py
> Run the script with both the server and rieman dashboard borad      running, you should  see the metrics collected showing on dashboard


## Task7: The metrics should go to influxdb from Riemann 

### Configure the riemann.config file
navigate to riemann.config 


```bash
cd riemann-0.3.6/etc
```
edit and add the define a function as shown in lines

```bash
sudo nano riemann.config
```

```bash
(def send-influx
(influxdb {
:version :0.9
:host "<ip of influxdbVm>"
:port 8086
:db "name of db created in influxd"
:username "admin"
:password "admin"
:timeout 1000000})
```
call the same 

```bash
(streams
  (default :ttl 60
    ; Index all events immediately.
    index
    send-influx
    ; Log expired events.
    (expired
      (fn [event] (info "expired" event))))))
```

now stop restart the riemann-serve to load the change made 



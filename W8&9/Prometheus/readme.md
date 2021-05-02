
# Week9
## Task  : Setup Prometheus to monitor various metrics for operating system and one of the following datastores ES/RMQ/AS 
[Prometheus](https://prometheus.io/docs/prometheus/latest/getting_started/)

### Step1: Installation of Prometheus-Server 

```bash 
sudo apt-get update
wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz
tar xvzf prometheus-2.26.0.linux-amd64.tar.gz
cd prometheus-2.26.0.linux-amd64
```

### Step2: Configure collectd 

```bash 
sudo nano prometheus.yml
```
* To monitor the same node about the prometheus-health, we have job name 'prometheus' along with 9090 port.* Job name 'node' along with 9100/8080/* port for system metrics from node exporter.
* Job name 'aerospike' along with 9145 port for aerospike metrics from aerospike-prometheus-exporter.

```bash
scrape_configs:
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seco>
    scrape_interval: 5s

    static_configs:
      - targets: ['192.168.1.6:9090']

  - job_name:       'node'

    # Override the global default and scrape targets from this job every 5 seco>
    scrape_interval: 5s

    static_configs:
      - targets: ['192.168.1.32:9100']
        labels:
          group: 'production'

  - job_name: 'aerospike'

    scrape_interval: 5s
    static_configs:
      - targets: ['192.168.1.32:9145']
```      

* To run the prometheus-server
```bash 
./prometheus --config.file=prometheus.yml
```
* Type the Target_IP:Port/graph or /metrics on the browser to see the dashboard.


## Step3: Setup Node-Exporter 

* To setup the node-exporter on the respective node
[Node-Exporter](https://prometheus.io/docs/guides/node-exporter/#installing-and-running-the-node-exporter)

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
tar xvfz node_exporter-1.1.2.linux-amd64.tar.gz
cd node_exporter-1.1.2.linux-amd64
```
* To run the node-exporter with the respective choice of port number (8080/8081/8082/9100)
```bash 
./node_exporter --web.listen-address 192.168.1.32:8080
```

### Step4: Setup Aerospike-Prometheus-Exporter 

* To setup the AS-exporter on the respective node
[Aerospike-Prometheus-Exporter](https://docs.aerospike.com/docs/tools/monitorstack/install/linux.html)

```bash 
wget https://www.aerospike.com/download/monitoring/aerospike-prometheus-exporter/latest/artifact/deb -O aerospike-prometheus-exporter.tgz
tar -xvzf aerospike-prometheus-exporter.tgz
dpkg -i aerospike-prometheus-exporter-1.2.0-amd64.deb
cd /etc/aerospike-prometheus-exporter/
nano ape.toml
```
* To configure the AS config file (ape.toml)
[Aerospike-Prometheus-Exporter_Config](https://docs.aerospike.com/docs/tools/monitorstack/configure/index.html)

* As a minimum required configuration, edit /etc/aerospike-prometheus-exporter/ape.toml to add db_host (default localhost) and db_port (default 3000) to point to an Aerospike server IP and port.

``` 
[Aerospike]

db_host="192.168.1.32"
db_port=3000
```
* Update the Exporter's bind address and port if required. The defaults are 0.0.0.0:9145 as shown below.
``` 
[Agent]

bind=":9145"

labels={zone="asia-south1-a", platform="google compute engine"}
```
* Create a Prometheus configuration file /etc/prometheus/prometheus.yml with the following changes.
* Add scrape_configs with targets pointing to each instance of aerospike-prometheus-exporter.
```
scrape_configs:
  - job_name: 'aerospike'
    static_configs:
      - targets: ['192.168.1.32:9145']
```

* For Alerts, we can refer the same link as in the [Aerospike-Prometheus-Exporter_Config]
  
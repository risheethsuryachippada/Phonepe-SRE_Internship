># Tasks - Week 8 & 9

```
Topic : System OS & Data Stores Metrics Monitoring
```

You need to monitor the OS & other system metrics along with Data Store (Aerospike)

* Monitoring using Collectd:

    * Setup collectd to monitor various metrics for operating system and one of the following datastores ES/RMQ/AS.
    * Setup influxdb on a vm.
    * Send collectd metrics to influxdb
    * Plot these metrics on a grafana dashboards


* Monitor with Manual Script to Riemann:

    * Setup riemann on a vm
    * Write a script to collect the metrics previously collected by collectd and send it to riemann
    * The metrics should go to influxdb from riemann
    * metrics such as disk usage/ram usage/HWM etc should have a threshold (80%) and should send a critical alert to riemann once the threshold is breached.
  
## Aerospike Replication

* Aerospike architecture comprises three layers:
    1. Client Layer
    2. Clustering and Data Distribution Layer
    3. Data Storage Layer

* The main replication occurs at the Data Distribution layer which consists of Replication & Cross-Datacenter Replication.

* Data Migration Module: 
    * Each node uses a distributed hash algorithm to divide the primary index space into data slices and assign owners. 
    * The Aerospike Data Migration module intelligently balances data distribution across all nodes in the cluster, ensuring that each bit of data replicates across all cluster nodes and datacenters. 
    * This operation is specified in the system replication factor configuration.

* Sync/Async Replication: For writes with immediate consistency, it propagates changes to all replicas before committing the data and returning the result to the client.

* XDR - Cross Datacenter Replication
    1. The Aerospike Cross-Datacenter Replication (XDR) feature asynchronously replicates cluster data over higher-latency links, typically WANs.
    2. Aerospike refers to a remote destination as a datacenter.
    3. The process of sending data to a remote datacenter is known as shipping.
    4. Replication is defined per datacenter
        * single namespace or multiple namespaces
        * sets or only specific record sets
    5. Shipping record deletes
        * By default, record deletes by clients are shipped.
        * By default, record deletes from expiration or eviction by nsup are not shipped.
    6. Last Update Time (LUT) & Last Ship Time (LST
        * If the LUT is greater than the LST, the record is shipped to the defined remote nodes.
    7. XDR Topologies
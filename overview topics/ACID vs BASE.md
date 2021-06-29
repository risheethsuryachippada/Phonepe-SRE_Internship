# ACID v/s BASE

>ACID and BASE database consistency models

## ACID Consistency Model

![ACID acronym standing for Atomic, Consistent, Isolated, Durable](https://phoenixnap.com/kb/wp-content/uploads/2021/04/acid-acronym.png)

**_Atomic_**
-   All operations in a transaction succeed or every operation is rolled back.

**_Consistent_**
-   On the completion of a transaction, the database is structurally sound.

**_Isolated_**
-   Transactions do not contend with one another. Transactions cannot compromise the integrity of other transactions by interacting with them while they are still in progress..

**_Durable_**
-   The data related to the completed transaction will persist even in the cases of network or power outages. If a transaction fails, it will not impact the manipulated data.

ACID properties mean that once a transaction is complete, its data is consistent and stable on disk.

**Financial institutions will almost exclusively use ACID databases. Money transfers depend on the atomic nature of ACID.**

When it comes to NoSQL technologies, most graph databases use an ACID consistency model to ensure data is safe and consistently stored.

## BASE Consistency Model

![BASE acronym standing for Basically Available, Soft state, Eventually consistent](https://phoenixnap.com/kb/wp-content/uploads/2021/04/base-acronym.png)

**_Basic Availability_**
-   The database appears to work most of the time.
- Rather than enforcing immediate consistency, BASE-modelled NoSQL databases will ensure availability of data by spreading and replicating it across the nodes of the database cluster.

**_Soft-state_**
-   Stores don’t have to be write-consistent, nor do different replicas have to be mutually consistent all the time.
- Due to the lack of immediate consistency, data values may change over time. The BASE model breaks off with the concept of a database which enforces its own consistency, delegating that responsibility to developers.

**_Eventual consistency_**
-   Stores exhibit consistency at some later point.
- The fact that BASE does not enforce immediate consistency does not mean that it never achieves it. However, until it does, data reads are still possible

A BASE data store values availability ,but it doesn’t offer guaranteed consistency of replicated data at write time.

**Social network feeds are not well structured but contain huge amounts of data which a BASE-modeled database can easily store.**

>ACID vs BASE

![ACID vs BASE: Comparison of two Design Philosophies](https://luminousmen.com/media/acid-vs-base-comparison-of-two-design-philosophies.JPG)

![ACID vs BASE](https://iamluminousmen-media.s3.amazonaws.com/media/acid-vs-base-comparison-of-two-design-philosophies/acid-vs-base-comparison-of-two-design-philosophies-2.JPG)

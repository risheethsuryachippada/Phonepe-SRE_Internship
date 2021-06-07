# Bloom Filter

A  **Bloom filter**  is a space-efficient  probabilistic data structure that is used to test whether an  element is a member of a set.

![bloom-filter@2x](https://blog.cloudflare.com/content/images/2020/02/bloom-filter@2x.png)

False positive matches are possible, but  false negatives are not – in other words, a query returns either "**possibly in set**" or "**definitely not in set**". Elements can be added to the set, but not removed (though this can be addressed with the counting Bloom filter variant, the more items added, the larger the probability of false positives.



An _empty Bloom filter_ is a bit array of m bits, all set to 0. There must also be k different hash functions defined, each of which maps or hashes some set element to one of the m array positions, generating a uniform random distribution. 
- Typically, k is a small constant which depends on the desired false error rate ε, while m is proportional to k and the number of elements to be added.

1. To _add_ an element, feed it to each of the k hash functions to get k array positions. Set the bits at all these positions to 1.

![All About Bloom Filters - Manning](https://freecontent.manning.com/wp-content/uploads/bloom-filters_02.png)


2. To _query_ for an element (test whether it is in the set), feed it to each of the k hash functions to get k array positions.
	- If _any_ of the bits at these positions is 0, the element is **definitely not in the set**;
	- If all are 1, then either the element is in the set, _or_ the bits have by chance been set to 1 during the insertion of other elements, resulting in a **false positive**.


![All About Bloom Filters - Manning](https://freecontent.manning.com/wp-content/uploads/bloom-filters_03.png)
3. Removing an element from this simple Bloom filter is impossible because there is no way to tell which of the k bits it maps to should be cleared. Although setting any one of those k bits to zero suffices to remove the element, it would also remove any other elements that happen to map onto that bit, clearing any of the bits would introduce the possibility of **false negatives**.

4. When the false positive rate gets too high, the filter can be regenerated.

5. It's a nice property of Bloom filters that you can modify the false positive rate of your filter. A larger filter will have less false positives, and a smaller one more.

6. The more hash functions you have, the slower your bloom filter, and the quicker it fills up. If you have too few, however, you may suffer too many false positive

```bash
 bloom - utility to work with Bloom filter
```

---
1.  **Space efficiency:**  Bloom filter does not store the actual items. In this way it’s space efficient. It’s just an array of integers.
2.  Saves expensive data scanning across several servers depending on the use case.

![](https://freecontent.manning.com/wp-content/uploads/bloom-filters_01.png)

## Applications which use Bloom Filters

### One-hit-wonders
- Facebook uses bloom filters to avoid caching the items that are very rarely searched or searched only once. Only when they are searched more than once, they will get cached. Several strategies might be designed to avoid such situations.


### Redis
- Bloom filters have been used with Redis for many years via client side libraries that leveraged  [GETBIT](https://redis.io/commands/getbit)  and  [SETBIT](https://redis.io/commands/setbit)  to work with a bitfield at a key. Thankfully, since Redis 4.0, the  [ReBloom](https://docs.redislabs.com/latest/modules/redisbloom/)  module has been available which takes away any Bloom filter implementation overhead.
- A good use case for a Bloom filter is to check for an already used username.
- You can tweak the error rate and size with the [BF.RESERVE](http://rebloom.io/Commands/#bfreserve) command

### Aerospike
- In Aerospike 4.x releases, XDR used a Bloom filter based implementation for shipping modified bins and this could occasionally cause a small number of unmodified bins to also be shipped along with any modified bins.
- Aerospike 5.2 uses an improved algorithm for shipping modified bins that guarantees that only the exact set of changed bins is shipped in all cases.

### Apache Cassandra
- Cassandra uses bloom filters to test if any of the SSTables is likely to contain the requested partition key or not, _without_ actually having to read their contents.
- Sorted String Tables(SST) are the immutable data files that Cassandra uses for persisting data on disk.

### Squid
- Squid web proxy keep the copies of recently-accessed web pages, but also keep the record of recently accessed web pages of their neighbors by having each proxy occasionally broadcast the Bloom filter of their own cache.
![](https://freecontent.manning.com/wp-content/uploads/bloom-filters_04.png)
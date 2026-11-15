# Portfolio 5 · Distributed and cloud databases (6 marks)

The lab uses three MongoDB data-bearing members on a private Docker network. The application connects via the replica-set URI. The primary accepts writes and secondaries replicate its oplog. Run these commands from this directory in PowerShell. The lab has no authentication and publishes no host ports. Use a dedicated local machine or lab VM.

```powershell
docker compose up -d
docker compose exec -T db1 mongosh --quiet --eval 'rs.initiate({_id:"ur",members:[{_id:0,host:"db1:27017"},{_id:1,host:"db2:27017"},{_id:2,host:"db3:27017"}]})'
docker compose cp probe.js db2:/tmp/probe.js
$uri = 'mongodb://db1:27017,db2:27017,db3:27017/?replicaSet=ur'
docker compose exec -T db2 mongosh $uri --quiet --eval 'printjson(rs.status().members.map(m => [m.name,m.stateStr]))'
docker compose exec -T -e UR_PHASE=before db2 mongosh $uri --quiet --file /tmp/probe.js
```

If the first status call fails before election, repeat it after a few seconds. Run the before probe with one primary and two healthy secondaries. Record its primary. Stop that service, then rerun the after probe from a surviving service. If db2 is the primary, first copy probe.js to db1 and use db1 as the surviving client.

```powershell
docker compose cp probe.js db1:/tmp/probe.js
$primary = Read-Host 'Service reported as primary before failover (db1, db2 or db3)'
if ($primary -notin @('db1','db2','db3')) { throw 'Invalid service' }
$client = if ($primary -eq 'db2') { 'db1' } else { 'db2' }
docker compose stop $primary
docker compose exec -T -e UR_PHASE=after $client mongosh $uri --quiet --file /tmp/probe.js
docker compose start $primary
docker compose exec -T $client mongosh $uri --quiet --eval 'printjson(rs.status().members.map(m => [m.name,m.stateStr]))'
docker compose down
```

During election, retry the after command after a few seconds if no primary is available. Expect two live voting members to elect a replacement and acknowledge a new majority write. The before marker should survive. Record exact command outputs and UTC observation times. To test loss of quorum separately, stop two members, attempt a primary-connected write with a server-selection timeout in the URI, record the client error, then restart both. Allow replication to catch up before stopping the lab. Standard down retains volumes. For re-use, start them and skip rs.initiate.

## Cloud design and trade-offs

In a managed deployment, place data-bearing replicas across three availability zones within one region and connect application services over private endpoints with TLS and least-privilege credentials. Keep transcript reads on the primary with majority read concern for this workflow. Majority acknowledgement trades write latency and minority-side availability for protection from rollback during ordinary primary failover. A partition with only one of three voters cannot elect a writable primary. Secondaries can lag and eligible reads can return older data. Majority reads expose majority-committed data, with causal sessions or stronger read guarantees needed for specific ordering requirements. Replication copies the data for availability. Sharding divides data to scale capacity and throughput. If load warrants sharding the transcript read model, test hashed matric lookup distribution and weigh scatter-gather for cross-student reporting. Backups and tested restores address deletion and disaster scenarios that replication alone cannot cover. The three local containers exercise process failure on one host. Cross-zone failure, regional recovery, billing and managed backups require a cloud deployment.

[MongoDB replica set write concern](https://www.mongodb.com/docs/manual/core/replica-set-write-concern/) · [MongoDB read concern](https://www.mongodb.com/docs/manual/reference/read-concern/)

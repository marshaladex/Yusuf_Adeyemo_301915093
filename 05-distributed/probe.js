// Connect via the replica set URI so mongosh can discover a replacement primary.
const lab = db.getSiblingDB("uniresult_distributed");
const hello = lab.adminCommand({ hello: 1 });
if (!hello.isWritablePrimary || hello.setName !== "ur") {
  throw new Error("Expected a writable primary in replica set ur");
}
const phase = process.env.UR_PHASE || "before";
if (!["before", "after"].includes(phase)) throw new Error("Unknown probe phase");
const probes = lab.getCollection("probes");
const response = probes.updateOne(
  { _id: phase },
  { $set: { primary: hello.me, observedAt: new Date() } },
  { upsert: true, writeConcern: { w: "majority", wtimeout: 10000 } }
);
if (!response.acknowledged) throw new Error("Expected an acknowledged write");
const read = lab.runCommand({
  find: "probes", filter: { _id: { $in: ["before","after"] } }, sort: { _id: 1 },
  readConcern: { level: "majority" }
});
if (read.ok !== 1) throw new Error("Majority read failed");
const rows = read.cursor.firstBatch;
const before = rows.find(row => row._id === "before");
const after = rows.find(row => row._id === "after");
if (!before || (phase === "after" && (!after || after.primary === before.primary))) {
  throw new Error("Expected the before marker and a different primary after failover");
}
printjson({ phase, primary: hello.me, markers: rows,
  members: rs.status().members.map(({name,stateStr,health}) => ({name,stateStr,health})) });

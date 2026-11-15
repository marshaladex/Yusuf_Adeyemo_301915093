// Run with mongosh against an isolated lab. Replaces only this demo collection.
const database = db.getSiblingDB("uniresult_mongo");
const collectionName = "transcripts";
database.getCollection(collectionName).drop();

function check(condition, message) {
  if (!condition) throw new Error(message);
}

const gradeScale = [[70,"A",5],[60,"B",4],[50,"C",3],[45,"D",2],[40,"E",1],[0,"F",0]];
const integer = (minimum, maximum) => ({ bsonType: "int", minimum, maximum });
const string = { bsonType: "string" };
const created = database.createCollection(collectionName, {
  validator: { $jsonSchema: {
    bsonType: "object",
    required: ["student", "sessionStart", "semester", "attempts"],
    properties: {
      student: { bsonType: "object", required: ["matric", "name", "department"],
        properties: { matric: string, name: string, department: string } },
      sessionStart: integer(2000, 2100),
      semester: integer(1, 2),
      attempts: { bsonType: "array", minItems: 1, items: {
        bsonType: "object", required: ["offeringId", "code", "title", "credits", "score"],
        properties: { offeringId: integer(1, 2147483647), code: string, title: string,
          credits: integer(1, 6),
          score: { bsonType: ["int", "decimal", "null"], minimum: 0, maximum: 100 } }
      } }
    }
  } },
  validationLevel: "strict",
  validationAction: "error"
});
check(created.ok === 1, "Collection creation failed");
const transcripts = database.getCollection(collectionName);
transcripts.createIndex({ "student.matric": 1, sessionStart: 1, semester: 1 }, { unique: true });
const students = [
  ["UR/24/0001", "Amara Okeke", "Computer Science"],
  ["UR/24/0002", "Tunde Bello", "Computer Science"],
  ["UR/24/0003", "Aisha Yusuf", "Mathematics"],
  ["UR/24/0004", "Efe Daniels", "Statistics"],
  ["UR/24/0005", "Kemi Afolabi", "Computer Science"],
  ["UR/25/0006", "Ibrahim Musa", "Mathematics"]
];
const offerings = {
  11: ["CSC301", "Database Systems", 3],
  12: ["MAT305", "Linear Algebra", 2],
  13: ["STA307", "Applied Statistics", 3],
  14: ["CSC315", "Data Structures", 3],
  21: ["CSC301", "Database Systems", 3]
};
const terms = [
  [0,2024,1,[[11,78],[12,64]]], [0,2024,2,[[14,69]]],
  [1,2024,1,[[11,38]]], [1,2025,1,[[21,62]]],
  [2,2024,1,[[12,91],[13,55]]], [3,2024,1,[[13,58],[12,47]]],
  [4,2024,1,[[11,72]]], [4,2024,2,[[14,40]]], [5,2025,1,[[21,null]]]
];
const documents = terms.map(([studentIndex, year, term, scores]) => {
  const [matric, name, department] = students[studentIndex];
  return {
    student: { matric, name, department },
    sessionStart: NumberInt(year), semester: NumberInt(term),
    attempts: scores.map(([id, score]) => {
      const [code,title,credits] = offerings[id];
      return { offeringId: NumberInt(id), code, title, credits: NumberInt(credits),
        score: score === null ? null : NumberDecimal(String(score)) };
    })
  };
});
check(transcripts.insertMany(documents).acknowledged, "Seed insert was unacknowledged");
const amara = { "student.matric": "UR/24/0001", sessionStart: 2024, semester: 1 };
printjson(transcripts.findOne(amara));
check(transcripts.countDocuments({}) === 9, "Unexpected term document count");
check(documents.reduce((total, doc) => total + doc.attempts.length, 0) === 12, "Unexpected attempt count");

const points = { $switch: {
  branches: gradeScale.slice(0,-1).map(([minimum,,point]) => ({
    case: { $gte: ["$attempts.score",minimum] }, then: point
  })), default: 0
} };
const gpas = transcripts.aggregate([
  { $unwind: "$attempts" },
  { $match: { "attempts.score": { $ne: null } } },
  { $group: { _id: { matric: "$student.matric", year: "$sessionStart", term: "$semester" },
    weighted: { $sum: { $multiply: ["$attempts.credits",points] } },
    credits: { $sum: "$attempts.credits" } } },
  { $project: { gpa: { $round: [{ $divide: ["$weighted","$credits"] },2] } } },
  { $sort: { "_id.matric": 1, "_id.year": 1, "_id.term": 1 } }
]).toArray();
printjson(gpas);
check(gpas.length === 8 && gpas[0]._id.matric === "UR/24/0001" && gpas[0].gpa === 4.6,
      "Unexpected GPA aggregation");

const pending = { "student.matric": "UR/25/0006", sessionStart: 2025, semester: 1,
  attempts: { $elemMatch: { offeringId: 21, score: null } } };
check(transcripts.updateOne(pending, { $set: { "attempts.$.score": NumberDecimal("66") } }).modifiedCount === 1,
      "Pending posting failed");
check(transcripts.updateOne(pending, { $set: { "attempts.$.score": NumberDecimal("67") } }).matchedCount === 0,
      "Second posting should find no pending attempt");
const posted = { "student.matric": "UR/25/0006", sessionStart: 2025, semester: 1,
  attempts: { $elemMatch: { offeringId: 21, score: NumberDecimal("66") } } };
check(transcripts.updateOne(posted, { $set: { "attempts.$.score": null } }).modifiedCount === 1,
      "Fixture cleanup failed");
let rejected = false;
try {
  transcripts.updateOne(pending, { $set: { "attempts.$.score": NumberDecimal("101") } });
} catch (error) {
  if (error.code !== 121) throw error;
  rejected = true;
}
check(rejected, "Validator accepted out-of-range score");
try {
  const { _id, ...duplicateTerm } = documents[0];
  transcripts.insertOne(duplicateTerm);
  throw new Error("Duplicate term accepted");
} catch (error) {
  if (error.code !== 11000) throw error;
}
printjson(transcripts.find(amara).explain("executionStats"));
print("MongoDB checks passed");

# Portfolio 4 · MongoDB implementation (7 marks)

Run mongosh with --file 04-mongodb/uniresult.js against an isolated MongoDB instance. The script rebuilds only uniresult_mongo.transcripts. Verify nine student-term documents, 12 attempts, eight GPA rows, Amara's first-term GPA of 4.60, rejection of invalid scores and duplicate transcripts, and a guarded result posting that restores the pending state.

The document grain is one student and academic term. Attempts are embedded because the primary access path fetches a semester transcript and the list is bounded by the term's course load. Course and student descriptors are snapshots, which reduces joins and retains displayed labels. Offerings and matric values are logical identifiers from the same synthetic fixture. Keep administrative writes in the relational source of truth and rebuild or upsert the read model when approved records change. This exercise loads the same fixture independently. It has no live synchronisation process.

The compound unique index enforces one document per matric, session and semester. It does not enforce unique offering IDs within the array. The controlled loader creates one entry per offering. Extensions allowing enrolment should atomically guard an append by checking that the offering ID is absent. Single-document score posting is atomic. A departmental dashboard must unwind or aggregate across documents, and changing current names across stored snapshots would require multiple document updates.

Save the execution output and explain's winning plan and examined keys/documents. A collection scan may be reasonable at this fixture size. Compare the SQL and MongoDB transcript models using the same matric and term.

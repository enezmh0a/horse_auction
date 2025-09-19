const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

function mkId(s) {
  if (!s) return null;
  const t = String(s).trim();
  const m = t.match(/^lot\s*(\d{1,3})$/i);
  if (m) return `lot${m[1]}`;       // "Lot 04" -> "lot04"
  return t.toLowerCase().replace(/\s+/g, ""); // strip spaces, lowercase
}

async function copySubcollection(srcDocRef, dstDocRef, sub = "bids") {
  const snap = await srcDocRef.collection(sub).get();
  const batch = db.batch();
  snap.forEach((d) => batch.set(dstDocRef.collection(sub).doc(d.id), d.data(), { merge: true }));
  await batch.commit();
}

(async () => {
  const dry = process.argv.includes("--dry");
  const lots = await db.collection("lots").get();
  const groups = new Map();

  // group by normalized human code (lotId/code/id/name) or doc.id fallback
  for (const doc of lots.docs) {
    const d = doc.data() || {};
    const key = [d.lotId, d.code, d.id, d.name].map(mkId).find(Boolean) || doc.id;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(doc);
  }

  for (const [key, docs] of groups.entries()) {
    if (docs.length < 2) continue; // no dupes

    // pick canonical: the one whose doc.id already equals the key, else first
    let canon = docs.find((d) => d.id === key) || docs[0];
    const canonRef = db.collection("lots").doc(canon.id);
    const canonData = canon.data() || {};
    console.log(`Group "${key}": ${docs.length} docs (canonical: ${canon.id})`);

    for (const doc of docs) {
      if (doc.id === canon.id) continue;
      const data = doc.data() || {};
      console.log(`${dry ? "[DRY MERGE]" : "[MERGE]"} ${doc.id} -> ${canon.id}`);

      if (!dry) {
        // merge top-level fields (prefer canonical truthy fields),
        // force lotId field to equal the canonical key
        const merged = { ...data, ...canonData, lotId: key, updatedAt: FieldValue.serverTimestamp() };
        await canonRef.set(merged, { merge: true });
        await copySubcollection(doc.ref, canonRef, "bids");
        await doc.ref.delete();
      }
    }
  }

  console.log("Dedup complete.");
  process.exit(0);
})();

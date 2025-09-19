const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

function mkId(s) {
  if (!s) return null;
  const t = String(s).trim();
  // normalize "Lot 04" / "lot 04" / "LOT04" -> "lot04"
  const m = t.match(/^lot\s*(\d{1,3})$/i);
  if (m) return `lot${m[1]}`;
  return t.toLowerCase().replace(/\s+/g, "").replace(/[^a-z0-9_-]/g, "");
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
  console.log(`Found ${lots.size} lot docs`);

  for (const doc of lots.docs) {
    const data = doc.data() || {};
    const candidates = [data.lotId, data.code, data.id, data.name];
    let target = candidates.map(mkId).find(Boolean);

    if (!target) {
      console.warn(`SKIP: ${doc.id} has no usable code (lotId/code/id/name).`);
      continue;
    }

    // special: if original lotId looks like "lot 04", force canonical "lot04"
    if (!/^lot\d+$/i.test(target) && data.lotId && /^lot\s*\d+$/i.test(data.lotId)) {
      target = data.lotId.toLowerCase().replace(/\s+/g, "");
    }

    if (target === doc.id) {
      console.log(`OK: ${doc.id} already canonical`);
      continue;
    }

    // If target exists, skip (we’ll fix with the dedupe step)
    const dstRef = db.collection("lots").doc(target);
    const dstSnap = await dstRef.get();
    if (dstSnap.exists) {
      console.warn(`DUPLICATE TARGET: ${target} already exists; keep ${doc.id} for now`);
      continue;
    }

    console.log(`${dry ? "[DRY]" : "[MOVE]"} ${doc.id} -> ${target}`);
    if (dry) continue;

    // create canonical doc with merged data
    await dstRef.set(
      {
        ...data,
        lotId: target,                     // keep a field mirroring the docId
        migratedFrom: doc.id,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    await copySubcollection(doc.ref, dstRef, "bids");
    await doc.ref.delete();
  }

  console.log("Migration complete.");
  process.exit(0);
})();

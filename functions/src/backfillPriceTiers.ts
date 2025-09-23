import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "./firebase";

// reuse the same thresholds as placeBid
function tierFor(amount: number): "low" | "mid" | "high" {
  if (amount >= 50000) return "high";
  if (amount >= 20000) return "mid";
  return "low";
}

export const backfillPriceTiers = onCall(async (req) => {
  if (!req.auth?.token?.admin) throw new HttpsError("permission-denied", "Admin only");

  const snap = await db.collection("lots").get();
  const batch = db.batch();
  let count = 0;

  snap.forEach((doc) => {
    const d = doc.data() as any;
    const current = d.currentHighest ?? d.startingPrice ?? 0;
    const t = tierFor(current);
    batch.update(doc.ref, { tier: t });
    count++;
  });

  await batch.commit();
  return { ok: true, updated: count };
});

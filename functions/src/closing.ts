// functions/src/closing.ts
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "./firebase"; // your admin Firestore instance

export const closeExpiredLotsNow = onCall({ region: "me-central1" }, async (req) => {
  if (!req.auth?.token?.admin) {
    throw new HttpsError("permission-denied", "Admin only");
  }

  const now = new Date();

  const snap = await db
    .collection("lots")
    .where("status", "==", "live")
    .where("closeAt", "<=", now)
    .get();

  const batch = db.batch();
  snap.docs.forEach((doc) => {
    batch.update(doc.ref, { status: "closed", closedAt: now });
  });

  if (!snap.empty) {
    await batch.commit();
  }

  return { closedCount: snap.size };
});

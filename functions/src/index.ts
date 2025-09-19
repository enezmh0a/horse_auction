import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
// (Optional) You can keep or remove setGlobalOptions; the per-function option below wins.

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// --- helper unchanged ---
async function rejectOtherPendingBids(lotId: string, acceptedBidId: string) {
  const bidsRef = db.collection("lots").doc(lotId).collection("bids");
  const snap = await bidsRef.get();
  const batch = db.batch();
  snap.forEach((doc: FirebaseFirestore.QueryDocumentSnapshot) => {
    if (doc.id !== acceptedBidId) {
      const b = doc.data() || {};
      const isPending = !b.status || b.status === "pending";
      if (isPending) batch.update(doc.ref, { status: "rejected" });
    }
  });
  await batch.commit();
}

// ✅ Region forced to me-central1 (TEMP) to bypass the 403
export const acceptBid = onCall({ region: "me-central1" }, async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "Sign in required.");
  if (!auth.token?.admin) throw new HttpsError("permission-denied", "Admin only.");

  const uid = auth.uid;
  const { lotId, bidId } = (request.data || {}) as { lotId?: string; bidId?: string };
  if (!lotId || !bidId) throw new HttpsError("invalid-argument", "lotId & bidId required.");

  const lotRef = db.collection("lots").doc(lotId);
  const bidRef = lotRef.collection("bids").doc(bidId);

  await db.runTransaction(async (tx) => {
    const lotSnap = await tx.get(lotRef);
    const bidSnap = await tx.get(bidRef);
    if (!lotSnap.exists || !bidSnap.exists) throw new HttpsError("not-found", "Lot or bid not found.");
    const bid = bidSnap.data() || {};
    const isPending = !bid.status || bid.status === "pending";
    if (!isPending) throw new HttpsError("failed-precondition", "Bid is not pending.");

    tx.update(bidRef, {
      status: "accepted",
      approvedBy: uid,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.update(lotRef, {
      currentHighest: Number(bid.amount || 0),
      lastAcceptedBidId: bidRef.id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await rejectOtherPendingBids(lotId, bidId);
  return { ok: true };
});

export const rejectBid = onCall({ region: "me-central1" }, async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "Sign in required.");
  if (!auth.token?.admin) throw new HttpsError("permission-denied", "Admin only.");

  const uid = auth.uid;
  const { lotId, bidId } = (request.data || {}) as { lotId?: string; bidId?: string };
  if (!lotId || !bidId) throw new HttpsError("invalid-argument", "lotId & bidId required.");

  const bidRef = db.collection("lots").doc(lotId).collection("bids").doc(bidId);
  await bidRef.update({
    status: "rejected",
    approvedBy: uid,
    approvedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { ok: true };
});

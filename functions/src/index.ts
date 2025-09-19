import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// Reject other bids still pending (no status or "pending")
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

function assertId(name: string, v?: string) {
  if (!v || typeof v !== "string" || /[\/\\]/.test(v)) {
    throw new HttpsError("invalid-argument", `${name} must be a document ID (no slashes).`);
  }
}

/** acceptBid (admin only) */
export const acceptBid = onCall({ region: "me-central1" }, async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "Sign in required.");
  if (!auth.token?.admin) throw new HttpsError("permission-denied", "Admin only.");

  const { lotId, bidId } = (request.data || {}) as { lotId?: string; bidId?: string };
  assertId("lotId", lotId);
  assertId("bidId", bidId);

  const uid = auth.uid;

  try {
    const lotRef = db.collection("lots").doc(lotId!);
    const bidRef = lotRef.collection("bids").doc(bidId!);

    await db.runTransaction(async (tx) => {
      const [lotSnap, bidSnap] = await Promise.all([tx.get(lotRef), tx.get(bidRef)]);

      if (!lotSnap.exists) throw new HttpsError("not-found", "Lot not found.");
      if (!bidSnap.exists) throw new HttpsError("not-found", "Bid not found.");

      const bid = bidSnap.data() || {};
      const amount = Number(bid.amount);
      if (!Number.isFinite(amount)) {
        throw new HttpsError("failed-precondition", "Bid amount missing/invalid.");
      }
      const status = bid.status ?? "pending";
      if (status !== "pending") {
        throw new HttpsError("failed-precondition", `Bid is ${status}, not pending.`);
      }

      tx.update(bidRef, {
        status: "accepted",
        approvedBy: uid,
        approvedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      tx.update(lotRef, {
        currentHighest: amount,
        lastAcceptedBidId: bidRef.id,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await rejectOtherPendingBids(lotId!, bidId!);
    return { ok: true };
  } catch (e: any) {
    console.error("acceptBid failed", { lotId, bidId, err: e?.message, stack: e?.stack });
    if (e instanceof HttpsError) throw e;
    throw new HttpsError("internal", e?.message || "acceptBid failed");
  }
});

/** rejectBid (admin only) */
export const rejectBid = onCall({ region: "me-central1" }, async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "Sign in required.");
  if (!auth.token?.admin) throw new HttpsError("permission-denied", "Admin only.");

  const { lotId, bidId } = (request.data || {}) as { lotId?: string; bidId?: string };
  assertId("lotId", lotId);
  assertId("bidId", bidId);

  const uid = auth.uid;

  try {
    const bidRef = db.collection("lots").doc(lotId!).collection("bids").doc(bidId!);
    const snap = await bidRef.get();
    if (!snap.exists) throw new HttpsError("not-found", "Bid not found.");

    await bidRef.update({
      status: "rejected",
      approvedBy: uid,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { ok: true };
  } catch (e: any) {
    console.error("rejectBid failed", { lotId, bidId, err: e?.message, stack: e?.stack });
    if (e instanceof HttpsError) throw e;
    throw new HttpsError("internal", e?.message || "rejectBid failed");
  }
});

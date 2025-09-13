// C:\horse-auction-firebase\functions\index.js
const functions = require("firebase-functions/v1"); // v1 compat
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Cloud Function: onBidCreated
 * Triggers when a new bid (status="pending") is created under lots/{lotId}/bids/{bidId}
 * Validates auction state/times and minIncrement/reservePrice, then accepts or rejects atomically.
 */
exports.onBidCreated = functions
  .region("us-central1") // or "europe-west3" if you prefer Frankfurt
  .firestore.document("lots/{lotId}/bids/{bidId}")
  .onCreate(async (snap, context) => {          // <-- async is REQUIRED
    const { lotId, bidId } = context.params;
    const bidRef = snap.ref;
    const lotRef = db.collection("lots").doc(lotId);

    const bid = snap.data();
    if (!bid || bid.status !== "pending") {
      await bidRef.update({ status: "rejected", reason: "INVALID_STATUS" });
      return;
    }

    try {
      await db.runTransaction(async (tx) => {
        const lotSnap = await tx.get(lotRef);
        if (!lotSnap.exists) {
          tx.update(bidRef, { status: "rejected", reason: "LOT_NOT_FOUND" });
          return;
        }

        const lot = lotSnap.data();
        const now = admin.firestore.Timestamp.now();

        // Auction lifecycle guards
        if (lot.state !== "live") {
          tx.update(bidRef, { status: "rejected", reason: "AUCTION_NOT_LIVE" });
          return;
        }
        if (lot.startTime && now.toMillis() < lot.startTime.toMillis()) {
          tx.update(bidRef, { status: "rejected", reason: "BEFORE_START" });
          return;
        }
        if (lot.endTime && now.toMillis() > lot.endTime.toMillis()) {
          tx.update(bidRef, { status: "rejected", reason: "AFTER_END" });
          return;
        }

        const currentHighest = lot.currentHighest || 0;
        const minInc = Math.max(1, lot.minIncrement || 1);

        // Must beat currentHighest + minIncrement
        if (typeof bid.amount !== "number" || bid.amount < currentHighest + minInc) {
          tx.update(bidRef, { status: "rejected", reason: "LOW_BID" });
          return;
        }

        // Enforce reserve for opening bid
        if (lot.reservePrice && currentHighest === 0 && bid.amount < lot.reservePrice) {
          tx.update(bidRef, { status: "rejected", reason: "BELOW_RESERVE" });
          return;
        }

        // Accept bid
        const newBidCount = (lot.bidCount || 0) + 1;

        tx.update(lotRef, {
          currentHighest: bid.amount,
          currentHighestBidId: bidId,
          bidCount: newBidCount,
          updatedAt: now,
        });

        tx.update(bidRef, {
          status: "accepted",
          reason: admin.firestore.FieldValue.delete(),
          processedAt: now,
        });
      });
    } catch (e) {
      console.error("Transaction error:", e);
      await bidRef.update({ status: "rejected", reason: "TX_ERROR" });
    }
  });

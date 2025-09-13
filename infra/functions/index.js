// C:\horse-auction-firebase\functions\index.js
const functions = require("firebase-functions/v1"); // v1 compat
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

const REGION = "europe-west3"; // Frankfurt 🇩🇪
const TZ = "Asia/Riyadh";      // your local timezone for schedules

/**
 * Bid arbitration: accept/reject pending bids atomically.
 */
exports.onBidCreated = functions
  .region(REGION)
  .firestore.document("lots/{lotId}/bids/{bidId}")
  .onCreate(async (snap, context) => {
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

        // Lifecycle checks
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

        if (typeof bid.amount !== "number" || bid.amount < currentHighest + minInc) {
          tx.update(bidRef, { status: "rejected", reason: "LOW_BID" });
          return;
        }

        // First bid must meet reserve (if present)
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

/**
 * Scheduler: open lots whose startTime has passed (pending -> live).
 * Runs every minute in Riyadh time.
 */
exports.autoOpenLots = functions
  .region(REGION)
  .pubsub.schedule("every 1 minutes")
  .timeZone(TZ)
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    const batchSize = 300; // safety cap per run
    const q = db
      .collection("lots")
      .where("state", "==", "pending")
      .where("startTime", "<=", now)
      .limit(batchSize);

    const snap = await q.get();
    if (snap.empty) return null;

    const batch = db.batch();
    snap.docs.forEach((doc) => {
      batch.update(doc.ref, {
        state: "live",
        updatedAt: now,
      });
    });

    await batch.commit();
    console.log(`autoOpenLots: opened ${snap.size} lots`);
    return null;
  });

/**
 * Scheduler: close lots whose endTime has passed (live -> closed).
 * Runs every minute in Riyadh time.
 */
exports.autoCloseLots = functions
  .region(REGION)
  .pubsub.schedule("every 1 minutes")
  .timeZone(TZ)
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    const batchSize = 300;
    const q = db
      .collection("lots")
      .where("state", "==", "live")
      .where("endTime", "<=", now)
      .limit(batchSize);

    const snap = await q.get();
    if (snap.empty) return null;

    const batch = db.batch();
    snap.docs.forEach((doc) => {
      batch.update(doc.ref, {
        state: "closed",
        updatedAt: now,
      });
    });

    await batch.commit();
    console.log(`autoCloseLots: closed ${snap.size} lots`);
    return null;
  });

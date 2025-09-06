import { onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import admin from "firebase-admin";

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

export const placeBid = onCall(
  { region: "us-central1", enforceAppCheck: false },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new Error("UNAUTHENTICATED: Sign-in required.");

    const { lotId, amount } = request.data || {};
    if (!lotId || typeof lotId !== "string")
      throw new Error("INVALID_ARGUMENT: lotId required.");
    if (typeof amount !== "number" || !isFinite(amount) || amount <= 0)
      throw new Error("INVALID_ARGUMENT: amount must be a positive number.");

    const DEFAULT_MIN_INCREMENT = 50;

    const lotRef = db.collection("lots").doc(lotId);
    const bidsCol = lotRef.collection("bids");

    return await db.runTransaction(async (tx) => {
      const lotSnap = await tx.get(lotRef);
      if (!lotSnap.exists) throw new Error("NOT_FOUND: Lot does not exist.");
      const lot = lotSnap.data() || {};
      const startingPrice = Number(lot.startingPrice) || 0;
      const minIncrement =
        typeof lot.minIncrement === "number" && lot.minIncrement > 0
          ? lot.minIncrement
          : DEFAULT_MIN_INCREMENT;

      const topSnap = await tx.get(bidsCol.orderBy("amount", "desc").limit(1));
      const highest = topSnap.empty ? 0 : Number(topSnap.docs[0].data().amount) || 0;

      const minRequired = highest > 0 ? highest + minIncrement : startingPrice;
      if (amount < minRequired) {
        throw new Error(
          highest > 0
            ? `BID_TOO_LOW: Must be ≥ ${minRequired} (highest ${highest} + step ${minIncrement}).`
            : `BID_TOO_LOW: First bid must be ≥ starting price ${startingPrice}.`
        );
      }

      const bidRef = bidsCol.doc();
      tx.set(bidRef, {
        amount,
        bidderId: uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info("Bid placed", { lotId, amount, uid });
      return { ok: true, amount, minIncrement, highest, startingPrice };
    });
  }
);

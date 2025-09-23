"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.placeBid = void 0;
// functions/src/placeBid.ts
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("./firebase");
function firstPositive(...vals) {
    for (const v of vals) {
        const n = Number(v);
        if (Number.isFinite(n) && n > 0)
            return n;
    }
    return undefined;
}
async function resolveIncrement(lot, tx) {
    // Prefer lot setting; accept multiple field names
    const lotInc = firstPositive(lot?.minIncrement, lot?.customIncrement, lot?.bidIncrement, lot?.step);
    if (lotInc)
        return lotInc;
    // Fallback to exhibitor setting (also accept multiple names)
    const exhibitorId = lot?.exhibitorId;
    if (exhibitorId) {
        const exRef = firebase_1.db.collection("exhibitors").doc(exhibitorId);
        const exSnap = await tx.get(exRef);
        if (exSnap.exists) {
            const ex = exSnap.data();
            const exInc = firstPositive(ex?.minIncrement, ex?.customIncrement, ex?.bidIncrement, ex?.step);
            if (exInc)
                return exInc;
        }
    }
    // Final fallback
    return 100;
}
/** The real async handler (returns a Promise<PlaceBidRes>). */
async function placeBidHandler(req) {
    const lotId = req.data?.lotId;
    const bidAmount = Number(req.data?.bidAmount);
    const uid = req.auth?.uid ?? "guest-web";
    if (!lotId || !Number.isFinite(bidAmount)) {
        throw new https_1.HttpsError("invalid-argument", "lotId and numeric bidAmount are required");
    }
    return firebase_1.db.runTransaction(async (tx) => {
        const lotRef = firebase_1.db.collection("lots").doc(lotId);
        const lotSnap = await tx.get(lotRef);
        if (!lotSnap.exists)
            throw new https_1.HttpsError("not-found", "Lot not found");
        const lot = lotSnap.data();
        if (lot.status !== "live") {
            return { ok: false, reason: "Lot is not live" };
        }
        const increment = await resolveIncrement(lot, tx);
        // Determine current high from lot summary, then double-check top bid doc
        let current = firstPositive(lot?.lastBidAmount, lot?.startPrice, lot?.startingBid) ?? 0;
        const top = await tx.get(lotRef.collection("bids").orderBy("amount", "desc").limit(1));
        if (!top.empty) {
            const topAmount = Number(top.docs[0].get("amount") || 0);
            if (Number.isFinite(topAmount))
                current = Math.max(current, topAmount);
        }
        // Minimum allowed = max(lot.nextBid, current + step)
        const minAllowed = Math.max(Number(lot?.nextBid || 0), current + increment);
        if (bidAmount < minAllowed) {
            return {
                ok: false,
                reason: "Bid below minimum step",
                minAllowed,
                current,
                usedIncrement: increment,
            };
        }
        // Write bid
        const bidRef = lotRef.collection("bids").doc();
        tx.set(bidRef, {
            lotId,
            amount: bidAmount,
            bidderUid: uid,
            createdAt: firestore_1.FieldValue.serverTimestamp(),
            status: "placed",
            source: "callable",
        });
        // Update lot summary and next required bid
        const nextMin = bidAmount + increment;
        tx.update(lotRef, {
            lastBidAmount: bidAmount,
            lastBidAt: firestore_1.FieldValue.serverTimestamp(),
            lastBidderUid: uid,
            updatedAt: firestore_1.FieldValue.serverTimestamp(),
            nextBid: nextMin,
            minIncrement: increment, // keep effective step visible
        });
        return { ok: true, current: bidAmount, nextMin, usedIncrement: increment };
    });
}
/**
 * Exported callable.
 * NOTE: we cast the async handler so it satisfies your local typings,
 * which (in your env) expect a non-Promise return type.
 */
exports.placeBid = (0, https_1.onCall)({ region: "me-central1" }, (req) => placeBidHandler(req));
//# sourceMappingURL=placeBid.js.map
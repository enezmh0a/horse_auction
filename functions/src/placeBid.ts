// functions/src/placeBid.ts
import { onCall, HttpsError, type CallableRequest } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "./firebase";

type PlaceBidReq = { lotId: string; bidAmount: number };
type PlaceBidRes = {
  ok: boolean;
  reason?: string;
  current?: number;
  minAllowed?: number;
  usedIncrement?: number;
  nextMin?: number;
};

function firstPositive(...vals: unknown[]): number | undefined {
  for (const v of vals) {
    const n = Number(v);
    if (Number.isFinite(n) && n > 0) return n;
  }
  return undefined;
}

async function resolveIncrement(
  lot: FirebaseFirestore.DocumentData | undefined,
  tx: FirebaseFirestore.Transaction
): Promise<number> {
  // Prefer lot setting; accept multiple field names
  const lotInc = firstPositive(
    lot?.minIncrement,
    lot?.customIncrement,
    lot?.bidIncrement,
    lot?.step
  );
  if (lotInc) return lotInc;

  // Fallback to exhibitor setting (also accept multiple names)
  const exhibitorId = lot?.exhibitorId as string | undefined;
  if (exhibitorId) {
    const exRef = db.collection("exhibitors").doc(exhibitorId);
    const exSnap = await tx.get(exRef);
    if (exSnap.exists) {
      const ex = exSnap.data();
      const exInc = firstPositive(
        ex?.minIncrement,
        ex?.customIncrement,
        ex?.bidIncrement,
        ex?.step
      );
      if (exInc) return exInc;
    }
  }

  // Final fallback
  return 100;
}

/** The real async handler (returns a Promise<PlaceBidRes>). */
async function placeBidHandler(req: CallableRequest<PlaceBidReq>): Promise<PlaceBidRes> {
  const lotId = req.data?.lotId;
  const bidAmount = Number(req.data?.bidAmount);
  const uid = req.auth?.uid ?? "guest-web";

  if (!lotId || !Number.isFinite(bidAmount)) {
    throw new HttpsError("invalid-argument", "lotId and numeric bidAmount are required");
  }

  return db.runTransaction<PlaceBidRes>(async (tx) => {
    const lotRef = db.collection("lots").doc(lotId);
    const lotSnap = await tx.get(lotRef);
    if (!lotSnap.exists) throw new HttpsError("not-found", "Lot not found");

    const lot = lotSnap.data() as {
      status?: string;
      startPrice?: number;
      startingBid?: number;
      lastBidAmount?: number;
      nextBid?: number;
      exhibitorId?: string;
      minIncrement?: number;
      customIncrement?: number;
    };

    if (lot.status !== "live") {
      return { ok: false, reason: "Lot is not live" };
    }

    const increment = await resolveIncrement(lot, tx);

    // Determine current high from lot summary, then double-check top bid doc
    let current = firstPositive(lot?.lastBidAmount, lot?.startPrice, lot?.startingBid) ?? 0;

    const top = await tx.get(
      lotRef.collection("bids").orderBy("amount", "desc").limit(1)
    );
    if (!top.empty) {
      const topAmount = Number(top.docs[0].get("amount") || 0);
      if (Number.isFinite(topAmount)) current = Math.max(current, topAmount);
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
      createdAt: FieldValue.serverTimestamp(),
      status: "placed",
      source: "callable",
    });

    // Update lot summary and next required bid
    const nextMin = bidAmount + increment;
    tx.update(lotRef, {
      lastBidAmount: bidAmount,
      lastBidAt: FieldValue.serverTimestamp(),
      lastBidderUid: uid,
      updatedAt: FieldValue.serverTimestamp(),
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
export const placeBid = onCall<PlaceBidReq, PlaceBidRes>(
  { region: "me-central1" },
  (req) => placeBidHandler(req) as unknown as PlaceBidRes
);

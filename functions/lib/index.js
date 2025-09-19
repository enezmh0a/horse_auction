"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.rejectBid = exports.acceptBid = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
if (!admin.apps.length)
    admin.initializeApp();
const db = admin.firestore();
// Reject other bids still pending (no status or "pending")
async function rejectOtherPendingBids(lotId, acceptedBidId) {
    const bidsRef = db.collection("lots").doc(lotId).collection("bids");
    const snap = await bidsRef.get();
    const batch = db.batch();
    snap.forEach((doc) => {
        if (doc.id !== acceptedBidId) {
            const b = doc.data() || {};
            const isPending = !b.status || b.status === "pending";
            if (isPending)
                batch.update(doc.ref, { status: "rejected" });
        }
    });
    await batch.commit();
}
function assertId(name, v) {
    if (!v || typeof v !== "string" || /[\/\\]/.test(v)) {
        throw new https_1.HttpsError("invalid-argument", `${name} must be a document ID (no slashes).`);
    }
}
/** acceptBid (admin only) */
exports.acceptBid = (0, https_1.onCall)({ region: "me-central1" }, async (request) => {
    const auth = request.auth;
    if (!auth)
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    if (!auth.token?.admin)
        throw new https_1.HttpsError("permission-denied", "Admin only.");
    const { lotId, bidId } = (request.data || {});
    assertId("lotId", lotId);
    assertId("bidId", bidId);
    const uid = auth.uid;
    try {
        const lotRef = db.collection("lots").doc(lotId);
        const bidRef = lotRef.collection("bids").doc(bidId);
        await db.runTransaction(async (tx) => {
            const [lotSnap, bidSnap] = await Promise.all([tx.get(lotRef), tx.get(bidRef)]);
            if (!lotSnap.exists)
                throw new https_1.HttpsError("not-found", "Lot not found.");
            if (!bidSnap.exists)
                throw new https_1.HttpsError("not-found", "Bid not found.");
            const bid = bidSnap.data() || {};
            const amount = Number(bid.amount);
            if (!Number.isFinite(amount)) {
                throw new https_1.HttpsError("failed-precondition", "Bid amount missing/invalid.");
            }
            const status = bid.status ?? "pending";
            if (status !== "pending") {
                throw new https_1.HttpsError("failed-precondition", `Bid is ${status}, not pending.`);
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
        await rejectOtherPendingBids(lotId, bidId);
        return { ok: true };
    }
    catch (e) {
        console.error("acceptBid failed", { lotId, bidId, err: e?.message, stack: e?.stack });
        if (e instanceof https_1.HttpsError)
            throw e;
        throw new https_1.HttpsError("internal", e?.message || "acceptBid failed");
    }
});
/** rejectBid (admin only) */
exports.rejectBid = (0, https_1.onCall)({ region: "me-central1" }, async (request) => {
    const auth = request.auth;
    if (!auth)
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    if (!auth.token?.admin)
        throw new https_1.HttpsError("permission-denied", "Admin only.");
    const { lotId, bidId } = (request.data || {});
    assertId("lotId", lotId);
    assertId("bidId", bidId);
    const uid = auth.uid;
    try {
        const bidRef = db.collection("lots").doc(lotId).collection("bids").doc(bidId);
        const snap = await bidRef.get();
        if (!snap.exists)
            throw new https_1.HttpsError("not-found", "Bid not found.");
        await bidRef.update({
            status: "rejected",
            approvedBy: uid,
            approvedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { ok: true };
    }
    catch (e) {
        console.error("rejectBid failed", { lotId, bidId, err: e?.message, stack: e?.stack });
        if (e instanceof https_1.HttpsError)
            throw e;
        throw new https_1.HttpsError("internal", e?.message || "rejectBid failed");
    }
});
//# sourceMappingURL=index.js.map
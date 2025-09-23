"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onLotWriteSetTier = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const firebase_1 = require("./firebase");
/**
 * Firestore trigger must run where your Firestore DB lives.
 * Your DB location is me-central2, so we set region to me-central2 here.
 */
exports.onLotWriteSetTier = (0, firestore_1.onDocumentWritten)({
    document: "lots/{lotId}",
    region: "me-central2", // <-- important: matches Firestore DB
}, async (event) => {
    const after = event.data?.after?.data();
    if (!after)
        return;
    const lotId = event.params.lotId;
    const current = after.currentHighest ?? after.startingPrice ?? 0;
    let tier = "low";
    if (current >= 50000)
        tier = "high";
    else if (current >= 20000)
        tier = "mid";
    await firebase_1.db.collection("lots").doc(lotId).set({ tier }, { merge: true });
});
//# sourceMappingURL=tiering.js.map
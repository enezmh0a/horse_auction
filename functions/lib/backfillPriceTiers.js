"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.backfillPriceTiers = void 0;
const https_1 = require("firebase-functions/v2/https");
const firebase_1 = require("./firebase");
// reuse the same thresholds as placeBid
function tierFor(amount) {
    if (amount >= 50000)
        return "high";
    if (amount >= 20000)
        return "mid";
    return "low";
}
exports.backfillPriceTiers = (0, https_1.onCall)(async (req) => {
    if (!req.auth?.token?.admin)
        throw new https_1.HttpsError("permission-denied", "Admin only");
    const snap = await firebase_1.db.collection("lots").get();
    const batch = firebase_1.db.batch();
    let count = 0;
    snap.forEach((doc) => {
        const d = doc.data();
        const current = d.currentHighest ?? d.startingPrice ?? 0;
        const t = tierFor(current);
        batch.update(doc.ref, { tier: t });
        count++;
    });
    await batch.commit();
    return { ok: true, updated: count };
});
//# sourceMappingURL=backfillPriceTiers.js.map
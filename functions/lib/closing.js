"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.closeExpiredLotsNow = void 0;
// functions/src/closing.ts
const https_1 = require("firebase-functions/v2/https");
const firebase_1 = require("./firebase"); // your admin Firestore instance
exports.closeExpiredLotsNow = (0, https_1.onCall)({ region: "me-central1" }, async (req) => {
    if (!req.auth?.token?.admin) {
        throw new https_1.HttpsError("permission-denied", "Admin only");
    }
    const now = new Date();
    const snap = await firebase_1.db
        .collection("lots")
        .where("status", "==", "live")
        .where("closeAt", "<=", now)
        .get();
    const batch = firebase_1.db.batch();
    snap.docs.forEach((doc) => {
        batch.update(doc.ref, { status: "closed", closedAt: now });
    });
    if (!snap.empty) {
        await batch.commit();
    }
    return { closedCount: snap.size };
});
//# sourceMappingURL=closing.js.map
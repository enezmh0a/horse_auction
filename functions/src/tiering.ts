import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { db } from "./firebase";

/**
 * Firestore trigger must run where your Firestore DB lives.
 * Your DB location is me-central2, so we set region to me-central2 here.
 */
export const onLotWriteSetTier = onDocumentWritten(
  {
    document: "lots/{lotId}",
    region: "me-central2", // <-- important: matches Firestore DB
  },
  async (event) => {
    const after = event.data?.after?.data() as any | undefined;
    if (!after) return;

    const lotId = event.params.lotId as string;
    const current = after.currentHighest ?? after.startingPrice ?? 0;

    let tier = "low";
    if (current >= 50000) tier = "high";
    else if (current >= 20000) tier = "mid";

    await db.collection("lots").doc(lotId).set({ tier }, { merge: true });
  }
);

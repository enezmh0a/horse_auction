// functions/scripts/setAdminClaim.js
const path = require("path");
const { initializeApp, cert } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

const serviceAccount = require(path.join(__dirname, "..", "serviceAccount.json"));

initializeApp({
  credential: cert(serviceAccount),
  projectId: "horse-auction-saudi",
});

(async () => {
  const uid = process.argv[2];
  const enable = (process.argv[3] ?? "true").toLowerCase() === "true";

  if (!uid) {
    console.error("Usage: node scripts/setAdminClaim.js <UID> [true|false]");
    process.exit(1);
  }

  await getAuth().setCustomUserClaims(uid, { admin: enable });
  console.log(`✅ set admin=${enable} for UID=${uid}`);
})();

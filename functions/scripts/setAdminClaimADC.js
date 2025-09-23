// functions/scripts/setAdminClaimADC.js
const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

// Use your user credentials (ADC) for this project
initializeApp({
  credential: applicationDefault(),
  projectId: "horse-auction-saudi",
});

(async () => {
  const uid = process.argv[2];
  const enable = (process.argv[3] ?? "true").toLowerCase() === "true";
  if (!uid) {
    console.error("Usage: node scripts/setAdminClaimADC.js <UID> [true|false]");
    process.exit(1);
  }

  await getAuth().setCustomUserClaims(uid, { admin: enable });
  console.log(`✅ set admin=${enable} for UID=${uid}`);
})();

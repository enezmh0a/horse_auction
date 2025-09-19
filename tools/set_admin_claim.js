const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

// Uses your local Google login via gcloud (ADC)
initializeApp({ credential: applicationDefault() });

(async () => {
  const uid = process.argv[2];
  if (!uid) {
    console.error("Usage: node set_admin_claim.js <UID>");
    process.exit(1);
  }
  await getAuth().setCustomUserClaims(uid, { admin: true });
  console.log("Admin set on", uid);
})();

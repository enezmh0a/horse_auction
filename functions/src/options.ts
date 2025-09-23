// functions/src/options.ts
import { setGlobalOptions } from "firebase-functions/v2/options";

// ONE call only. No region here; defaultRegion is set in firebase.json to me-central1.
setGlobalOptions({
  // timeoutSeconds: 60,
  // memory: "256MiB",
});

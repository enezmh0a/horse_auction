"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// functions/src/options.ts
const options_1 = require("firebase-functions/v2/options");
// ONE call only. No region here; defaultRegion is set in firebase.json to me-central1.
(0, options_1.setGlobalOptions)({
// timeoutSeconds: 60,
// memory: "256MiB",
});
//# sourceMappingURL=options.js.map
// * Package Imports
import { Auth } from "@vonage/auth";
import { Vonage } from "@vonage/server-sdk";

// * Configure Vonage auth object
const vonageAuth = new Auth({
  apiKey: process.env.VONAGE_API_KEY,
  apiSecret: process.env.VONAGE_API_SECRET,
  applicationId: process.env.VONAGE_APPLICATION_ID,
  privateKey: "private.key",
});

const vonage = new Vonage(vonageAuth);

export default vonage;

import cron from "node-cron";
import AliveModel from "./db/models/alive.model";
import vonage from "./helpers/vonage.helper";

const findOfflineConnections = async () => {
  try {
    console.log("Checking for offline devices...");
    const oneMinuteAgoTimestamp = new Date(Date.now() - 60000);
    const results = await AliveModel.find({
      lastPinged: { $lt: oneMinuteAgoTimestamp },
      activated: true,
    });
    if (results.length) {
      console.log(`📵 Service has gone offline: ${results[0].aliveToken}`);

      if (!process.env.TO_NUMBER || !process.env.VONAGE_FROM_NUMBER) {
        console.log("Incorrect vonage configuration");
        return;
      }
      // * Trigger Vonage call to send SMS.
      vonage.sms.send({
        to: process.env.TO_NUMBER,
        from: process.env.VONAGE_FROM_NUMBER,
        text: `Device has gone offline: ${results[0]._id}`,
      });

      // * Deactivate device
      await AliveModel.findOneAndUpdate(
        { aliveToken: results[0].aliveToken },
        { $set: { activated: false } }
      );
    }
    console.log("Successfully checked for offline connections");
  } catch (err: any) {
    console.log(
      `An error occurred while checking offline connections: ${err.message}`
    );
  }
};

findOfflineConnections();
cron.schedule("* * * * *", () => findOfflineConnections()).start();

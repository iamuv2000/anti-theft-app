import { Request, Response } from "express";
import AliveModel from "../db/models/alive.model";
import vonage from "../helpers/vonage.helper";

export const alive = async (req: Request, res: Response) => {
  try {
    // * Validation
    const { authorization: aliveToken } = req.headers;
    if (aliveToken != process.env.KEEP_ALIVE_TOKEN || !aliveToken) {
      console.log(`Faulty auth token provided: ${aliveToken}`);
      return res.status(500).send({
        msg: "Internal server error",
      });
    }

    // * Update the lastPinged field
    await AliveModel.findOneAndUpdate(
      {
        aliveToken,
      },
      {
        $set: { lastPinged: new Date() },
      },
      { new: true, upsert: true }
    );

    return res.status(200).send({
      message: "Successfully updated alive timestamp",
    });
  } catch (err: any) {
    console.log(`An error occurred while updating alive route: ${err.message}`);
    return res.status(500).send({
      message: "Internal Server Error",
    });
  }
};

// * Fetch activated state
export const getActivatedState = async (req: Request, res: Response) => {
  try {
    // * Validation
    const { authorization: aliveToken } = req.headers;
    if (aliveToken !== process.env.KEEP_ALIVE_TOKEN || !aliveToken) {
      console.log(`Faulty auth token provided: ${aliveToken}`);
      return res.status(500).send({
        msg: "Internal server error",
      });
    }

    // * Find active state
    const result = await AliveModel.findOne({ aliveToken }, { activated: 1 });

    return res.status(200).send({
      msg: "Successfully fetched device activate state",
      data: result,
    });
  } catch (err: any) {
    console.log(
      `An error occurred while finding device activation state: ${err.message}`
    );
    return res.status(500).send({
      msg: "Internal server error",
    });
  }
};

export const updateActivatedState = async (req: Request, res: Response) => {
  try {
    // * Validation
    const { activated } = req.body;
    const { authorization: aliveToken } = req.headers;
    if (aliveToken !== process.env.KEEP_ALIVE_TOKEN || !aliveToken) {
      console.log(`Faulty auth token provided: ${aliveToken}`);
      return res.status(500).send({
        msg: "Internal server error",
      });
    }
    if (activated === undefined) {
      console.log(`No activation intent provided.`);
      return res.status(400).send({
        msg: "Please set an activation state",
      });
    }

    // * Update active state
    await AliveModel.findOneAndUpdate(
      { aliveToken },
      { $set: { lastPinged: new Date(), activated: activated } },
      { new: true, upsert: true }
    );

    return res.status(200).send({
      msg: "Successfully updated device activate state",
    });
  } catch (err: any) {
    console.log(
      `An error occurred while updating device activation state: ${err.message}`
    );
    return res.status(500).send({
      msg: "Internal server error",
    });
  }
};

export const movementDetected = async (req: Request, res: Response) => {
  try {
    const { authorization: aliveToken } = req.headers;
    if (aliveToken !== process.env.KEEP_ALIVE_TOKEN || !aliveToken) {
      console.log(`Faulty auth token provided: ${aliveToken}`);
      return res.status(500).send({
        msg: "Internal server error",
      });
    }

    // * Fetch only active device with the alive token
    const triggeredDevice = await AliveModel.findOne({
      aliveToken: aliveToken,
      activated: true,
    });
    if (!triggeredDevice) {
      return res.status(404).send({
        msg: "Device is offline",
      });
    }

    // * Trigger call from vonage
    if (!process.env.TO_NUMBER || !process.env.VONAGE_FROM_NUMBER) {
      console.log("Incorrect vonage configuration");
      return res.status(500).send({
        msg: "Alerts have not been configured",
      });
    }

    const response = await vonage.voice.createOutboundCall({
      to: [
        {
          type: "phone",
          number: process.env.TO_NUMBER,
        },
      ],
      from: {
        type: "phone",
        number: process.env.VONAGE_FROM_NUMBER,
      },
      ncco: [
        {
          action: "talk" as any,
          text: "ALERT! ALERT! ALERT! Please note movement has been detected for your device",
        },
      ],
    });

    console.log("Outbound Vonage call -->");
    console.log(response);

    // * Deactivate device
    await AliveModel.findOneAndUpdate(
      { aliveToken: aliveToken },
      { $set: { lastPinged: new Date(), activated: false } }
    );

    return res.status(200).send({
      msg: "Successfully triggered call",
    });
  } catch (err: any) {
    console.log(
      `An error occurred while processing movement detected: ${err.message}`
    );
    console.log(err?.response);
    return res.status(500).send({
      msg: "Internal server error",
    });
  }
};

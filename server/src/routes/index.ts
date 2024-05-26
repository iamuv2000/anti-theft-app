import express from "express";
import {
  alive,
  getActivatedState,
  movementDetected,
  updateActivatedState,
} from "../controllers";

const router = express.Router();

router.post("/alive", alive);

router.get("/device", getActivatedState);
router.put("/device", updateActivatedState);

router.post("/movement-detected", movementDetected);

export default router;

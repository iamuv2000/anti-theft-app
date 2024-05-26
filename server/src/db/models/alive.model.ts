import mongoose from "mongoose";

const Alive = new mongoose.Schema({
  aliveToken: {
    type: String,
    required: true,
  },
  lastPinged: {
    type: Date,
    required: true,
  },
  activated: {
    type: Boolean,
    default: false,
    required: true,
  },
});

const AliveModel = mongoose.model("alive", Alive);
export default AliveModel;

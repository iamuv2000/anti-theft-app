import dotenv from "dotenv";
dotenv.config();
import "./db/mongoose";
import app from "./app";
import "./cron";

const PORT = process.env.PORT;

app.listen(PORT, () => console.log(`🚀 Server is up at ${PORT}`));

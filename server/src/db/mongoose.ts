import mongoose from "mongoose";

// * Config
mongoose.set("strictQuery", true);

if (!process.env.MONGODB_URI) throw Error("MONGODB_URI is not provided");

mongoose.connect(process.env.MONGODB_URI);

mongoose.connection.on("open", () => {
  console.log(`🚀 Connection to database successful`);
});

mongoose.connection.on("error", (err: Error) => {
  console.log(`An error occurred while connecting to DB: ${err.message}`);
});

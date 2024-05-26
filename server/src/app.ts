import express, { Application, Request, Response } from "express";
import cors from "cors";
import bodyParser from "body-parser";
import morgan from "morgan";

// * Routes
import routes from "./routes";

// * Configure express
const app: Application = express();
app.use(
  cors({
    origin: "*",
  })
);
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.json());
app.use(
  morgan(
    "[:date[clf]] :method :url :status :res[content-length] - :response-time ms"
  )
);
app.use("/api", routes);

// * Root route
app.get("/", (req: Request, res: Response) => {
  return res.status(200).send({
    msg: "Movement API is up and running",
  });
});

export default app;

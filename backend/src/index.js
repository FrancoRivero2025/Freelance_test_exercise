import express from "express";
import cors from "cors";
import employeesRouter from "./routes/employeeRoutes.js";

const app = express();
const PORT = process.env.PORT || 3000;

const corsOptions = {
  origin: process.env.FRONTEND_URL || "http://localhost:4000",
  methods: "GET,POST,PUT,DELETE",
  allowedHeaders: ["Content-Type"],
};
app.use(cors(corsOptions));
app.use(express.json());

// Routes
app.use("/employees", employeesRouter);

app.get("/", (req, res) => {
  res.send("Employee API up and running");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

import "dotenv/config";
import express from "express";
import cors from "cors";
import swaggerUi from "swagger-ui-express";
import { createRequire } from "module";

import connectDB from "./config/db.js";
import authRoutes from "./routes/authRoutes.js";
import categoryRoutes from "./routes/categoryRoutes.js";
import transactionRoutes from "./routes/transactionRoutes.js";
import budgetRoutes from "./routes/budgetRoutes.js";
import financialProfileRoutes from "./routes/financialProfileRoutes.js";
import seedRoutes from "./routes/seedRoutes.js";
import aiRoutes from "./routes/aiRoutes.js";

const require = createRequire(import.meta.url);
const swaggerDocument = require("./swagger.json");

const app = express();

connectDB();

app.use(cors({ origin: "*" }));
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/transactions", transactionRoutes);
app.use("/api/budgets", budgetRoutes);
app.use("/api/financial-profile", financialProfileRoutes);
app.use("/api/seed", seedRoutes);
app.use("/api/ai", aiRoutes);

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "🚀 Mony API opérationnelle",
    docs: "/api-docs",
  });
});

app.use((req, res) => {
  res.status(404).json({ success: false, message: "Route introuvable." });
});

app.use((err, req, res, next) => {
  console.error("❌ Erreur globale :", err.message);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || "Erreur interne du serveur.",
  });
});

if (process.env.NODE_ENV !== "production") {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
    console.log(`📄 Docs Swagger : http://localhost:${PORT}/api-docs`);
  });
}

export default app;

import { Router } from "express";
import {
  getTransactions,
  createTransaction,
  updateTransaction,
  deleteTransaction,
  getStats,
} from "../controllers/transactionController.js";
import verifyToken from "../middlewares/auth.js";

const router = Router();

router.use(verifyToken);

router.get("/stats", getStats);
router.get("/", getTransactions);
router.post("/", createTransaction);
router.put("/:id", updateTransaction);
router.delete("/:id", deleteTransaction);

export default router;

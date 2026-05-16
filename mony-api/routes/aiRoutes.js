import { Router } from "express";
import { chat, getChatHistory, getAIAnalysis } from "../controllers/aiController.js";
import verifyToken from "../middlewares/auth.js";

const router = Router();

router.use(verifyToken);

router.post("/chat", chat);
router.get("/history", getChatHistory);
router.get("/analyze", getAIAnalysis);

export default router;

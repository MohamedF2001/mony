import { Router } from "express";
import { seedQuestions } from "../controllers/seedController.js";
import verifyToken from "../middlewares/auth.js";

const router = Router();

// Route protégée pour éviter que n'importe qui puisse réinitialiser les questions
router.post("/questions", verifyToken, seedQuestions);

export default router;

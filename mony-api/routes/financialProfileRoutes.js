import { Router } from "express";
import {
  getQuestions,
  calculateAndSaveProfile,
  getMyProfile,
} from "../controllers/financialProfileController.js";
import verifyToken from "../middlewares/auth.js";

const router = Router();

router.use(verifyToken);

router.get("/questions", getQuestions);
router.post("/calculate", calculateAndSaveProfile);
router.get("/", getMyProfile);

export default router;

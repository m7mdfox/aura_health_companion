import express from "express";
import { submitOnboarding, getOnboarding } from "../controllers/nutrition_controller.js";
import authMiddleware from "../middlewares/auth_middleware.js";

const router = express.Router();

router.post("/onboarding", authMiddleware, submitOnboarding);
router.get("/onboarding", authMiddleware, getOnboarding);

export default router;

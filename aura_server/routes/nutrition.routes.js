// routes/nutrition.routes.js - COMPLETE VERSION
import express from "express";
import { 
  submitOnboarding, 
  getOnboarding, 
  getCompleteNutritionData,
  generatePlan,
  getSavedPlan,
  deletePlan,
  suggestMealEndpoint,
  askNutritionist,
  logDailyProgress,
  getProgressHistory
} from "../controllers/nutrition_controller.js";
import authMiddleware from "../middlewares/auth_middleware.js";

const router = express.Router();

console.log('📝 Loading nutrition routes...');

// ==================== EXISTING ROUTES ====================
router.post("/onboarding", authMiddleware, submitOnboarding);
router.get("/onboarding", authMiddleware, getOnboarding);
router.get("/complete-data", authMiddleware, getCompleteNutritionData);
router.post("/generate-plan", authMiddleware, generatePlan);
router.get("/saved-plan", authMiddleware, getSavedPlan);
router.delete("/delete-plan", authMiddleware, deletePlan);

// ==================== 🆕 NEW ROUTES ====================
router.post("/suggest-meal", authMiddleware, suggestMealEndpoint);
router.post("/ask-nutritionist", authMiddleware, askNutritionist);  // 🔥 هنا الـ route
router.post("/log-progress", authMiddleware, logDailyProgress);
router.get("/progress-history", authMiddleware, getProgressHistory);

console.log('✅ Nutrition routes loaded successfully');
console.log('📋 Available routes:');
console.log('   - POST /onboarding');
console.log('   - GET /onboarding');
console.log('   - GET /complete-data');
console.log('   - POST /generate-plan');
console.log('   - GET /saved-plan');
console.log('   - DELETE /delete-plan');
console.log('   - POST /suggest-meal');
console.log('   - POST /ask-nutritionist  🔥');
console.log('   - POST /log-progress');
console.log('   - GET /progress-history');

export default router;
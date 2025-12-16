// controllers/nutrition_controller.js (UPDATED WITH NEW FEATURES)
import NutritionProfile from "../models/nutritionProfile.js";
import SavedNutritionPlan from "../models/savedNutritionPlan.js";
import Profile from "../models/profile.js";
import DailyProgress from "../models/dailyProgress.js";
import { generateNutritionPlan, suggestMeal, answerNutritionQuestion } from "../utils/geminiNutrition.js";

// ==================== Submit Onboarding ====================
export const submitOnboarding = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const { 
      lifestyle, 
      eating_relation, 
      meal_times, 
      improvement_goal,
      goal_type,
      diet_type,
      if_schedule,
      activity_level,
      chronic_diseases
    } = req.body;

    const mealTimesVal = Array.isArray(meal_times) ? meal_times : [];
    const chronicDiseasesVal = Array.isArray(chronic_diseases) ? chronic_diseases : [];

    const doc = await NutritionProfile.findOneAndUpdate(
      { userAuthId: user.auth_id },
      {
        userAuthId: user.auth_id,
        lifestyle: lifestyle || "",
        eatingRelation: eating_relation || "",
        mealTimes: mealTimesVal,
        improvementGoal: improvement_goal || "",
        goalType: goal_type || "",
        dietType: diet_type || "",
        ifSchedule: if_schedule || "",
        activityLevel: activity_level || "",
        chronicDiseases: chronicDiseasesVal,
        updatedAt: new Date()
      },
      { upsert: true, new: true }
    );

    console.log("✅ Onboarding saved for user:", user.auth_id);
    return res.status(200).json({ message: "Onboarding saved", profile: doc });
  } catch (e) {
    console.error("❌ submitOnboarding error:", e);
    res.status(500).json({ error: "Failed to save onboarding" });
  }
};

// ==================== Get Onboarding ====================
export const getOnboarding = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) return res.status(401).json({ error: "Unauthorized" });

    const doc = await NutritionProfile.findOne({ userAuthId: user.auth_id });
    
    if (!doc) return res.status(404).json({ error: "Not found" });
    
    return res.json({ profile: doc });
  } catch (e) {
    console.error("❌ getOnboarding error:", e);
    res.status(500).json({ error: "Failed to fetch onboarding" });
  }
};

// ==================== Get Complete Nutrition Data ====================
export const getCompleteNutritionData = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) return res.status(401).json({ error: "Unauthorized" });

    const profile = await Profile.findOne({ auth_id: user.auth_id });
    if (!profile) return res.status(404).json({ error: "Profile not found" });

    const nutritionProfile = await NutritionProfile.findOne({ userAuthId: user.auth_id });
    const savedPlan = await SavedNutritionPlan.findOne({ userAuthId: user.auth_id });

    let age = null;
    if (profile.birthdate) {
      const birthDate = new Date(profile.birthdate);
      const today = new Date();
      age = today.getFullYear() - birthDate.getFullYear();
      const monthDiff = today.getMonth() - birthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
    }

    const completeData = {
      fullName: profile.full_name,
      email: profile.email,
      gender: profile.gender,
      age: age,
      heightCm: profile.height_cm,
      weightKg: profile.weight_kg,
      chronicConditions: profile.chronic_conditions || [],
      activityLevel: profile.activity_level || "sedentary",
      
      lifestyle: nutritionProfile?.lifestyle || "",
      eatingRelation: nutritionProfile?.eatingRelation || "",
      mealTimes: nutritionProfile?.mealTimes || [],
      improvementGoal: nutritionProfile?.improvementGoal || "",
      goalType: nutritionProfile?.goalType || "",
      dietType: nutritionProfile?.dietType || "",
      ifSchedule: nutritionProfile?.ifSchedule || "",
      
      planGenerated: savedPlan ? true : false,
      tdee: savedPlan?.tdee || 0,
      targetCalories: savedPlan?.targetCalories || 0,
    };

    return res.json({ data: completeData });
  } catch (e) {
    console.error("❌ getCompleteNutritionData error:", e);
    res.status(500).json({ error: "Failed to fetch data" });
  }
};

// ==================== Generate Nutrition Plan ====================
export const generatePlan = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) {
      console.log("❌ No user auth_id");
      return res.status(401).json({ error: "Unauthorized" });
    }

    console.log("🔄 Generating plan for user:", user.auth_id);

    const profile = await Profile.findOne({ auth_id: user.auth_id });
    if (!profile) {
      console.log("❌ Profile not found");
      return res.status(404).json({ error: "Profile not found" });
    }

    const nutritionProfile = await NutritionProfile.findOne({ userAuthId: user.auth_id });
    if (!nutritionProfile) {
      console.log("❌ Nutrition profile not found");
      return res.status(404).json({ error: "Please complete onboarding first" });
    }

    console.log("✅ Found profiles, calculating age...");

    let age = 25;
    if (profile.birthdate) {
      const birthDate = new Date(profile.birthdate);
      const today = new Date();
      age = today.getFullYear() - birthDate.getFullYear();
      const monthDiff = today.getMonth() - birthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
    }

    console.log("📊 User data prepared:", {
      name: profile.full_name,
      age,
      goalType: nutritionProfile.goalType,
      dietType: nutritionProfile.dietType
    });

    const userData = {
      fullName: profile.full_name,
      age: age,
      gender: profile.gender || 'male',
      weightKg: profile.weight_kg || 70,
      heightCm: profile.height_cm || 170,
      activityLevel: nutritionProfile.activityLevel || profile.activity_level || 'sedentary',
      goalType: nutritionProfile.goalType,
      dietType: nutritionProfile.dietType,
      ifSchedule: nutritionProfile.ifSchedule || '',
      chronicDiseases: nutritionProfile.chronicDiseases || [],
      lifestyle: nutritionProfile.lifestyle,
      eatingRelation: nutritionProfile.eatingRelation,
      mealTimes: nutritionProfile.mealTimes,
      improvementGoal: nutritionProfile.improvementGoal
    };

    console.log("🤖 Calling Gemini to generate plan...");
    const result = await generateNutritionPlan(userData);
    console.log("✅ Plan generated from Gemini!");

    const existingPlan = await SavedNutritionPlan.findOne({ userAuthId: user.auth_id });
    if (existingPlan) {
      console.log("🗑️ Deleting old plan");
      await SavedNutritionPlan.deleteOne({ _id: existingPlan._id });
    }

    const planData = {
      userAuthId: user.auth_id,
      tdee: result.calculations.tdee,
      targetCalories: result.calculations.targetCalories,
      proteinGrams: result.calculations.proteinGrams,
      carbsGrams: result.calculations.carbsGrams,
      fatsGrams: result.calculations.fatsGrams,
      weeklyPlan: result.plan.weeklyPlan || [],
      nutritionTips: result.plan.tips || [],
      shoppingList: result.plan.shoppingList || [],
      goalType: nutritionProfile.goalType,
      dietType: nutritionProfile.dietType,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const newPlan = new SavedNutritionPlan(planData);
    const savedPlan = await newPlan.save();
    
    console.log("✅✅✅ Plan saved successfully!");

    return res.status(200).json({
      message: "Nutrition plan generated and saved successfully",
      data: {
        calculations: result.calculations,
        plan: result.plan
      }
    });

  } catch (error) {
    console.error("❌❌❌ generatePlan error:", error);
    res.status(500).json({ 
      error: "Failed to generate nutrition plan",
      details: error.message 
    });
  }
};

// ==================== Get Saved Plan ====================
export const getSavedPlan = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const savedPlan = await SavedNutritionPlan.findOne({ userAuthId: user.auth_id });
    
    if (!savedPlan) {
      return res.status(404).json({ 
        error: "No plan found",
        hasPlan: false 
      });
    }

    return res.status(200).json({
      hasPlan: true,
      data: {
        calculations: {
          tdee: savedPlan.tdee,
          targetCalories: savedPlan.targetCalories,
          proteinGrams: savedPlan.proteinGrams,
          carbsGrams: savedPlan.carbsGrams,
          fatsGrams: savedPlan.fatsGrams
        },
        plan: {
          weeklyPlan: savedPlan.weeklyPlan || [],
          tips: savedPlan.nutritionTips || [],
          shoppingList: savedPlan.shoppingList || []
        },
        lastGeneratedAt: savedPlan.createdAt
      }
    });

  } catch (error) {
    console.error("❌ getSavedPlan error:", error);
    res.status(500).json({ 
      error: "Failed to fetch saved plan",
      details: error.message 
    });
  }
};

// ==================== Delete Current Plan ====================
export const deletePlan = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    await SavedNutritionPlan.deleteOne({ userAuthId: user.auth_id });

    return res.status(200).json({
      message: "Plan deleted successfully",
      success: true
    });

  } catch (error) {
    console.error("❌ deletePlan error:", error);
    res.status(500).json({ 
      error: "Failed to delete plan",
      details: error.message 
    });
  }
};

// ==================== 🆕 SUGGEST MEAL ====================
export const suggestMealEndpoint = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const { remainingCalories, availableIngredients } = req.body;

    const profile = await Profile.findOne({ auth_id: user.auth_id });
    const nutritionProfile = await NutritionProfile.findOne({ userAuthId: user.auth_id });
    const savedPlan = await SavedNutritionPlan.findOne({ userAuthId: user.auth_id });

    if (!profile || !nutritionProfile || !savedPlan) {
      return res.status(404).json({ error: "Complete your profile first" });
    }

    const userData = {
      goalType: nutritionProfile.goalType,
      dietType: nutritionProfile.dietType,
      chronicDiseases: nutritionProfile.chronicDiseases || [],
      targetCalories: savedPlan.targetCalories,
      remainingCalories: remainingCalories || savedPlan.targetCalories,
      availableIngredients: availableIngredients || []
    };

    const suggestion = await suggestMeal(userData);

    return res.status(200).json({
      success: true,
      meal: suggestion
    });

  } catch (error) {
    console.error("❌ suggestMeal error:", error);
    res.status(500).json({ 
      error: "Failed to suggest meal",
      details: error.message 
    });
  }
};

// ==================== 🆕 ASK AI NUTRITIONIST ====================
export const askNutritionist = async (req, res) => {
  try {
    console.log('🔄 askNutritionist endpoint called');
    
    const user = req.user;
    if (!user || !user.auth_id) {
      console.log('❌ No user auth_id');
      return res.status(401).json({ error: "Unauthorized" });
    }

    const { question } = req.body;
    console.log('📝 Question received:', question);

    if (!question || question.trim() === '') {
      console.log('❌ Empty question');
      return res.status(400).json({ error: "Question is required" });
    }

    console.log('🔄 Fetching user profiles...');
    
    const profile = await Profile.findOne({ auth_id: user.auth_id });
    const nutritionProfile = await NutritionProfile.findOne({ userAuthId: user.auth_id });
    const savedPlan = await SavedNutritionPlan.findOne({ userAuthId: user.auth_id });

    console.log('✅ Profiles fetched:', {
      hasProfile: !!profile,
      hasNutritionProfile: !!nutritionProfile,
      hasSavedPlan: !!savedPlan
    });

    const context = {
      goalType: nutritionProfile?.goalType || '',
      dietType: nutritionProfile?.dietType || '',
      chronicDiseases: nutritionProfile?.chronicDiseases || [],
      targetCalories: savedPlan?.targetCalories || 0,
      currentWeight: profile?.weight_kg || 0
    };

    console.log('📊 Context prepared:', context);
    console.log('🤖 Calling answerNutritionQuestion...');

    const answer = await answerNutritionQuestion(question, context);

    console.log('✅ Got answer, length:', answer.length);

    return res.status(200).json({
      success: true,
      answer: answer
    });

  } catch (error) {
    console.error('❌❌❌ askNutritionist error:', error);
    console.error('❌ Error message:', error.message);
    console.error('❌ Error stack:', error.stack);
    
    // Send a user-friendly error
    res.status(500).json({ 
      error: "حدث خطأ في معالجة السؤال",
      details: process.env.NODE_ENV === 'development' ? error.message : undefined,
      answer: "عذراً، حدث خطأ مؤقت. يرجى المحاولة مرة أخرى. 🙏"
    });
  }
};

// ==================== 🆕 LOG DAILY PROGRESS ====================
export const logDailyProgress = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const { date, caloriesConsumed, waterIntake, weight, notes } = req.body;

    const progressData = {
      userAuthId: user.auth_id,
      date: date || new Date(),
      caloriesConsumed: caloriesConsumed || 0,
      waterIntake: waterIntake || 0,
      weight: weight,
      notes: notes || '',
      updatedAt: new Date()
    };

    const progress = await DailyProgress.findOneAndUpdate(
      { 
        userAuthId: user.auth_id,
        date: progressData.date
      },
      progressData,
      { upsert: true, new: true }
    );

    return res.status(200).json({
      success: true,
      data: progress
    });

  } catch (error) {
    console.error("❌ logDailyProgress error:", error);
    res.status(500).json({ 
      error: "Failed to log progress",
      details: error.message 
    });
  }
};

// ==================== 🆕 GET PROGRESS HISTORY ====================
export const getProgressHistory = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const { days } = req.query;
    const daysAgo = parseInt(days) || 30;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysAgo);

    const history = await DailyProgress.find({
      userAuthId: user.auth_id,
      date: { $gte: startDate }
    }).sort({ date: -1 });

    return res.status(200).json({
      success: true,
      data: history
    });

  } catch (error) {
    console.error("❌ getProgressHistory error:", error);
    res.status(500).json({ 
      error: "Failed to fetch history",
      details: error.message 
    });
  }
};
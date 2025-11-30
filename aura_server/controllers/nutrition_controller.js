import NutritionProfile from "../models/nutritionProfile.js";

export const submitOnboarding = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    // 1. Get all fields including improvement_goal
    const { 
      lifestyle, 
      eating_relation, 
      meal_times, 
      improvement_goal 
    } = req.body;

    // 2. Prepare array validation only (ensure meal_times is an array)
    const mealTimesVal = Array.isArray(meal_times) ? meal_times : [];

    // 3. Upsert with the exact values sent from Flutter
    const doc = await NutritionProfile.findOneAndUpdate(
      { userAuthId: user.auth_id },
      {
        userAuthId: user.auth_id,
        lifestyle: lifestyle,                 // Save exactly what comes from app
        eatingRelation: eating_relation,      // Save exactly what comes from app
        mealTimes: mealTimesVal,
        improvementGoal: improvement_goal,    // Save the goal
        updatedAt: new Date()
      },
      { upsert: true, new: true }
    );

    return res.status(200).json({ message: "Onboarding saved", profile: doc });
  } catch (e) {
    console.error("submitOnboarding error:", e);
    res.status(500).json({ error: "Failed to save onboarding" });
  }
};

export const getOnboarding = async (req, res) => {
  try {
    const user = req.user;
    if (!user || !user.auth_id) return res.status(401).json({ error: "Unauthorized" });

    const doc = await NutritionProfile.findOne({ userAuthId: user.auth_id });
    
    if (!doc) return res.status(404).json({ error: "Not found" });
    
    return res.json({ profile: doc });
  } catch (e) {
    console.error("getOnboarding error:", e);
    res.status(500).json({ error: "Failed to fetch onboarding" });
  }
};
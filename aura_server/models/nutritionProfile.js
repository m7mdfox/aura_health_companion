import mongoose from "mongoose";

const NutritionProfileSchema = new mongoose.Schema({
  userAuthId: { type: String, required: true, index: true },
  lifestyle: { type: String, default: "" }, 
  eatingRelation: { type: String, default: "" }, 
  mealTimes: [{ type: String }], 
  improvementGoal: { type: String, default: "" },
  
  goalType: { 
    type: String, 
    enum: ["lose_weight", "gain_weight", "maintain", "build_muscle", ""],
    default: "" 
  },
  
  dietType: { 
    type: String, 
    enum: ["balanced", "keto", "low_carb", "intermittent_fasting", ""],
    default: "" 
  },
  
  ifSchedule: { 
    type: String, 
    enum: ["16_8", "18_6", "omad", ""],
    default: "" 
  },
  
  activityLevel: { 
    type: String, 
    enum: ["sedentary", "lightly_active", "moderately_active", "very_active", "extra_active", ""],
    default: "" 
  },
  
  chronicDiseases: [{ type: String }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

NutritionProfileSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

const NutritionProfile = mongoose.models.NutritionProfile || mongoose.model("NutritionProfile", NutritionProfileSchema);
export default NutritionProfile;
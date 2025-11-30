import mongoose from "mongoose";

const NutritionProfileSchema = new mongoose.Schema({
  userAuthId: { type: String, required: true, index: true },
  
  // Changed to generic String to allow saving any user choice
  lifestyle: { type: String, default: "" }, 
  
  // Changed to generic String
  eatingRelation: { type: String, default: "" }, 
  
  mealTimes: [{ type: String }], 
  
  // ADDED THIS FIELD (It was missing in your previous database save)
  improvementGoal: { type: String, default: "" }, 
  
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

NutritionProfileSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

export default mongoose.model("NutritionProfile", NutritionProfileSchema);
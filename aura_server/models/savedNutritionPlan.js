// server/models/savedNutritionPlan.js
import mongoose from "mongoose";

const SavedNutritionPlanSchema = new mongoose.Schema({
  userAuthId: { 
    type: String, 
    required: true, 
    unique: true,  // كل مستخدم له خطة واحدة فقط
    index: true 
  },
  
  // حسابات السعرات والماكروز
  tdee: { 
    type: Number, 
    required: true 
  },
  targetCalories: { 
    type: Number, 
    required: true 
  },
  proteinGrams: { 
    type: Number, 
    required: true 
  },
  carbsGrams: { 
    type: Number, 
    required: true 
  },
  fatsGrams: { 
    type: Number, 
    required: true 
  },
  
  // الخطة الأسبوعية كاملة
  weeklyPlan: { 
    type: Array, 
    required: true,
    default: []
  },
  
  // النصائح الغذائية
  nutritionTips: { 
    type: Array, 
    default: [] 
  },
  
  // قائمة التسوق
  shoppingList: { 
    type: Array, 
    default: [] 
  },
  
  // معلومات إضافية من الـ Profile
  goalType: { 
    type: String,
    required: true
  },
  dietType: { 
    type: String,
    required: true
  },
  
  // التواريخ
  createdAt: { 
    type: Date, 
    default: Date.now 
  },
  updatedAt: { 
    type: Date, 
    default: Date.now 
  }
});

// تحديث updatedAt تلقائيًا عند التعديل
SavedNutritionPlanSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

SavedNutritionPlanSchema.pre('findOneAndUpdate', function(next) {
  this.set({ updatedAt: Date.now() });
  next();
});

// Log عند إنشاء أو حفظ خطة
SavedNutritionPlanSchema.post('save', function(doc) {
  console.log('✅ SavedNutritionPlan saved to DB:', doc._id);
});

// ✅ تحقق إذا كان الـ model موجود قبل ما تعرفه
const SavedNutritionPlan = mongoose.models.SavedNutritionPlan || mongoose.model("SavedNutritionPlan", SavedNutritionPlanSchema);

console.log('📋 SavedNutritionPlan model registered');

export default SavedNutritionPlan;
import mongoose from "mongoose";

const userMedicineSchema = new mongoose.Schema({
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: "Profile", required: true }, // Linked to Profile
  trade_name: { type: String, required: true },        // الاسم التجاري للدواء
  concentration: { type: String },                     // التركيز (مثل 500mg)
  dose: { type: String },                              // الجرعة (مثلاً قرص واحد)
  frequency: { type: Number, min: 1 },                 // عدد المرات في اليوم
  duration_days: { type: Number, min: 1 },             // مدة العلاج بالأيام
  quantity: { type: Number, default: 0 },              // كمية الدواء الحالية
  active_ingredient: { type: String },                 // المادة الفعالة
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now },
});

export default mongoose.model("UserMedicine", userMedicineSchema);

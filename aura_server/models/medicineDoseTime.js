import mongoose from "mongoose";

const medicineDoseTimeSchema = new mongoose.Schema({
  medicine_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "UserMedicine",
    required: true,
  }, // ارتباط بالدواء
  dose_time: { type: String, required: true }, // وقت الجرعة (تقدر تستخدم Date لو هتسجل التوقيت الفعلي)
  created_at: { type: Date, default: Date.now },
});

export default mongoose.model("MedicineDoseTime", medicineDoseTimeSchema);

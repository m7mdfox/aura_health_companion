// /models/DoctorWeeklySchedule.js
import mongoose from "mongoose";

const scheduleSchema = new mongoose.Schema({
  doctor_id: { type: mongoose.Schema.Types.ObjectId, ref: "Doctor", required: true },
  // day_of_week: 0 = Sunday, 1 = Monday, ... 6 = Saturday
  day_of_week: { type: Number, min: 0, max: 6, required: true },
  week_num: { type: Number }, // optional: week number in the year if you track per-week availability
  start_time: { type: String, required: true }, // "09:00"
  end_time: { type: String, required: true },   // "09:30"
  is_available: { type: Boolean, default: true }
}, { timestamps: true });

export default mongoose.model("DoctorWeeklySchedule", scheduleSchema);

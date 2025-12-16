// models/Appointment.js
import mongoose from "mongoose";

const appointmentSchema = new mongoose.Schema({
  doctor_id: { type: mongoose.Schema.Types.ObjectId, ref: "Doctor", required: true },
  
  // FIX: This must match the name in profile.js ("Profile")
  patient_id: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: "Profile", 
    required: true 
  },
  
  appointment_date: { type: Date, required: true },
  start_time: { type: String, required: true },
  end_time: { type: String, required: true },
  type: { type: String, enum: ["consultation", "examination"], default: "consultation" },
  status: { type: String, enum: ["requested", "confirmed", "cancelled", "completed", "rejected"], default: "requested" },
  notes: { type: String },
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now }
}, { timestamps: true });

export default mongoose.model("Appointment", appointmentSchema);
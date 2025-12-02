// /models/Appointment.js
import mongoose from "mongoose";

const appointmentSchema = new mongoose.Schema({
  doctor_id: { type: mongoose.Schema.Types.ObjectId, ref: "Doctor", required: true },
  patient_id: { type: mongoose.Schema.Types.ObjectId, ref: "Profile", required: true },
  appointment_date: { type: Date, required: true }, // the date (and optionally time)
  start_time: { type: String, required: true }, // "14:00"
  end_time: { type: String, required: true },   // "14:30"
  type: { type: String, enum: ["consultation", "examination"], default: "consultation" },
  status: { type: String, enum: ["requested", "confirmed", "cancelled", "completed", "rejected"], default: "requested" },
  notes: { type: String },
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now }
}, { timestamps: true });

export default mongoose.model("Appointment", appointmentSchema);

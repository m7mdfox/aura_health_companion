// /models/Doctor.js
import mongoose from "mongoose";

const doctorSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }, // hashed
  specialty: { type: String },
  clinic_address: { type: String },
  bio: { type: String },
  price_examination: { type: Number, default: 0 },
  duration_of_examination: { type: Number, default: 20 }, // minutes
  price_consultation: { type: Number, default: 0 },
  duration_of_consultation: { type: Number, default: 30 }, // minutes (string in your doc -> prefer number)
  rating_avg: { type: Number, default: 0 },
  rating_count: { type: Number, default: 0 },
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now },
}, { timestamps: true });

export default mongoose.model("Doctor", doctorSchema);

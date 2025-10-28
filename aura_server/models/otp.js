import mongoose from "mongoose";

const otpSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  otp: { type: String, required: true },
  created_at: { type: Date, default: Date.now, expires: 300 }, // OTP expires in 5 minutes
});

export default mongoose.model("OTP", otpSchema);
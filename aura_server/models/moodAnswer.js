// models/moodAnswer.js
import mongoose from "mongoose";

const moodAnswerSchema = new mongoose.Schema({
  auth_id: { type: String, required: true },
  mood_type: { type: String, required: true },
  answers: { type: mongoose.Schema.Types.Mixed, required: true },
  language: { type: String, default: "en" },
  ai_insights: { type: String, default: null },     // جديد
  ai_updated_at: { type: Date, default: null },     // جديد
  created_at: { type: Date, default: Date.now },
});

const MoodAnswer = mongoose.model("MoodAnswer", moodAnswerSchema);
export default MoodAnswer;
// models/mood.js
import mongoose from "mongoose";

const moodSchema = new mongoose.Schema({
  auth_id: { type: String, required: true },
  mood_type: { type: String, required: true },
  note: { type: String },
  created_at: { type: Date, default: Date.now },
});

const Mood = mongoose.model("Mood", moodSchema);
export default Mood;
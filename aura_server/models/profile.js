import mongoose from "mongoose";

const profileSchema = new mongoose.Schema({
  auth_id: { type: String, required: true, unique: true },
  full_name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  phone: String,
  gender: { type: String, enum: ["male", "female", "other"] },
  birthdate: Date,
  height_cm: Number,
  weight_kg: Number,
  chronic_conditions: [String],
  avatar_url: String,
  locale: { type: String, default: "en" },
  created_at: { type: Date, default: Date.now },
}, { 
  timestamps: true,
  collection: "profiles" // <--- ADD THIS LINE (Forces connection to 'profiles')
});

// Check if "Profile" is already defined. If yes, use it. If no, create it.
const Profile = mongoose.models.Profile || mongoose.model("Profile", profileSchema);
export default Profile;
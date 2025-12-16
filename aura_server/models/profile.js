import mongoose from "mongoose";

const profileSchema = new mongoose.Schema({
  auth_id: { 
    type: String, 
    required: true, 
    unique: true,
    index: true // لتسريع البحث
  },
  full_name: { 
    type: String, 
    required: true,
    trim: true
  },
  email: { 
    type: String, 
    required: true, 
    unique: true,
    lowercase: true,
    trim: true,
    index: true
  },
  password: { 
    type: String, 
    required: true 
  },
  phone: {
    type: String,
    trim: true
  },
  gender: { 
    type: String, 
    enum: ["male", "female", "other"],
    lowercase: true
  },
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
  height_cm: {
    type: Number,
    min: 100,
    max: 250
  },
  weight_kg: {
    type: Number,
    min: 30,
    max: 300
  },
  blood_type: {
    type: String,
    enum: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
  },
  chronic_conditions: {
    type: [String],
    default: []
  },
  
  // مستوى النشاط البدني
  activity_level: { 
    type: String, 
    enum: ["sedentary", "lightly_active", "moderately_active", "very_active", "extra_active"],
    default: "sedentary"
  },
  
  // صورة الملف الشخصي
  avatar_url: {
    type: String,
    default: null
  },
  
  // اللغة المفضلة
  locale: { 
    type: String, 
    default: "en",
    enum: ["en", "ar"]
  },
  
  // إحصائيات المستخدم
  streakDays: {
    type: Number,
    default: 0
  },
  totalPoints: {
    type: Number,
    default: 0
  },
  completedChallenges: {
    type: Number,
    default: 0
  },
  
  // أهداف صحية
  waterIntakeGoal: {
    type: Number,
    default: 2.5 // باللتر
  },
  stepsGoal: {
    type: Number,
    default: 10000
  },
  
  // التواريخ
  created_at: { 
    type: Date, 
    default: Date.now 
  },
  updated_at: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true // يضيف createdAt و updatedAt تلقائياً
});

// Index مركب للبحث السريع
profileSchema.index({ auth_id: 1, email: 1 });

// Virtual للعمر
profileSchema.virtual('age').get(function() {
  if (!this.birthdate) return null;
  const today = new Date();
  const birthDate = new Date(this.birthdate);
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
});

// Virtual لـ BMI
profileSchema.virtual('bmi').get(function() {
  if (!this.height_cm || !this.weight_kg) return null;
  const heightInMeters = this.height_cm / 100;
  return (this.weight_kg / (heightInMeters * heightInMeters)).toFixed(1);
});

// تفعيل الـ virtuals عند التحويل إلى JSON
profileSchema.set('toJSON', { 
  virtuals: true,
  transform: function(doc, ret) {
    delete ret.__v;
    return ret;
  }
});

profileSchema.set('toObject', { virtuals: true });

// تحديث updated_at قبل الحفظ
profileSchema.pre('save', function(next) {
  this.updated_at = new Date();
  next();
});

// تحديث updated_at قبل findOneAndUpdate
profileSchema.pre('findOneAndUpdate', function(next) {
  this.set({ updated_at: new Date() });
  next();
});

// ✅ منع تكرار الموديل
const Profile = mongoose.models.Profile || mongoose.model("Profile", profileSchema);

export default Profile;
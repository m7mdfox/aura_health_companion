// models/dailyProgress.js - Daily Progress Tracking Model
import mongoose from "mongoose";

const dailyProgressSchema = new mongoose.Schema(
  {
    userAuthId: {
      type: String,
      required: true,
      index: true
    },
    date: {
      type: Date,
      required: true,
      index: true
    },
    // Calories consumed
    caloriesConsumed: {
      type: Number,
      default: 0,
      min: 0
    },
    // Water intake in liters
    waterIntake: {
      type: Number,
      default: 0,
      min: 0
    },
    // Current weight in kg
    weight: {
      type: Number,
      min: 0
    },
    // Exercise/activity minutes
    exerciseMinutes: {
      type: Number,
      default: 0,
      min: 0
    },
    // Macros breakdown (optional)
    macros: {
      protein: { type: Number, default: 0 },
      carbs: { type: Number, default: 0 },
      fats: { type: Number, default: 0 }
    },
    // Meals logged
    meals: [{
      name: String,
      calories: Number,
      time: String,
      type: {
        type: String,
        enum: ['breakfast', 'lunch', 'dinner', 'snack']
      }
    }],
    // User notes
    notes: {
      type: String,
      maxlength: 500
    },
    // Mood/energy level
    mood: {
      type: String,
      enum: ['excellent', 'good', 'okay', 'tired', 'bad']
    },
    // Sleep hours
    sleepHours: {
      type: Number,
      min: 0,
      max: 24
    },
    // Progress photos (optional)
    photos: [{
      url: String,
      uploadedAt: Date
    }],
    // Adherence to plan (percentage)
    adherence: {
      type: Number,
      min: 0,
      max: 100
    }
  },
  {
    timestamps: true
  }
);

// Create compound index for user + date (unique combination)
dailyProgressSchema.index({ userAuthId: 1, date: 1 }, { unique: true });

// Virtual for calculating daily goal achievement
dailyProgressSchema.virtual('goalAchievement').get(function() {
  if (this.targetCalories && this.caloriesConsumed) {
    return Math.round((this.caloriesConsumed / this.targetCalories) * 100);
  }
  return null;
});

// Method to get weekly summary
dailyProgressSchema.statics.getWeeklySummary = async function(userAuthId, startDate, endDate) {
  return this.aggregate([
    {
      $match: {
        userAuthId: userAuthId,
        date: { $gte: startDate, $lte: endDate }
      }
    },
    {
      $group: {
        _id: null,
        avgCalories: { $avg: '$caloriesConsumed' },
        avgWater: { $avg: '$waterIntake' },
        totalExercise: { $sum: '$exerciseMinutes' },
        daysLogged: { $sum: 1 }
      }
    }
  ]);
};

// Method to get weight trend
dailyProgressSchema.statics.getWeightTrend = async function(userAuthId, days = 30) {
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);
  
  return this.find({
    userAuthId: userAuthId,
    date: { $gte: startDate },
    weight: { $exists: true, $ne: null }
  })
  .select('date weight')
  .sort({ date: 1 });
};

const DailyProgress = mongoose.model("DailyProgress", dailyProgressSchema);

export default DailyProgress;
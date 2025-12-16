// models/HealthPoints.js - Transaction log for health points
import mongoose from "mongoose";

const healthPointsSchema = new mongoose.Schema({
    user_auth_id: {
        type: String,
        required: true,
        index: true
    },
    points: {
        type: Number,
        required: true
    },
    action_type: {
        type: String,
        required: true,
        enum: [
            'challenge_complete',
            'daily_login',
            'water_goal',
            'exercise',
            'streak_bonus',
            'mood_log',
            'medicine_taken'
        ]
    },
    action_id: {
        type: String,
        default: null
    },
    description: {
        type: String,
        default: ''
    },
    created_at: {
        type: Date,
        default: Date.now,
        index: true
    }
}, {
    timestamps: false,
    collection: "health_points"
});

// Compound index for efficient user history queries
healthPointsSchema.index({ user_auth_id: 1, created_at: -1 });

// Static method to get user's total points
healthPointsSchema.statics.getUserTotalPoints = async function (userAuthId) {
    const result = await this.aggregate([
        { $match: { user_auth_id: userAuthId } },
        { $group: { _id: null, total: { $sum: '$points' } } }
    ]);
    return result.length > 0 ? result[0].total : 0;
};

// Static method to get points history
healthPointsSchema.statics.getUserHistory = async function (userAuthId, limit = 50) {
    return this.find({ user_auth_id: userAuthId })
        .sort({ created_at: -1 })
        .limit(limit);
};

// Static method to get points by action type
healthPointsSchema.statics.getPointsByAction = async function (userAuthId, actionType) {
    const result = await this.aggregate([
        { $match: { user_auth_id: userAuthId, action_type: actionType } },
        { $group: { _id: null, total: { $sum: '$points' } } }
    ]);
    return result.length > 0 ? result[0].total : 0;
};

const HealthPoints = mongoose.models.HealthPoints || mongoose.model("HealthPoints", healthPointsSchema);

export default HealthPoints;

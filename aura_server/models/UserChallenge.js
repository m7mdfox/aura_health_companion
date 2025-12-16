// models/UserChallenge.js - User challenge progress tracking
import mongoose from "mongoose";

const userChallengeSchema = new mongoose.Schema({
    user_auth_id: {
        type: String,
        required: true,
        index: true
    },
    challenge_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Challenge',
        required: true,
        index: true
    },
    status: {
        type: String,
        enum: ['in_progress', 'completed', 'expired', 'abandoned'],
        default: 'in_progress',
        index: true
    },
    progress: {
        type: Number,
        default: 0,
        min: 0
    },
    target: {
        type: Number,
        required: true
    },
    started_at: {
        type: Date,
        default: Date.now
    },
    completed_at: {
        type: Date,
        default: null
    },
    expires_at: {
        type: Date,
        default: null
    },
    points_awarded: {
        type: Number,
        default: 0
    }
}, {
    timestamps: true,
    collection: "user_challenges"
});

// Compound index for user + challenge uniqueness
userChallengeSchema.index({ user_auth_id: 1, challenge_id: 1 });

// Get user's active challenges
userChallengeSchema.statics.getActiveForUser = async function (userAuthId) {
    return this.find({
        user_auth_id: userAuthId,
        status: 'in_progress'
    }).populate('challenge_id');
};

// Get user's completed challenges
userChallengeSchema.statics.getCompletedForUser = async function (userAuthId) {
    return this.find({
        user_auth_id: userAuthId,
        status: 'completed'
    }).populate('challenge_id').sort({ completed_at: -1 });
};

// Get user's challenge count
userChallengeSchema.statics.getCompletedCount = async function (userAuthId) {
    return this.countDocuments({
        user_auth_id: userAuthId,
        status: 'completed'
    });
};

// Virtual for progress percentage
userChallengeSchema.virtual('progress_percentage').get(function () {
    if (!this.target || this.target === 0) return 0;
    return Math.min(100, Math.round((this.progress / this.target) * 100));
});

userChallengeSchema.set('toJSON', { virtuals: true });
userChallengeSchema.set('toObject', { virtuals: true });

const UserChallenge = mongoose.models.UserChallenge || mongoose.model("UserChallenge", userChallengeSchema);

export default UserChallenge;

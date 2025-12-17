// models/Challenge.js - Challenge definitions
import mongoose from "mongoose";

const challengeSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true
    },
    title_ar: {
        type: String,
        trim: true
    },
    description: {
        type: String,
        required: true
    },
    description_ar: {
        type: String
    },
    points_reward: {
        type: Number,
        required: true,
        min: 1
    },
    category: {
        type: String,
        required: true,
        enum: ['fitness', 'nutrition', 'wellness', 'hydration', 'medication'],
        index: true
    },
    difficulty: {
        type: String,
        required: true,
        enum: ['easy', 'medium', 'hard'],
        default: 'easy'
    },
    // Requirements for completing the challenge
    requirements: {
        type: {
            type: String,
            enum: ['count', 'duration', 'streak'],
            default: 'count'
        },
        target: {
            type: Number,
            required: true,
            default: 1
        },
        unit: {
            type: String,
            default: 'times'
        }
    },
    // Duration in days (0 = one-time challenge)
    duration_days: {
        type: Number,
        default: 0
    },
    // Icon/image for the challenge
    icon: {
        type: String,
        default: '🏆'
    },
    // Action that triggers automatic progress update
    action_trigger: {
        type: String,
        enum: ['medicine_taken', 'mood_log', 'water_goal', 'exercise', 'daily_login', null],
        default: null,
        index: true
    },
    is_active: {
        type: Boolean,
        default: true,
        index: true
    },
    // Order for display
    sort_order: {
        type: Number,
        default: 0
    },
    created_at: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true,
    collection: "challenges"
});

// Get active challenges by category
challengeSchema.statics.getByCategory = async function (category) {
    return this.find({ category, is_active: true }).sort({ sort_order: 1 });
};

// Get all active challenges
challengeSchema.statics.getAllActive = async function () {
    return this.find({ is_active: true }).sort({ category: 1, sort_order: 1 });
};

const Challenge = mongoose.models.Challenge || mongoose.model("Challenge", challengeSchema);

export default Challenge;

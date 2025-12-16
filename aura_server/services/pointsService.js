// services/pointsService.js - Centralized points management service
import HealthPoints from "../models/HealthPoints.js";
import Profile from "../models/profile.js";
import UserChallenge from "../models/UserChallenge.js";

// Points configuration
const POINTS_CONFIG = {
    challenge_complete_easy: 20,
    challenge_complete_medium: 35,
    challenge_complete_hard: 50,
    daily_login: 5,
    water_goal: 10,
    exercise: 15,
    mood_log: 5,
    medicine_taken: 10,
    streak_bonus_7: 50,
    streak_bonus_30: 200
};

const pointsService = {
    /**
     * Award points to a user and log the transaction
     * @param {string} userAuthId - User's auth ID
     * @param {number} points - Points to award
     * @param {string} actionType - Type of action
     * @param {string} description - Description of the action
     * @param {string} actionId - Optional reference ID
     * @returns {Object} - The created transaction and updated total
     */
    async awardPoints(userAuthId, points, actionType, description = '', actionId = null) {
        try {
            console.log(`📝 awardPoints called: user=${userAuthId}, points=${points}, action=${actionType}`);

            // Create transaction record
            const transaction = await HealthPoints.create({
                user_auth_id: userAuthId,
                points,
                action_type: actionType,
                action_id: actionId,
                description
            });
            console.log(`✅ Transaction created:`, transaction._id);

            // Update user's total points in profile
            const updatedProfile = await Profile.findOneAndUpdate(
                { auth_id: userAuthId },
                { $inc: { totalPoints: points } },
                { new: true }
            );
            console.log(`✅ Profile updated: totalPoints=${updatedProfile?.totalPoints}`);

            return {
                success: true,
                transaction,
                newTotal: updatedProfile?.totalPoints || points
            };
        } catch (error) {
            console.error('❌ Error awarding points:', error);
            throw error;
        }
    },

    /**
     * Get user's points history
     * @param {string} userAuthId - User's auth ID
     * @param {number} limit - Number of records to return
     * @returns {Array} - Points transactions
     */
    async getUserHistory(userAuthId, limit = 50) {
        return HealthPoints.getUserHistory(userAuthId, limit);
    },

    /**
     * Get user's total points
     * @param {string} userAuthId - User's auth ID
     * @returns {number} - Total points
     */
    async getUserTotalPoints(userAuthId) {
        const profile = await Profile.findOne({ auth_id: userAuthId });
        return profile?.totalPoints || 0;
    },

    /**
     * Get leaderboard (top users by points)
     * @param {number} limit - Number of users to return
     * @returns {Array} - Top users with points
     */
    async getLeaderboard(limit = 10) {
        return Profile.find({ totalPoints: { $gt: 0 } })
            .select('full_name avatar_url totalPoints streakDays completedChallenges')
            .sort({ totalPoints: -1 })
            .limit(limit);
    },

    /**
     * Get user's rank in the leaderboard
     * @param {string} userAuthId - User's auth ID
     * @returns {Object} - User's rank and total users
     */
    async getUserRank(userAuthId) {
        const profile = await Profile.findOne({ auth_id: userAuthId });
        if (!profile) return { rank: null, total: 0 };

        const rank = await Profile.countDocuments({
            totalPoints: { $gt: profile.totalPoints }
        }) + 1;

        const total = await Profile.countDocuments({ totalPoints: { $gt: 0 } });

        return { rank, total, points: profile.totalPoints };
    },

    /**
     * Award points for completing a challenge
     * @param {string} userAuthId - User's auth ID
     * @param {Object} challenge - Challenge document
     * @returns {Object} - Award result
     */
    async awardChallengePoints(userAuthId, challenge) {
        const description = `Completed challenge: ${challenge.title}`;

        // Update profile's completed challenges count
        await Profile.findOneAndUpdate(
            { auth_id: userAuthId },
            { $inc: { completedChallenges: 1 } }
        );

        return this.awardPoints(
            userAuthId,
            challenge.points_reward,
            'challenge_complete',
            description,
            challenge._id?.toString()
        );
    },

    /**
     * Award daily login bonus
     * @param {string} userAuthId - User's auth ID
     * @returns {Object} - Award result or null if already awarded today
     */
    async awardDailyLogin(userAuthId) {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Check if already awarded today
        const existingToday = await HealthPoints.findOne({
            user_auth_id: userAuthId,
            action_type: 'daily_login',
            created_at: { $gte: today }
        });

        if (existingToday) {
            return { success: false, reason: 'Already awarded today' };
        }

        return this.awardPoints(
            userAuthId,
            POINTS_CONFIG.daily_login,
            'daily_login',
            'Daily login bonus'
        );
    },

    /**
     * Award points for medicine taken on time
     * @param {string} userAuthId - User's auth ID
     * @param {string} medicineName - Name of the medicine
     * @param {string} medicineId - Medicine ID reference
     * @returns {Object} - Award result
     */
    async awardMedicineTaken(userAuthId, medicineName, medicineId = null) {
        return this.awardPoints(
            userAuthId,
            POINTS_CONFIG.medicine_taken,
            'medicine_taken',
            `Took medicine on time: ${medicineName}`,
            medicineId
        );
    },

    /**
     * Award points for mood logging
     * @param {string} userAuthId - User's auth ID
     * @returns {Object} - Award result
     */
    async awardMoodLog(userAuthId) {
        return this.awardPoints(
            userAuthId,
            POINTS_CONFIG.mood_log,
            'mood_log',
            'Logged daily mood'
        );
    },

    /**
     * Award points for water goal completion
     * @param {string} userAuthId - User's auth ID
     * @returns {Object} - Award result
     */
    async awardWaterGoal(userAuthId) {
        return this.awardPoints(
            userAuthId,
            POINTS_CONFIG.water_goal,
            'water_goal',
            'Reached daily water intake goal'
        );
    },

    /**
     * Award points for exercise
     * @param {string} userAuthId - User's auth ID
     * @param {number} minutes - Exercise duration in minutes
     * @returns {Object} - Award result
     */
    async awardExercise(userAuthId, minutes) {
        return this.awardPoints(
            userAuthId,
            POINTS_CONFIG.exercise,
            'exercise',
            `Completed ${minutes} minutes of exercise`
        );
    },

    /**
     * Check and award streak bonus
     * @param {string} userAuthId - User's auth ID
     * @param {number} streakDays - Current streak days
     * @returns {Object|null} - Award result or null if no bonus
     */
    async checkAndAwardStreakBonus(userAuthId, streakDays) {
        if (streakDays === 7) {
            return this.awardPoints(
                userAuthId,
                POINTS_CONFIG.streak_bonus_7,
                'streak_bonus',
                '7-day streak bonus! 🔥'
            );
        }
        if (streakDays === 30) {
            return this.awardPoints(
                userAuthId,
                POINTS_CONFIG.streak_bonus_30,
                'streak_bonus',
                '30-day streak bonus! 🏆'
            );
        }
        return null;
    },

    /**
     * Get user's points summary by action type
     * @param {string} userAuthId - User's auth ID
     * @returns {Object} - Points breakdown by action
     */
    async getPointsSummary(userAuthId) {
        const result = await HealthPoints.aggregate([
            { $match: { user_auth_id: userAuthId } },
            {
                $group: {
                    _id: '$action_type',
                    total: { $sum: '$points' },
                    count: { $sum: 1 }
                }
            }
        ]);

        const summary = {};
        result.forEach(item => {
            summary[item._id] = { points: item.total, count: item.count };
        });

        return summary;
    },

    // Export points config for reference
    POINTS_CONFIG
};

export default pointsService;

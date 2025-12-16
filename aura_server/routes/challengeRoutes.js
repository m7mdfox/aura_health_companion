// routes/challengeRoutes.js - API routes for challenges
import express from "express";
import Challenge from "../models/Challenge.js";
import UserChallenge from "../models/UserChallenge.js";
import pointsService from "../services/pointsService.js";

const router = express.Router();

/**
 * GET /api/challenges
 * Get all active challenges
 */
router.get("/", async (req, res) => {
    try {
        const { category } = req.query;

        let challenges;
        if (category) {
            challenges = await Challenge.getByCategory(category);
        } else {
            challenges = await Challenge.getAllActive();
        }

        res.json({
            success: true,
            data: challenges
        });
    } catch (error) {
        console.error("Error fetching challenges:", error);
        res.status(500).json({ error: "Failed to fetch challenges" });
    }
});

/**
 * GET /api/challenges/user
 * Get user's challenge progress
 */
router.get("/user", async (req, res) => {
    try {
        const { auth_id } = req.query;

        if (!auth_id) {
            return res.status(400).json({ error: "auth_id is required" });
        }

        const [active, completed] = await Promise.all([
            UserChallenge.getActiveForUser(auth_id),
            UserChallenge.getCompletedForUser(auth_id)
        ]);

        res.json({
            success: true,
            data: {
                active,
                completed,
                completedCount: completed.length
            }
        });
    } catch (error) {
        console.error("Error fetching user challenges:", error);
        res.status(500).json({ error: "Failed to fetch user challenges" });
    }
});

/**
 * POST /api/challenges/:id/start
 * Start a challenge for a user
 */
router.post("/:id/start", async (req, res) => {
    try {
        const { id } = req.params;
        const { auth_id } = req.body;

        if (!auth_id) {
            return res.status(400).json({ error: "auth_id is required" });
        }

        // Check if challenge exists
        const challenge = await Challenge.findById(id);
        if (!challenge) {
            return res.status(404).json({ error: "Challenge not found" });
        }

        // Check if user already has this challenge in progress
        const existingChallenge = await UserChallenge.findOne({
            user_auth_id: auth_id,
            challenge_id: id,
            status: 'in_progress'
        });

        if (existingChallenge) {
            return res.status(400).json({
                error: "Challenge already in progress",
                data: existingChallenge
            });
        }

        // Calculate expiration date if challenge has duration
        let expiresAt = null;
        if (challenge.duration_days > 0) {
            expiresAt = new Date();
            expiresAt.setDate(expiresAt.getDate() + challenge.duration_days);
        }

        // Create user challenge
        const userChallenge = await UserChallenge.create({
            user_auth_id: auth_id,
            challenge_id: id,
            status: 'in_progress',
            progress: 0,
            target: challenge.requirements.target,
            expires_at: expiresAt
        });

        await userChallenge.populate('challenge_id');

        res.json({
            success: true,
            data: userChallenge
        });
    } catch (error) {
        console.error("Error starting challenge:", error);
        res.status(500).json({ error: "Failed to start challenge" });
    }
});

/**
 * POST /api/challenges/:id/progress
 * Update challenge progress
 */
router.post("/:id/progress", async (req, res) => {
    try {
        const { id } = req.params;
        const { auth_id, increment = 1 } = req.body;

        if (!auth_id) {
            return res.status(400).json({ error: "auth_id is required" });
        }

        // Find active user challenge
        const userChallenge = await UserChallenge.findOne({
            user_auth_id: auth_id,
            challenge_id: id,
            status: 'in_progress'
        }).populate('challenge_id');

        if (!userChallenge) {
            return res.status(404).json({
                error: "No active challenge found for this user"
            });
        }

        // Update progress
        userChallenge.progress += increment;

        // Check if challenge is completed
        if (userChallenge.progress >= userChallenge.target) {
            userChallenge.status = 'completed';
            userChallenge.completed_at = new Date();
            userChallenge.points_awarded = userChallenge.challenge_id.points_reward;

            // Award points
            await pointsService.awardChallengePoints(
                auth_id,
                userChallenge.challenge_id
            );
        }

        await userChallenge.save();

        res.json({
            success: true,
            data: userChallenge,
            completed: userChallenge.status === 'completed'
        });
    } catch (error) {
        console.error("Error updating challenge progress:", error);
        res.status(500).json({ error: "Failed to update challenge progress" });
    }
});

/**
 * POST /api/challenges/:id/complete
 * Manually complete a challenge (for instant challenges)
 */
router.post("/:id/complete", async (req, res) => {
    try {
        const { id } = req.params;
        const { auth_id } = req.body;

        if (!auth_id) {
            return res.status(400).json({ error: "auth_id is required" });
        }

        // Find active user challenge
        let userChallenge = await UserChallenge.findOne({
            user_auth_id: auth_id,
            challenge_id: id,
            status: 'in_progress'
        }).populate('challenge_id');

        // If no active challenge, check if it's a one-time challenge they can complete
        if (!userChallenge) {
            const challenge = await Challenge.findById(id);
            if (!challenge) {
                return res.status(404).json({ error: "Challenge not found" });
            }

            // Check if already completed
            const alreadyCompleted = await UserChallenge.findOne({
                user_auth_id: auth_id,
                challenge_id: id,
                status: 'completed'
            });

            if (alreadyCompleted) {
                return res.status(400).json({
                    error: "Challenge already completed"
                });
            }

            // Create and complete in one step for instant challenges
            userChallenge = await UserChallenge.create({
                user_auth_id: auth_id,
                challenge_id: id,
                status: 'completed',
                progress: challenge.requirements.target,
                target: challenge.requirements.target,
                completed_at: new Date(),
                points_awarded: challenge.points_reward
            });

            await pointsService.awardChallengePoints(auth_id, challenge);
            await userChallenge.populate('challenge_id');
        } else {
            // Complete existing challenge
            userChallenge.status = 'completed';
            userChallenge.progress = userChallenge.target;
            userChallenge.completed_at = new Date();
            userChallenge.points_awarded = userChallenge.challenge_id.points_reward;

            await pointsService.awardChallengePoints(
                auth_id,
                userChallenge.challenge_id
            );
            await userChallenge.save();
        }

        res.json({
            success: true,
            data: userChallenge,
            pointsAwarded: userChallenge.points_awarded
        });
    } catch (error) {
        console.error("Error completing challenge:", error);
        res.status(500).json({ error: "Failed to complete challenge" });
    }
});

/**
 * POST /api/challenges (Admin)
 * Create a new challenge
 */
router.post("/", async (req, res) => {
    try {
        const challengeData = req.body;

        const challenge = await Challenge.create(challengeData);

        res.status(201).json({
            success: true,
            data: challenge
        });
    } catch (error) {
        console.error("Error creating challenge:", error);
        res.status(500).json({ error: "Failed to create challenge" });
    }
});

export default router;

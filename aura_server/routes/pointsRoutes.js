// routes/pointsRoutes.js - API routes for health points
import express from "express";
import pointsService from "../services/pointsService.js";
import HealthPoints from "../models/HealthPoints.js";

const router = express.Router();

/**
 * GET /api/points/history
 * Get user's points transaction history
 */
router.get("/history", async (req, res) => {
    try {
        const { auth_id } = req.query;
        const limit = parseInt(req.query.limit) || 50;

        if (!auth_id) {
            return res.status(400).json({ error: "auth_id is required" });
        }

        const history = await pointsService.getUserHistory(auth_id, limit);

        res.json({
            success: true,
            data: history
        });
    } catch (error) {
        console.error("Error fetching points history:", error);
        res.status(500).json({ error: "Failed to fetch points history" });
    }
});

/**
 * GET /api/points/summary
 * Get user's points summary with rank
 */
router.get("/summary", async (req, res) => {
    try {
        const { auth_id } = req.query;

        if (!auth_id) {
            return res.status(400).json({ error: "auth_id is required" });
        }

        const [total, rank, breakdown] = await Promise.all([
            pointsService.getUserTotalPoints(auth_id),
            pointsService.getUserRank(auth_id),
            pointsService.getPointsSummary(auth_id)
        ]);

        res.json({
            success: true,
            data: {
                totalPoints: total,
                rank: rank.rank,
                totalUsers: rank.total,
                breakdown
            }
        });
    } catch (error) {
        console.error("Error fetching points summary:", error);
        res.status(500).json({ error: "Failed to fetch points summary" });
    }
});

/**
 * GET /api/points/leaderboard
 * Get top users by points
 */
router.get("/leaderboard", async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 10;
        const leaderboard = await pointsService.getLeaderboard(limit);

        res.json({
            success: true,
            data: leaderboard
        });
    } catch (error) {
        console.error("Error fetching leaderboard:", error);
        res.status(500).json({ error: "Failed to fetch leaderboard" });
    }
});

/**
 * POST /api/points/award
 * Award points to a user (for internal/admin use)
 */
router.post("/award", async (req, res) => {
    try {
        const { auth_id, points, action_type, description, action_id } = req.body;

        if (!auth_id || !points || !action_type) {
            return res.status(400).json({
                error: "auth_id, points, and action_type are required"
            });
        }

        const result = await pointsService.awardPoints(
            auth_id,
            points,
            action_type,
            description || '',
            action_id || null
        );

        res.json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error("Error awarding points:", error);
        res.status(500).json({ error: "Failed to award points" });
    }
});

/**
 * POST /api/points/daily-login
 * Award daily login bonus
 */
router.post("/daily-login", async (req, res) => {
    try {
        const { auth_id } = req.body;

        if (!auth_id) {
            return res.status(400).json({ error: "auth_id is required" });
        }

        const result = await pointsService.awardDailyLogin(auth_id);

        res.json({
            success: result.success,
            data: result
        });
    } catch (error) {
        console.error("Error awarding daily login:", error);
        res.status(500).json({ error: "Failed to award daily login bonus" });
    }
});

/**
 * GET /api/points/config
 * Get points configuration
 */
router.get("/config", (req, res) => {
    res.json({
        success: true,
        data: pointsService.POINTS_CONFIG
    });
});

export default router;

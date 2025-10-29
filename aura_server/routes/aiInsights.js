// routes/aiInsights.js
import express from 'express';
import MoodAnswer from '../models/moodAnswer.js';
import { generateInsights } from '../utils/gemini.js';

const router = express.Router();

// POST /api/moods/ai-insights
router.post('/', async (req, res) => {
  try {
    const { mood_id, auth_id, mood_type, answers } = req.body;

    if (!mood_id || !auth_id || !mood_type || !answers) {
      return res.status(400).json({ error: 'Missing data' });
    }

    // 1. توليد التحليل
    const ai_insights = await generateInsights(mood_type, answers);

    // 2. تحديث الـ document
    await MoodAnswer.findByIdAndUpdate(mood_id, {
      ai_insights,
      ai_updated_at: new Date(),
    });

    res.status(201).json({
      success: true,
      ai_insights,
    });
  } catch (error) {
    console.error('AI Error:', error);
    res.status(500).json({ error: 'فشل في التحليل الذكي' });
  }
});

export default router;
// aura_server/routes/moodRoutes.js
import express from "express";
import Mood from "../models/mood.js";
import MoodAnswer from "../models/moodAnswer.js";
import { generateInsights } from "../utils/gemini.js";

const router = express.Router();

/* ──────────────────────────────  POST: Add or Update Mood (Same Day) ────────────────────────────── */
router.post("/", async (req, res) => {
  try {
    const { auth_id, mood_type, note } = req.body;

    if (!auth_id || !mood_type) {
      return res.status(400).json({ error: "Missing required fields: auth_id or mood_type" });
    }

    const normalizedMood = mood_type.toLowerCase().trim();
    const validMoods = ["happy", "relaxed", "anxious", "sad", "neutral", "angry", "tired", "stressed"];

    if (!validMoods.includes(normalizedMood)) {
      return res.status(400).json({ error: "Invalid mood_type" });
    }

    const trimmedAuthId = auth_id.trim();

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);

    const updatedMood = await Mood.findOneAndUpdate(
      {
        auth_id: trimmedAuthId,
        created_at: { $gte: today, $lt: tomorrow },
      },
      {
        $set: {
          mood_type: normalizedMood,
          note: note?.trim() || "",
          created_at: new Date(),
        },
      },
      {
        new: true,
        upsert: true,
        setDefaultsOnInsert: true,
      }
    );

    const action = updatedMood.created_at.getTime() === new Date().getTime() ? "saved" : "updated";

    console.log(`🟢 Mood ${action} for ${trimmedAuthId}: ${normalizedMood}`);

    res.status(updatedMood.isNew ? 201 : 200).json({
      message: `Mood ${action} successfully`,
      data: updatedMood,
    });
  } catch (err) {
    console.error("❌ Error saving/updating mood:", err);
    res.status(500).json({ error: "Failed to save mood", details: err.message });
  }
});

/* ──────────────────────────────  GET: Fetch AI Insights by ID ────────────────────────────── */
router.get("/insights/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const doc = await MoodAnswer.findById(id).select("ai_insights ai_updated_at").lean();

    if (!doc || !doc.ai_insights) {
      return res.status(404).json({ error: "AI insights not ready yet" });
    }

    res.json({
      ai_insights: doc.ai_insights,
      updated_at: doc.ai_updated_at,
    });
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch insights" });
  }
});

/* ──────────────────────────────  POST: Save Mood Answers + Trigger AI ────────────────────────────── */
router.post("/answers", async (req, res) => {
  try {
    const { auth_id, mood_type, answers, language } = req.body;

    if (!auth_id || !mood_type || !answers) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const trimmedAuthId = auth_id.trim();
    const normalizedMood = mood_type.toLowerCase().trim();

    console.log(`📩 Received answers for AI from ${trimmedAuthId}, mood=${normalizedMood}`);

    const newAnswer = new MoodAnswer({
      auth_id: trimmedAuthId,
      mood_type: normalizedMood,
      answers,
      language: language || "ar",
    });

    const savedAnswer = await newAnswer.save();

    console.log(`💾 Answers saved to DB (ID: ${savedAnswer._id})`);

    try {
      const lang = language && ["ar", "en"].includes(language) ? language : "ar";

      console.log(`⚙️ Generating AI insights using Gemini for mood=${normalizedMood}, lang=${lang}`);

      const ai_insights = await generateInsights(normalizedMood, answers, lang);

      console.log(`🧠 AI response generated (first 200 chars):\n${ai_insights.substring(0, 200)}...`);

      await MoodAnswer.findByIdAndUpdate(savedAnswer._id, {
        ai_insights,
        ai_updated_at: new Date(),
      });

      const updated = await MoodAnswer.findById(savedAnswer._id).select("ai_insights ai_updated_at").lean();

      console.log(
        `✅ AI insights saved successfully for ${savedAnswer._id} | hasInsights=${!!updated?.ai_insights} | updatedAt=${updated?.ai_updated_at}`
      );
    } catch (err) {
      console.error(`❌ AI generation failed for ${savedAnswer._id}:`, err.message);
    }

    res.status(201).json({
      message: "Answers saved, AI analyzing...",
      mood_answer_id: savedAnswer._id.toString(),
    });
  } catch (err) {
    console.error("❌ Error saving answers:", err);
    res.status(500).json({ error: "Failed to save answers" });
  }
});

/* ──────────────────────────────  GET: Fetch all moods for user ────────────────────────────── */
router.get("/:auth_id", async (req, res) => {
  try {
    const { auth_id } = req.params;
    const moods = await Mood.find({ auth_id }).sort({ created_at: -1 }).lean();
    res.json(moods);
  } catch (err) {
    console.error("Error fetching moods:", err);
    res.status(500).json({ error: "Failed to fetch moods" });
  }
});

/* ──────────────────────────────  GET: Latest insights for today ────────────────────────────── */
router.get("/latest-insights/:auth_id", async (req, res) => {
  try {
    const { auth_id } = req.params;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);

    const latest = await MoodAnswer.findOne({
      auth_id,
      created_at: { $gte: today, $lt: tomorrow },
    })
      .sort({ created_at: -1 })
      .lean();

    if (!latest || !latest.ai_insights) {
      console.log(`⚠️ No insights found yet for ${auth_id}`);
      return res.status(404).json({ error: "No insights yet" });
    }

    console.log(`📤 Sending latest insights for ${auth_id}`);
    res.json({
      mood_type: latest.mood_type,
      ai_insights: latest.ai_insights,
      date: latest.created_at.toISOString().split("T")[0],
    });
  } catch (err) {
    console.error("Latest insights error:", err);
    res.status(500).json({ error: "Failed to fetch latest insights" });
  }
});

/* ──────────────────────────────  Helper: Calculate current streak ────────────────────────────── */
function calculateCurrentStreak(dates) {
  if (dates.length === 0) return 0;
  dates.sort((a, b) => b - a);
  let streak = 1;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const lastEntry = new Date(dates[0]);
  lastEntry.setHours(0, 0, 0, 0);
  const diffFromToday = Math.floor((today - lastEntry) / (1000 * 60 * 60 * 24));
  if (diffFromToday > 0) return 0;

  for (let i = 1; i < dates.length; i++) {
    const prev = new Date(dates[i - 1]);
    const curr = new Date(dates[i]);
    prev.setHours(0, 0, 0, 0);
    curr.setHours(0, 0, 0, 0);
    const diffDays = Math.floor((prev - curr) / (1000 * 60 * 60 * 24));
    if (diffDays === 1) streak++;
    else if (diffDays > 1) break;
  }
  return streak;
}

/* ──────────────────────────────  GET: Mood summary ────────────────────────────── */
router.get("/summary/:auth_id", async (req, res) => {
  try {
    const { auth_id } = req.params;
    const allMoods = await Mood.find({ auth_id }).sort({ created_at: -1 }).lean();

    const defaultDistribution = { Happy: 0, Relaxed: 0, Anxious: 0, Sad: 0, Neutral: 0, Angry: 0, Tired: 0, Stressed: 0 };
    const distribution = allMoods.reduce((acc, m) => {
      const type = m.mood_type.charAt(0).toUpperCase() + m.mood_type.slice(1);
      acc[type] = (acc[type] || 0) + 1;
      return acc;
    }, { ...defaultDistribution });

    const moodValue = { happy: 5, relaxed: 4, neutral: 3, anxious: 2, sad: 1, angry: 1, tired: 1, stressed: 1 };
    const total = allMoods.length;
    let allTimeAverage = 0;
    if (total > 0) {
      const sum = allMoods.reduce((s, m) => s + (moodValue[m.mood_type] || 3), 0);
      allTimeAverage = Number((sum / total).toFixed(1));
    }

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const sevenDaysAgo = new Date(today);
    sevenDaysAgo.setDate(today.getDate() - 6);

    const weekly = [];
    const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    for (let i = 0; i < 7; i++) {
      const day = new Date(sevenDaysAgo);
      day.setDate(sevenDaysAgo.getDate() + i);
      const dayStr = day.toISOString().split("T")[0];
      const dayShort = dayNames[day.getUTCDay()];

      const dayMoods = allMoods.filter((m) => {
        const mDate = new Date(m.created_at);
        return mDate.toISOString().split("T")[0] === dayStr;
      });

      let avg = 0;
      if (dayMoods.length > 0) {
        const sum = dayMoods.reduce((s, m) => s + (moodValue[m.mood_type] || 3), 0);
        avg = Number((sum / dayMoods.length).toFixed(1));
      }

      weekly.push({ day: dayShort, mood: avg });
    }

    const weeklyAverage = Number((weekly.reduce((s, d) => s + d.mood, 0) / 7).toFixed(1));
    const moodDates = allMoods.map((m) => new Date(m.created_at));
    const currentStreak = calculateCurrentStreak(moodDates);

    res.json({
      distribution,
      weekly,
      total,
      allTimeAverage,
      weeklyAverage,
      currentStreak,
    });
  } catch (err) {
    console.error("Error in summary route:", err);
    res.status(500).json({ error: "Failed to generate summary", details: err.message });
  }
});

/* ──────────────────────────────  Test route ────────────────────────────── */
router.get("/test", (req, res) => {
  res.json({
    message: "Mood routes are working!",
    timestamp: new Date().toISOString(),
  });
});

export default router;

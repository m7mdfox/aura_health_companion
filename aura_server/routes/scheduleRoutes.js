// /routes/scheduleRoutes.js
import express from "express";
import DoctorWeeklySchedule from "../models/DoctorWeeklySchedule.js";
const router = express.Router();

// Create or bulk create schedule slots for a doctor
router.post("/", async (req, res) => {
  try {
    const { slots } = req.body; // expect an array of schedule objects
    if (!Array.isArray(slots)) return res.status(400).json({ error: "slots must be an array" });
    const created = await DoctorWeeklySchedule.insertMany(slots);
    res.status(201).json(created);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get schedule for a doctor (optionally filter by day_of_week)
router.get("/doctor/:doctorId", async (req, res) => {
  try {
    const filter = { doctor_id: req.params.doctorId };
    if (req.query.day_of_week !== undefined) filter.day_of_week = Number(req.query.day_of_week);
    const schedules = await DoctorWeeklySchedule.find(filter).lean();
    res.json(schedules);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update a schedule slot
router.put("/:id", async (req, res) => {
  try {
    const updated = await DoctorWeeklySchedule.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete a schedule slot
router.delete("/:id", async (req, res) => {
  try {
    await DoctorWeeklySchedule.findByIdAndDelete(req.params.id);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;

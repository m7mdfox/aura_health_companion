// /routes/doctorRoutes.js
import express from "express";
import Doctor from "../models/Doctor.js";
const router = express.Router();

// Create/register doctor (admin or doctor sign up)
router.post("/", async (req, res) => {
  try {
    const doc = new Doctor(req.body);
    await doc.save();
    res.status(201).json(doc);
  } catch (err) {
    console.error(err);
    res.status(400).json({ error: err.message });
  }
});

// Get doctors list (search by specialty, name, etc.)
router.get("/", async (req, res) => {
  try {
    const { specialty, name } = req.query;
    const filter = {};
    if (specialty) filter.specialty = specialty;
    if (name) filter.name = new RegExp(name, "i");
    const doctors = await Doctor.find(filter).lean();
    res.json(doctors);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single doctor
router.get("/:id", async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id);
    if (!doctor) return res.status(404).json({ error: "Doctor not found" });
    res.json(doctor);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update doctor
router.put("/:id", async (req, res) => {
  try {
    const updated = await Doctor.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;

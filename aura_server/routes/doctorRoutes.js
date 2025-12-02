import express from "express";
import Doctor from "../models/Doctor.js";

const router = express.Router();

// ✅ GET ALL DOCTORS
router.get("/", async (req, res) => {
  console.log("--> Received request for ALL Doctors"); // طباعة للمراقبة
  try {
    const doctors = await Doctor.find({}).lean();
    console.log(`--> Found ${doctors.length} doctors`);
    res.json(doctors);
  } catch (err) {
    console.error("--> Error finding doctors:", err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ CREATE DOCTOR (لإضافة بيانات تجريبية)
router.post("/", async (req, res) => {
  try {
    const doc = new Doctor(req.body);
    await doc.save();
    res.status(201).json(doc);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;
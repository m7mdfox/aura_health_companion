import express from "express";
import mongoose from "mongoose"; // <--- THIS WAS MISSING
import Appointment from "../models/Appointment.js";

const router = express.Router();

router.get("/doctor/:doctorId", async (req, res) => {
  console.log(`\n--- 🔍 DIAGNOSTIC MODE ---`);
  try {
    // 1. WHAT DB ARE WE IN?
    console.log("🔥 Connected Database Name:", mongoose.connection.name);
    
    // 2. IS THE COLLECTION EMPTY?
    const profileCount = await mongoose.model("Profile").countDocuments();
    console.log(`📊 Total Profiles Found in '${mongoose.connection.name}':`, profileCount);

    if (profileCount === 0) {
      console.log("❌ ERROR: The 'profiles' collection is empty or does not exist in this database.");
      console.log("   -> Check if your actual database is named 'test', 'aura_db' (lowercase), or 'AURA_DB'.");
    } else {
      // 3. IF NOT EMPTY, LIST ONE ID TO COMPARE
      const firstProfile = await mongoose.model("Profile").findOne();
      console.log("✅ First Profile ID found:", firstProfile._id);
      
      const targetAppt = await Appointment.findOne({ doctor_id: req.params.doctorId });
      if (targetAppt) {
         console.log("🎯 Looking for ID:", targetAppt.patient_id);
      }
    }

    // 4. Run the populate attempt
    const appts = await Appointment.find({ doctor_id: req.params.doctorId })
      .populate("patient_id", "full_name email")
      .sort({ appointment_date: -1 });

    res.json(appts);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ GET PATIENT APPOINTMENTS
router.get("/patient/:patientId", async (req, res) => {
  try {
    const appts = await Appointment.find({ patient_id: req.params.patientId })
      .populate("doctor_id")
      .sort({ appointment_date: -1 });
    res.json(appts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ UPDATE STATUS
router.put("/:id/status", async (req, res) => {
  try {
    const { status } = req.body;
    const updated = await Appointment.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ CREATE REQUEST
router.post("/request", async (req, res) => {
  try {
    const { doctor_id, patient_id, appointment_date, start_time, end_time, type, notes } = req.body;
    
    const appt = new Appointment({
      doctor_id,
      patient_id,
      appointment_date,
      start_time,
      end_time,
      type: type || "examination",
      status: "requested",
      notes
    });

    await appt.save();
    res.status(201).json(appt);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
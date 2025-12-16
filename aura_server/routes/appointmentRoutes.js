import express from "express";
import mongoose from "mongoose";
import Appointment from "../models/Appointment.js";
import Doctor from "../models/Doctor.js"; // Required for populate to work

const router = express.Router();

// In Node.js doctorController.js
// ✅ GET DOCTOR APPOINTMENTS (SAFE MODE - NO SKIPPING)
// ✅ GET DOCTOR APPOINTMENTS (FIXED - Preserves raw ID when populate fails)
router.get("/doctor/:doctorId", async (req, res) => {
  try {
    console.log(`\n--- Fetching for Doctor: ${req.params.doctorId} ---`);

    // Step 1: Get raw appointments first (without populate) to preserve ObjectIds
    const rawAppts = await Appointment.find({ doctor_id: req.params.doctorId })
      .sort({ appointment_date: -1 })
      .lean(); // Use lean() for plain JS objects

    // Step 2: Get all unique patient IDs
    const patientIds = [...new Set(rawAppts.map(a => a.patient_id?.toString()).filter(Boolean))];
    
    // Step 3: Fetch all existing profiles in one query
    const Profile = mongoose.model("Profile");
    const profiles = await Profile.find({ _id: { $in: patientIds } }).lean();
    
    // Step 4: Create a lookup map
    const profileMap = {};
    profiles.forEach(p => {
      profileMap[p._id.toString()] = p;
    });

    // Step 5: Build the response with preserved IDs
    const cleanList = rawAppts.map(appt => {
      const rawPatientId = appt.patient_id?.toString() || "Unknown_ID";
      const profile = profileMap[rawPatientId];

      return {
        _id: appt._id.toString(),
        doctor_id: appt.doctor_id.toString(),
        patient_id: rawPatientId,  // ✅ Always preserve the raw ID
        patient_name: profile?.full_name || "Unknown Patient",
        patient_email: profile?.email || "N/A",
        appointment_date: appt.appointment_date,
        start_time: appt.start_time,
        end_time: appt.end_time,
        type: appt.type,
        status: appt.status,
        notes: appt.notes
      };
    });

    console.log(`✅ Returning ${cleanList.length} appointments`);
    res.json(cleanList);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ GET PATIENT APPOINTMENTS
router.get("/patient/:patientId", async (req, res) => {
  try {
    console.log(`\n--- Fetching appointments for Patient: ${req.params.patientId} ---`);

    const appts = await Appointment.find({ patient_id: req.params.patientId })
      .populate("doctor_id")
      .sort({ appointment_date: -1 });

    console.log(`Found ${appts.length} appointments for patient ${req.params.patientId}`);

    res.json(appts);
  } catch (err) {
    console.error("Error fetching patient appointments:", err);
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
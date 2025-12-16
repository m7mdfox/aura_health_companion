import express from "express";
import mongoose from "mongoose";
import Appointment from "../models/Appointment.js";
import Doctor from "../models/Doctor.js"; // Required for populate to work

const router = express.Router();

// In Node.js doctorController.js
// ✅ GET DOCTOR APPOINTMENTS (SAFE MODE - NO SKIPPING)
router.get("/doctor/:doctorId", async (req, res) => {
  try {
    console.log(`\n--- Fetching for Doctor: ${req.params.doctorId} ---`);

    const rawAppts = await Appointment.find({ doctor_id: req.params.doctorId })
      .populate("patient_id", "full_name email")
      .sort({ appointment_date: -1 });

    const cleanList = rawAppts.map(appt => {
      // --- LOGIC TO HANDLE BROKEN IDs ---
      let pId = "Unknown_ID";
      let pName = "Unknown Patient";
      let pEmail = "N/A";

      // Case 1: Populate worked (Perfect)
      if (appt.patient_id && appt.patient_id.full_name) {
        pId = appt.patient_id._id;
        pName = appt.patient_id.full_name;
        pEmail = appt.patient_id.email;
      }
      // Case 2: Populate failed (The "Zombie" case)
      else {
        console.log(`⚠️ Keeping broken appointment ${appt._id} visible.`);
        // Try to recover the raw ID if it exists, otherwise keep "Unknown_ID"
        if (appt.patient_id) pId = appt.patient_id.toString();
      }

      return {
        _id: appt._id,
        doctor_id: appt.doctor_id,
        patient_id: pId.toString(),
        patient_name: pName,
        patient_email: pEmail,
        appointment_date: appt.appointment_date,
        start_time: appt.start_time,
        end_time: appt.end_time,
        type: appt.type,
        status: appt.status,
        notes: appt.notes
      };
    });

    // Send the list (Do NOT filter anything out)
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
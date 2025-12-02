import express from "express";
import Appointment from "../models/Appointment.js";

const router = express.Router();

// ✅ GET PATIENT APPOINTMENTS
router.get("/patient/:patientId", async (req, res) => {
  console.log(`--> Received request for Patient Appointments: ${req.params.patientId}`);
  try {
    const appts = await Appointment.find({ patient_id: req.params.patientId })
      .populate("doctor_id")
      .sort({ appointment_date: -1 });
    res.json(appts);
  } catch (err) {
    console.error("--> Error fetching appointments:", err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ CREATE REQUEST
router.post("/request", async (req, res) => {
  console.log("--> Creating new appointment request");
  try {
    const { doctor_id, patient_id, appointment_date, start_time, end_time, type, notes } = req.body;
    
    // إنشاء الموعد مباشرة دون تعقيدات التحقق مؤقتاً لضمان عمل الاتصال
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
    console.error("--> Error creating appointment:", err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
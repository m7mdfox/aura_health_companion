// /routes/appointmentRoutes.js
import express from "express";
import Appointment from "../models/Appointment.js";
import DoctorWeeklySchedule from "../models/DoctorWeeklySchedule.js";
import Doctor from "../models/Doctor.js";
const router = express.Router();

/**
 * Helper: check if given time interval overlaps with other appointments for same doctor on same day
 * times are strings "HH:MM"
 */
function timeToMinutes(t) {
  const [h, m] = t.split(":").map(Number);
  return h * 60 + m;
}
function overlaps(aStart, aEnd, bStart, bEnd) {
  return aStart < bEnd && bStart < aEnd;
}

// Replace the POST /request handler in /routes/appointmentRoutes.js with this:

router.post("/request", async (req, res) => {
  try {
    const { doctor_id, patient_id, appointment_date, start_time, end_time, type, notes } = req.body;
    if (!doctor_id || !patient_id || !appointment_date || !start_time || !end_time) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const apptDate = new Date(appointment_date);
    if (isNaN(apptDate.getTime())) return res.status(400).json({ error: "Invalid appointment_date" });

    // ensure doctor exists
    const doctor = await Doctor.findById(doctor_id);
    if (!doctor) return res.status(404).json({ error: "Doctor not found" });

    // Helper convert HH:MM -> minutes
    function timeToMinutes(t) {
      const [h, m] = t.split(":").map(Number);
      return h * 60 + m;
    }
    function overlaps(aStart, aEnd, bStart, bEnd) {
      return aStart < bEnd && bStart < aEnd;
    }

    // Server-side fixed slot policy (NO DoctorWeeklySchedule)
    // Clinic hours (change if needed) — in minutes from midnight
    const CLINIC_OPEN = timeToMinutes("09:00");
    const CLINIC_CLOSE = timeToMinutes("17:00");

    // Determine duration (minutes) based on appointment type
    const dur = (type === "examination")
      ? (doctor.duration_of_examination || 20)
      : (doctor.duration_of_consultation || 30);

    const reqStart = timeToMinutes(start_time);
    const reqEnd = timeToMinutes(end_time);

    // Basic sanity
    if (reqStart >= reqEnd) return res.status(400).json({ error: "start_time must be before end_time" });
    if (reqEnd - reqStart !== dur) return res.status(400).json({ error: `Appointment length must be exactly ${dur} minutes` });

    // Must be within clinic hours
    if (reqStart < CLINIC_OPEN || reqEnd > CLINIC_CLOSE) {
      return res.status(400).json({ error: "Requested time is outside clinic hours" });
    }

    // Enforce alignment to slot grid: start_time must be CLINIC_OPEN + n * dur OR a step (e.g., 30m)
    // You can also allow fixed steps like 15 minutes; here we'll require alignment with dur from clinic open.
    const offsetFromOpen = reqStart - CLINIC_OPEN;
    if (offsetFromOpen % dur !== 0) {
      return res.status(400).json({ error: `Start time must align to ${dur}-minute slots beginning at 09:00` });
    }

    // Check overlap with existing appointments for this doctor on same day
    const startOfDay = new Date(apptDate);
    startOfDay.setHours(0,0,0,0);
    const endOfDay = new Date(apptDate);
    endOfDay.setHours(23,59,59,999);

    const existing = await Appointment.find({
      doctor_id,
      appointment_date: { $gte: startOfDay, $lte: endOfDay },
      status: { $in: ["requested", "confirmed"] }
    });

    for (const e of existing) {
      if (overlaps(reqStart, reqEnd, timeToMinutes(e.start_time), timeToMinutes(e.end_time))) {
        return res.status(409).json({ error: "Requested time conflicts with another appointment." });
      }
    }

    // Create appointment with status "requested"
    const appt = new Appointment({
      doctor_id,
      patient_id,
      appointment_date: apptDate,
      start_time,
      end_time,
      type: type || "examination",
      status: "requested",
      notes
    });

    await appt.save();
    res.status(201).json(appt);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});


// Doctor confirms / rejects / cancels an appointment
router.put("/:id/status", async (req, res) => {
  try {
    const { status } = req.body; // expected: confirmed, rejected, cancelled, completed
    if (!["confirmed", "rejected", "cancelled", "completed"].includes(status)) {
      return res.status(400).json({ error: "Invalid status" });
    }
    const appt = await Appointment.findById(req.params.id);
    if (!appt) return res.status(404).json({ error: "Appointment not found" });

    appt.status = status;
    await appt.save();
    res.json(appt);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get appointments for a patient
router.get("/patient/:patientId", async (req, res) => {
  try {
    const appts = await Appointment.find({ patient_id: req.params.patientId }).populate("doctor_id").sort({ appointment_date: -1 });
    res.json(appts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get appointments for a doctor
router.get("/doctor/:doctorId", async (req, res) => {
  try {
    const appts = await Appointment.find({ doctor_id: req.params.doctorId }).populate("patient_id").sort({ appointment_date: -1 });
    res.json(appts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;

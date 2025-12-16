import express from "express";
import jwt from "jsonwebtoken"; // For generating tokens
import Doctor from "../models/Doctor.js";

const router = express.Router();

// ----------------------
// 1. DOCTOR LOGIN (Plain Text Version)
// ----------------------
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    // A. Check if doctor exists
    const doctor = await Doctor.findOne({ email });
    if (!doctor) {
      return res.status(404).json({ error: "Doctor not found" });
    }

    // B. Compare password directly (Plain Text)
    if (password !== doctor.password) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    // C. Generate Token
    const token = jwt.sign(
      { id: doctor._id, role: "doctor" },
      process.env.JWT_SECRET || "fallback_secret",
      { expiresIn: "30d" }
    );

    // D. Return token and doctor info (excluding password)
    const { password: _, ...doctorData } = doctor.toObject();

    res.status(200).json({
      token,
      doctor: doctorData
    });

  } catch (err) {
    console.error("Login Error:", err);
    res.status(500).json({ error: err.message });
  }
});

// ----------------------
// 2. CREATE DOCTOR (Registration)
// ----------------------
router.post("/", async (req, res) => {
  try {
    // We save the body directly without hashing the password (as per your request)
    const doc = new Doctor(req.body);

    await doc.save();

    const { password: _, ...savedDoc } = doc.toObject();
    res.status(201).json(savedDoc);

  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ----------------------
// 3. GET DOCTORS (Merged Route)
// ----------------------
// Handles both "Get All" and "Filter by Name/Specialty"
router.get("/", async (req, res) => {
  console.log("--> Received request for Doctors"); 
  try {
    const { specialty, name } = req.query;
    const filter = {};

    // Apply filters if they exist
    if (specialty) filter.specialty = specialty;
    if (name) filter.name = new RegExp(name, "i"); // Case-insensitive regex

    const doctors = await Doctor.find(filter).lean();
    
    console.log(`--> Found ${doctors.length} doctors`);
    res.json(doctors);

  } catch (err) {
    console.error("--> Error finding doctors:", err);
    res.status(500).json({ error: err.message });
  }
});

// ----------------------
// 4. GET SINGLE DOCTOR BY ID
// ----------------------
router.get("/:id", async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id);
    if (!doctor) return res.status(404).json({ error: "Doctor not found" });
    res.json(doctor);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ----------------------
// 5. UPDATE DOCTOR
// ----------------------
router.put("/:id", async (req, res) => {
  try {
    const updated = await Doctor.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;
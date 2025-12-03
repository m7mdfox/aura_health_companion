import express from "express";
import jwt from "jsonwebtoken"; // For generating tokens
import Doctor from "../models/Doctor.js";

// Note: bcrypt import is removed because we are not using hashing anymore
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
    // If your DB has "123456", and user sends "123456", this returns true.
    if (password !== doctor.password) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    // C. Generate Token
    const token = jwt.sign(
      { id: doctor._id, role: "doctor" }, 
      process.env.JWT_SECRET || "fallback_secret", 
      { expiresIn: "30d" }
    );

    // D. Return token and doctor info
    // We remove the password from the response for safety, even if it's plain text in DB
    const { password: _, ...doctorData } = doctor.toObject();
    
    res.status(200).json({
      token,
      doctor: doctorData
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ----------------------
// 2. REGISTER / CREATE (Plain Text Version)
// ----------------------
router.post("/", async (req, res) => {
  try {
    // We save the body directly without hashing the password
    const doc = new Doctor(req.body);

    await doc.save();
    
    const { password: _, ...savedDoc } = doc.toObject();
    res.status(201).json(savedDoc);

  } catch (err) {
    console.error(err);
    res.status(400).json({ error: err.message });
  }
});

// ----------------------
// 3. EXISTING ROUTES
// ----------------------

// Get doctors list
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
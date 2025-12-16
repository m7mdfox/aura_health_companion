import express from "express";
import Profile from "../models/profile.js";
import OTP from "../models/otp.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import mongoose from "mongoose";
import { sendOTP } from "../utils/sendEmail.js";

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || "fallback-secret";

// Generate and send OTP
router.post("/send-otp", async (req, res) => {
  try {
    const { email } = req.body;
    console.log("Received OTP request for email:", email);

    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    // Check if email already exists
    const existingProfile = await Profile.findOne({ email });
    if (existingProfile) {
      console.log("Email already used:", email);
      return res.status(409).json({ error: "Email already used" });
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    console.log(`Generated OTP for ${email}: ${otp}`);

    // Store OTP in MongoDB
    await OTP.deleteOne({ email }); // Remove any existing OTP for this email
    const otpRecord = new OTP({ email, otp });
    await otpRecord.save();
    console.log(`OTP saved for ${email}`);

    // Send OTP via email
    await sendOTP(email, otp);

    res.status(200).json({ message: "OTP sent successfully" });
  } catch (e) {
    console.error("Send OTP error:", e);
    res.status(500).json({ error: `Failed to send OTP: ${e.message}` });
  }
});

// Verify OTP and create account
router.post("/verify-otp", async (req, res) => {
  try {
    const {
      email,
      otp,
      full_name,
      password,
      phone,
      gender,
      birthdate,
      height_cm,
      weight_kg,
      chronic_conditions = [],
      avatar_url = "",
      locale = "en",
    } = req.body;

    console.log("Received OTP verification request:", { email, otp });

    if (!email || !otp || !full_name || !password) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Verify OTP
    const otpRecord = await OTP.findOne({ email });
    if (!otpRecord) {
      console.log("OTP not found or expired for:", email);
      return res.status(400).json({ error: "Invalid or expired OTP" });
    }

    if (otpRecord.otp !== otp) {
      console.log("Invalid OTP for:", email);
      return res.status(400).json({ error: "Invalid OTP" });
    }

    // OTP is valid, delete it
    await OTP.deleteOne({ email });
    console.log("OTP verified and deleted for:", email);

    // Check if email already exists (double-check)
    const existingProfile = await Profile.findOne({ email });
    if (existingProfile) {
      console.log("Email already used:", email);
      return res.status(409).json({ error: "Email already used" });
    }

    // Create profile
    const hashed = await bcrypt.hash(password, 10);
    const auth_id = new mongoose.Types.ObjectId().toString();

    const profile = new Profile({
      auth_id,
      full_name,
      email,
      password: hashed,
      phone,
      gender,
      birthdate,
      height_cm,
      weight_kg,
      chronic_conditions,
      avatar_url,
      locale,
    });

    console.log("Saving profile:", profile);
    await profile.save();
    console.log("Profile saved successfully:", profile._id);

    const token = jwt.sign({ auth_id, email }, JWT_SECRET, { expiresIn: "7d" });

    res.status(201).json({
      token,
      profile: {
        _id: profile._id, // MongoDB document ID - used for appointments
        auth_id,
        full_name,
        email,
        phone,
        gender,
        birthdate,
        height_cm,
        weight_kg,
        chronic_conditions,
        avatar_url,
        locale,
      },
    });
  } catch (e) {
    console.error("Verify OTP error:", e);
    if (e.code === 13297) {
      res.status(500).json({ error: "Database name conflict. Contact support." });
    } else {
      res.status(500).json({ error: `Failed to create user: ${e.message}` });
    }
  }
});

// Login (unchanged)
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log("Login attempt for email:", email);

    const profile = await Profile.findOne({ email });
    if (!profile) {
      console.log("User not found:", email);
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const match = await bcrypt.compare(password, profile.password);
    if (!match) {
      console.log("Invalid password for:", email);
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign({ auth_id: profile.auth_id, email }, JWT_SECRET, {
      expiresIn: "7d",
    });

    console.log("Login successful for:", email);
    res.json({
      token,
      profile: {
        _id: profile._id, // MongoDB document ID - used for appointments
        auth_id: profile.auth_id,
        full_name: profile.full_name,
        email,
        phone: profile.phone,
        gender: profile.gender,
        birthdate: profile.birthdate,
        height_cm: profile.height_cm,
        weight_kg: profile.weight_kg,
        chronic_conditions: profile.chronic_conditions,
        avatar_url: profile.avatar_url,
        locale: profile.locale,
      },
    });
  } catch (e) {
    console.error("Login error:", e);
    res.status(500).json({ error: `Login failed: ${e.message}` });
  }
});

export default router;
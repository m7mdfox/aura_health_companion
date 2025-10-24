import express from "express";
import UserMedicine from "../models/userMedicine.js";
import mongoose from "mongoose";
import jwt from "jsonwebtoken";
import fs from "fs";
import path from "path";

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || "fallback-secret";

// Log current working directory for debugging
console.log("Current working directory:", process.cwd());

// Load interactions JSON file
const interactionsFilePath = path.join(process.cwd(), "assets", "interactions.json");
let interactionsData = [];
try {
  const fileContent = fs.readFileSync(interactionsFilePath, "utf8");
  interactionsData = JSON.parse(fileContent);
  console.log("✅ Interactions JSON loaded successfully. Number of entries:", interactionsData.length);
  console.log("Sample entry:", interactionsData[0]);
} catch (err) {
  console.error("❌ Error loading interactions JSON:", err.message);
  console.error("File path attempted:", interactionsFilePath);
}

// Middleware to verify JWT
const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) {
    return res.status(401).json({ error: "No token provided" });
  }
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // Attach user info (auth_id, email) to request
    next();
  } catch (err) {
    console.error("Token verification error:", err);
    res.status(401).json({ error: "Invalid token" });
  }
};

// Helper function to check for drug interactions
const checkDrugInteractions = (newMedicine, existingMedicines) => {
  if (interactionsData.length === 0) {
    console.warn("No interaction data available for conflict checking");
    return [];
  }
  const conflicts = [];
  const newMedicineLower = newMedicine.trade_name.toLowerCase().trim();
  for (const existingMed of existingMedicines) {
    const existingMedLower = existingMed.trade_name.toLowerCase().trim();
    const interaction = interactionsData.find((i) => {
      const brand1Lower = i.brand1.toLowerCase().trim();
      const brand2Lower = i.brand2.toLowerCase().trim();
      const match =
        (brand1Lower === newMedicineLower && brand2Lower === existingMedLower) ||
        (brand1Lower === existingMedLower && brand2Lower === newMedicineLower);
      if (match) {
        console.log("Interaction match found in checkDrugInteractions:", {
          brand1: i.brand1,
          brand2: i.brand2,
          newMedicine: newMedicine.trade_name,
          existingMed: existingMed.trade_name,
          InteractionDescription: i["Interaction Description"]
        });
      }
      return match;
    });
    if (interaction) {
      conflicts.push({
        conflictingMedicine: existingMed.trade_name,
        description: interaction["Interaction Description"] || "No description available"
      });
    }
  }
  return conflicts;
};

// Add a new medicine with conflict check
router.post("/add-medicine", authMiddleware, async (req, res) => {
  try {
    const {
      trade_name,
      concentration,
      dose,
      frequency,
      duration_days,
      quantity,
      active_ingredient,
    } = req.body;

    console.log("Received add-medicine request:", { trade_name, user_id: req.user.auth_id });

    // Validate required fields
    if (!trade_name || !dose || !frequency || !duration_days || !active_ingredient) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Fetch user's existing medicines
    const existingMedicines = await UserMedicine.find({ user_id: req.user.auth_id });

    // Check for interactions
    const newMedicine = { trade_name };
    const conflicts = checkDrugInteractions(newMedicine, existingMedicines);

    if (interactionsData.length === 0) {
      console.warn("Adding medicine without interaction check due to missing interactions data");
    }

    if (conflicts.length > 0) {
      console.log("Conflicts found for:", trade_name, conflicts);
      return res.status(409).json({
        error: "Medicine conflicts with existing medicines",
        conflicts
      });
    }

    // No conflicts, create new medicine record
    const medicine = new UserMedicine({
      user_id: req.user.auth_id,
      trade_name,
      concentration,
      dose,
      frequency,
      duration_days,
      quantity,
      active_ingredient,
    });

    await medicine.save();
    console.log("Medicine added successfully:", medicine._id);

    res.status(201).json({
      message: "Medicine added successfully",
      medicine: {
        _id: medicine._id,
        trade_name,
        concentration,
        dose,
        frequency,
        duration_days,
        quantity,
        active_ingredient,
      },
    });
  } catch (e) {
    console.error("Add medicine error:", e);
    res.status(500).json({ error: `Failed to add medicine: ${e.message}` });
  }
});

// Check interactions between two medicines (not limited to user's medicines)
router.post("/check-interaction", async (req, res) => {
  try {
    let { medicine1, medicine2 } = req.body;

    console.log("Received interaction check request:", { medicine1, medicine2 });

    // Validate and trim input
    if (!medicine1 || !medicine2) {
      return res.status(400).json({ error: "Both medicine names are required" });
    }

    medicine1 = medicine1.trim().toLowerCase();
    medicine2 = medicine2.trim().toLowerCase();

    // Check if interaction data is loaded
    if (interactionsData.length === 0) {
      console.error("No interaction data available");
      return res.status(500).json({
        interaction: false,
        description: "",
        error: "Interaction data not available. Please contact support."
      });
    }

    // Log input and JSON data for debugging
    console.log("Trimmed inputs:", { medicine1, medicine2 });
    console.log("Interactions data length:", interactionsData.length);

    // Check for interaction with case-insensitive comparison
    const interaction = interactionsData.find((i) => {
      const brand1Lower = i.brand1.toLowerCase().trim();
      const brand2Lower = i.brand2.toLowerCase().trim();
      const match =
        (brand1Lower === medicine1 && brand2Lower === medicine2) ||
        (brand1Lower === medicine2 && brand2Lower === medicine1);
      if (match) {
        console.log("Interaction match found in check-interaction:", {
          brand1: i.brand1,
          brand2: i.brand2,
          medicine1,
          medicine2,
          InteractionDescription: i["Interaction Description"]
        });
      }
      return match;
    });

    if (interaction) {
      console.log("Interaction confirmed:", interaction);
      return res.status(200).json({
        interaction: true,
        description: interaction["Interaction Description"] || "No description available"
      });
    }

    console.log("No interaction found between:", medicine1, medicine2);
    return res.status(200).json({
      interaction: false,
      description: ""
    });
  } catch (e) {
    console.error("Check interaction error:", e);
    return res.status(500).json({
      interaction: false,
      description: "",
      error: `Failed to check interaction: ${e.message}`
    });
  }
});

export default router;
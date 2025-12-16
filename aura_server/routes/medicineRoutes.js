import express from "express";
import UserMedicine from "../models/userMedicine.js";
import MedicineDoseTime from "../models/medicineDoseTime.js";
import mongoose from "mongoose";
import jwt from "jsonwebtoken";
import fs from "fs";
import path from "path";
import pointsService from "../services/pointsService.js";

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || "fallback-secret";

// Log current working directory for debugging
console.log("Current working directory:", process.cwd());

// Load interactions JSON file
const interactionsFilePath = path.join(
  process.cwd(),
  "assets",
  "interactions.json"
);
let interactionsData = [];
try {
  const fileContent = fs.readFileSync(interactionsFilePath, "utf8");
  interactionsData = JSON.parse(fileContent);
  console.log(
    "✅ Interactions JSON loaded successfully. Number of entries:",
    interactionsData.length
  );
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
        (brand1Lower === newMedicineLower &&
          brand2Lower === existingMedLower) ||
        (brand1Lower === existingMedLower && brand2Lower === newMedicineLower);
      if (match) {
        console.log("Interaction match found in checkDrugInteractions:", {
          brand1: i.brand1,
          brand2: i.brand2,
          newMedicine: newMedicine.trade_name,
          existingMed: existingMed.trade_name,
          InteractionDescription: i["Interaction Description"],
        });
      }
      return match;
    });
    if (interaction) {
      conflicts.push({
        conflictingMedicine: existingMed.trade_name,
        description:
          interaction["Interaction Description"] || "No description available",
      });
    }
  }
  return conflicts;
};

// Test route to confirm medicine routes are loaded
router.get("/test", (req, res) => {
  console.log("Medicine test route hit");
  res.status(200).json({ message: "Medicine routes are active" });
});

// Get user's medicines
router.get("/my-medicines", authMiddleware, async (req, res) => {
  console.log("My-medicines route hit");
  try {
    console.log("Fetching medicines for user:", req.user.auth_id);
    const medicines = await UserMedicine.find({ user_id: req.user.auth_id });

    if (!medicines || medicines.length === 0) {
      return res.status(200).json({
        message: "No medicines found for this user",
        medicines: [],
      });
    }

    res.status(200).json({
      message: "Medicines retrieved successfully",
      medicines: medicines.map((med) => ({
        _id: med._id,
        trade_name: med.trade_name,
        concentration: med.concentration,
        dose: med.dose,
        frequency: med.frequency,
        duration_days: med.duration_days,
        quantity: med.quantity,
        active_ingredient: med.active_ingredient,
        dose_times: med.dose_times, // +++ ADDED +++
      })),
    });
  } catch (e) {
    console.error("Get medicines error:", e);
    res.status(500).json({ error: `Failed to fetch medicines: ${e.message}` });
  }
});

// Add a new medicine with conflict check
router.post("/add-medicine", authMiddleware, async (req, res) => {
  console.log("Add-medicine route hit");
  try {
    const {
      trade_name,
      concentration,
      dose,
      frequency,
      duration_days,
      quantity,
      active_ingredient, // This will be undefined or null, which is fine
      dose_times, // +++ ADDED +++
    } = req.body;

    console.log("Received add-medicine request:", {
      trade_name,
      user_id: req.user.auth_id,
      dose_times,
    });

    // Validate required fields
    if (
      !trade_name ||
      !dose ||
      !frequency ||
      !duration_days
      // --- REMOVED --- !active_ingredient
    ) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Fetch user's existing medicines
    const existingMedicines = await UserMedicine.find({
      user_id: req.user.auth_id,
    });

    // Check for interactions
    const newMedicine = { trade_name };
    const conflicts = checkDrugInteractions(newMedicine, existingMedicines);

    if (interactionsData.length === 0) {
      console.warn(
        "Adding medicine without interaction check due to missing interactions data"
      );
    }

    if (conflicts.length > 0) {
      console.log("Conflicts found for:", trade_name, conflicts);
      return res.status(409).json({
        error: "Medicine conflicts with existing medicines",
        conflicts,
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
      active_ingredient, // Will be saved as null/undefined if not provided
      dose_times, // +++ ADDED +++
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
        dose_times: medicine.dose_times, // +++ ADDED +++
      },
    });
  } catch (e) {
    console.error("Add medicine error:", e);
    res.status(500).json({ error: `Failed to add medicine: ${e.message}` });
  }
});

// Update medicine quantity and log dose time
router.put("/update-quantity", authMiddleware, async (req, res) => {
  console.log("Update-quantity route hit:", req.body);
  try {
    const { medicineId, quantity } = req.body;

    // Validate input
    if (!medicineId || quantity == null) {
      return res.status(400).json({ error: "Missing medicineId or quantity" });
    }

    // Validate medicineId format
    if (!mongoose.Types.ObjectId.isValid(medicineId)) {
      return res.status(400).json({ error: "Invalid medicineId format" });
    }

    // Check if medicine exists and belongs to the user
    const medicine = await UserMedicine.findOne({
      _id: medicineId,
      user_id: req.user.auth_id,
    });

    if (!medicine) {
      return res
        .status(404)
        .json({ error: "Medicine not found or does not belong to user" });
    }

    // Prevent negative quantity
    if (quantity < 0) {
      return res.status(400).json({ error: "Quantity cannot be negative" });
    }

    // Update quantity
    medicine.quantity = quantity;
    medicine.updated_at = Date.now();
    await medicine.save();

    // Log dose time in MedicineDoseTime
    const doseTime = new MedicineDoseTime({
      medicine_id: medicineId,
      dose_time: new Date().toISOString(),
    });
    await doseTime.save();

    console.log(
      `Quantity updated for medicine ${medicineId} to ${quantity}, dose time logged`
    );

    // Award points for taking medicine on time
    let pointsAwarded = null;
    try {
      console.log(`🎯 Attempting to award medicine points to: ${req.user.auth_id}`);
      const result = await pointsService.awardMedicineTaken(
        req.user.auth_id,
        medicine.trade_name,
        medicineId
      );
      console.log(`✅ Medicine points awarded successfully:`, result);
      pointsAwarded = {
        points: result.transaction.points,
        action: 'medicine_taken',
        message: `+${result.transaction.points} points for taking ${medicine.trade_name} on time! 💊`,
        newTotal: result.newTotal
      };
      console.log(`🎯 Points awarded for taking medicine: ${medicine.trade_name}, total: ${result.newTotal}`);
    } catch (pointsErr) {
      console.error("❌ Failed to award points for medicine:", pointsErr);
    }

    res.status(200).json({
      message: "Quantity updated successfully",
      medicine: {
        _id: medicine._id,
        trade_name: medicine.trade_name,
        concentration: medicine.concentration,
        dose: medicine.dose,
        frequency: medicine.frequency,
        duration_days: medicine.duration_days,
        quantity: medicine.quantity,
        active_ingredient: medicine.active_ingredient,
        dose_times: medicine.dose_times,
      },
      pointsAwarded,
    });
  } catch (e) {
    console.error("Update quantity error:", e);
    res.status(500).json({ error: `Failed to update quantity: ${e.message}` });
  }
});

// Delete a medicine
router.delete("/delete/:medicineId", authMiddleware, async (req, res) => {
  console.log("Delete-medicine route hit:", req.params);
  try {
    const { medicineId } = req.params;

    // Validate medicineId format
    if (!mongoose.Types.ObjectId.isValid(medicineId)) {
      return res.status(400).json({ error: "Invalid medicineId format" });
    }

    // Delete medicine if it belongs to the user
    const medicine = await UserMedicine.findOneAndDelete({
      _id: medicineId,
      user_id: req.user.auth_id,
    });

    if (!medicine) {
      return res
        .status(404)
        .json({ error: "Medicine not found or does not belong to user" });
    }

    // Optionally delete related dose times
    await MedicineDoseTime.deleteMany({ medicine_id: medicineId });

    console.log(`Medicine ${medicineId} deleted successfully`);
    res.status(200).json({ message: "Medicine deleted successfully" });
  } catch (e) {
    console.error("Delete medicine error:", e);
    res.status(500).json({ error: `Failed to delete medicine: ${e.message}` });
  }
});

// Check interactions between two medicines (not limited to user's medicines)
router.post("/check-interaction", async (req, res) => {
  console.log("Check-interaction route hit");
  try {
    let { medicine1, medicine2 } = req.body;

    console.log("Received interaction check request:", {
      medicine1,
      medicine2,
    });

    // Validate and trim input
    if (!medicine1 || !medicine2) {
      return res
        .status(400)
        .json({ error: "Both medicine names are required" });
    }

    medicine1 = medicine1.trim().toLowerCase();
    medicine2 = medicine2.trim().toLowerCase();

    // Check if interaction data is loaded
    if (interactionsData.length === 0) {
      console.error("No interaction data available");
      return res.status(500).json({
        interaction: false,
        description: "",
        error: "Interaction data not available. Please contact support.",
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
          InteractionDescription: i["Interaction Description"],
        });
      }
      return match;
    });

    if (interaction) {
      console.log("Interaction confirmed:", interaction);
      return res.status(200).json({
        interaction: true,
        description:
          interaction["Interaction Description"] || "No description available",
      });
    }

    console.log("No interaction found between:", medicine1, medicine2);
    return res.status(200).json({
      interaction: false,
      description: "",
    });
  } catch (e) {
    console.error("Check interaction error:", e);
    return res.status(500).json({
      interaction: false,
      description: "",
      error: `Failed to check interaction: ${e.message}`,
    });
  }
});

export default router;
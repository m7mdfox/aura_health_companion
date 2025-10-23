import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
import authRoutes from "./routes/authRoutes.js";

dotenv.config();
const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB connected"))
  .catch((err) => console.error("❌ MongoDB connection error:", err));

// Debug MongoDB connection status
mongoose.connection.on('connected', () => {
  console.log("MongoDB connection established");
});
mongoose.connection.on('error', (err) => {
  console.error("MongoDB connection error:", err);
});
mongoose.connection.on('disconnected', () => {
  console.log("MongoDB disconnected");
});

// Start Server
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
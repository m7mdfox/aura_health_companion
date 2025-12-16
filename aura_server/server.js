// server.js - COMPLETE WITH STATIC FILES & UPLOAD SUPPORT
import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config();

// ✅ Clear cached models safely
Object.keys(mongoose.models).forEach(modelName => {
  delete mongoose.models[modelName];
});

// Clear model schemas if it exists
if (mongoose.connection && mongoose.connection.models) {
  mongoose.connection.models = {};
}

// Now import routes (which will import models)
import authRoutes from "./routes/authRoutes.js";
import medicineRoutes from "./routes/medicineRoutes.js";
import moodRoutes from "./routes/moodRoutes.js";
import nutritionRoutes from "./routes/nutrition.routes.js";
import profileRouter from "./routes/profile.js";
import aiInsightsRoutes from "./routes/aiInsights.js";

const app = express();

// ==================== MIDDLEWARE ====================
// Log all incoming requests for debugging
app.use((req, res, next) => {
  console.log(`📨 ${new Date().toISOString()} - ${req.method} ${req.url}`);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('📦 Body:', JSON.stringify(req.body).substring(0, 200));
  }
  next();
});

// CORS
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true
  })
);

// Body parsing
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// ✅ Static files - Serve uploaded images
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
console.log('📁 Static files directory:', path.join(__dirname, 'uploads'));

// ==================== ROUTES ====================
app.use("/api/auth", authRoutes);
app.use("/api/medicine", medicineRoutes);
app.use("/api/moods", moodRoutes);
app.use("/api/nutrition", nutritionRoutes);
app.use("/api/profile", profileRouter);
app.use("/api/ai-insights", aiInsightsRoutes);

// ==================== TEST ROUTES ====================
// Root route
app.get("/", (req, res) => {
  res.status(200).json({ 
    message: "Aura Health API is running",
    mongodb: mongoose.connection.readyState === 1 ? "connected" : "disconnected",
    timestamp: new Date().toISOString(),
    version: "2.0.0"
  });
});

// Health check
app.get("/health", (req, res) => {
  res.status(200).json({ 
    status: "OK",
    mongodb: mongoose.connection.readyState === 1 ? "connected" : "disconnected",
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

// Test route
app.get("/test", (req, res) => {
  res.status(200).json({ 
    message: "Server is running",
    availableRoutes: [
      "POST /api/auth/signup",
      "POST /api/auth/login",
      "GET /api/profile/me",
      "PATCH /api/profile/update",
      "POST /api/profile/upload-avatar 📸",
      "DELETE /api/profile/delete-avatar",
      "POST /api/nutrition/ask-nutritionist 🔥",
      "POST /api/nutrition/suggest-meal",
      "GET /api/nutrition/...",
    ]
  });
});

// ==================== MONGODB CONNECTION ====================
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("\n✅ MongoDB connected successfully");
    
    // List all registered models
    console.log("\n📋 Registered Mongoose Models:");
    Object.keys(mongoose.models).forEach(modelName => {
      console.log(`   - ${modelName}`);
    });
    
    // List all collections in database
    mongoose.connection.db.listCollections().toArray((err, collections) => {
      if (err) {
        console.error("❌ Error listing collections:", err);
      } else {
        console.log("\n📊 Available MongoDB Collections:");
        collections.forEach(col => {
          console.log(`   - ${col.name}`);
        });
        console.log("");
      }
    });
  })
  .catch((err) => {
    console.error("❌ MongoDB connection error:", err);
    process.exit(1);
  });

// MongoDB connection events
mongoose.connection.on("connected", () => {
  console.log("🔗 MongoDB connection established");
});

mongoose.connection.on("error", (err) => {
  console.error("❌ MongoDB connection error:", err);
});

mongoose.connection.on("disconnected", () => {
  console.log("🔌 MongoDB disconnected");
});

// ==================== ERROR HANDLING ====================
// Error handling middleware
app.use((err, req, res, next) => {
  console.error("❌ Server Error:", err);
  console.error("❌ Stack:", err.stack);
  res.status(500).json({ 
    error: "Internal server error",
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// 404 handler - MUST BE LAST
app.use((req, res) => {
  console.log(`❌ 404 - Route not found: ${req.method} ${req.originalUrl}`);
  res.status(404).json({ 
    error: "Route not found",
    path: req.originalUrl,
    method: req.method,
    availableEndpoints: [
      "/api/auth/*",
      "/api/profile/*",
      "/api/nutrition/*",
      "/api/moods/*",
      "/api/medicine/*",
      "/api/ai-insights/*"
    ]
  });
});

// ==================== START SERVER ====================
const PORT = process.env.PORT || 4000;
app.listen(PORT, '0.0.0.0', () => {
  console.log("\n🚀 ========================================");
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`🔗 Local: http://localhost:${PORT}`);
  console.log(`🔗 Network: http://192.168.1.7:${PORT}`);
  console.log("========================================");
  console.log("\n📋 Available API Routes:");
  console.log("   ├─ /api/auth");
  console.log("   │  ├─ POST /signup");
  console.log("   │  └─ POST /login");
  console.log("   ├─ /api/profile");
  console.log("   │  ├─ GET /me");
  console.log("   │  ├─ PATCH /update");
  console.log("   │  ├─ POST /upload-avatar  📸");
  console.log("   │  └─ DELETE /delete-avatar");
  console.log("   ├─ /api/nutrition");
  console.log("   │  ├─ POST /onboarding");
  console.log("   │  ├─ POST /generate-plan");
  console.log("   │  ├─ POST /ask-nutritionist  🔥 AI Chat");
  console.log("   │  └─ POST /suggest-meal");
  console.log("   ├─ /api/moods");
  console.log("   ├─ /api/medicine");
  console.log("   └─ /api/ai-insights");
  console.log("\n📁 Static Files:");
  console.log(`   └─ /uploads/* (Avatar images)`);
  console.log("\n✨ Press Ctrl+C to stop the server\n");
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('👋 SIGTERM received, closing server gracefully...');
  mongoose.connection.close(() => {
    console.log('✅ MongoDB connection closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\n👋 SIGINT received, closing server gracefully...');
  mongoose.connection.close(() => {
    console.log('✅ MongoDB connection closed');
    process.exit(0);
  });
});
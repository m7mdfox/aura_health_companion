import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
import { Server } from "socket.io"; 
import multer from "multer"; 
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

// 1. IMPORT THE MESSAGE MODEL
import Message from "./models/Message.js"; 

// Import Routes
import authRoutes from "./routes/authRoutes.js";
import medicineRoutes from "./routes/medicineRoutes.js";
import moodRoutes from "./routes/moodRoutes.js";
import nutritionRoutes from "./routes/nutrition.routes.js";
import profileRouter from "./routes/profile.js";
import doctorRoutes from "./routes/doctorRoutes.js";
import appointmentRoutes from "./routes/appointmentRoutes.js";
import scheduleRoutes from "./routes/scheduleRoutes.js";

dotenv.config();

// Fix for __dirname in ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// Ensure 'uploads' directory exists
const uploadDir = path.join(__dirname, "uploads");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

// Log all incoming requests for debugging
app.use((req, res, next) => {
  console.log(`Incoming request: ${req.method} ${req.url}`);
  next();
});

// Middleware
app.use(cors({
  origin: "*", // Allow connections from Flutter (mobile) & JavaFX (desktop)
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json());

// Serve Uploaded Files Statically
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Configure Multer (File Upload Storage)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/"); 
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + "-" + file.originalname);
  },
});
const upload = multer({ storage: storage });

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/medicine", medicineRoutes);
app.use("/api/moods", moodRoutes);
app.use("/api/nutrition", nutritionRoutes);
app.use("/api/profile", profileRouter);
app.use("/api/doctors", doctorRoutes);
app.use("/api/appointments", appointmentRoutes);
app.use("/api/schedules", scheduleRoutes);

// --- NEW ROUTE: Upload Image ---
app.post("/api/upload", upload.single("file"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: "No file uploaded" });
  }
  const fileUrl = `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;
  
  res.status(200).json({ 
    message: "File uploaded successfully", 
    url: fileUrl,
    type: req.file.mimetype 
  });
});

// --- NEW ROUTE: Get Chat History ---
app.get("/api/chat/history/:roomId", async (req, res) => {
  try {
    const { roomId } = req.params;
    // Find messages for this room and sort by oldest first
    const messages = await Message.find({ roomId }).sort({ timestamp: 1 });
    res.status(200).json(messages);
  } catch (err) {
    console.error("Error fetching chat history:", err);
    res.status(500).json({ error: "Could not fetch chat history" });
  }
});

app.get("/test", (req, res) => {
  res.status(200).json({ message: "Server is running" });
});

// MongoDB Connection
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.error("MongoDB connection error:", err));

mongoose.connection.on("connected", () => {
  console.log("MongoDB connection established");
});
mongoose.connection.on("error", (err) => {
  console.error("MongoDB connection error:", err);
});
mongoose.connection.on("disconnected", () => {
  console.log("MongoDB disconnected");
});

// Start Server & Initialize Socket.IO
const PORT = process.env.PORT || 4000;

const server = app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

const io = new Server(server, {
  cors: {
    origin: "*", 
    methods: ["GET", "POST"]
  }
});

// --- UPDATED SOCKET.IO LOGIC ---
io.on("connection", (socket) => {
  console.log(`User Connected: ${socket.id}`);

  // Join Room
  socket.on("join_room", (room) => {
    socket.join(room);
    console.log(`User ${socket.id} joined room: ${room}`);
  });

  // Send Message (AND SAVE TO DB)
  socket.on("send_message", async (data) => {
    console.log("Message received:", data);

    try {
      // 1. Create a new Message document
      const newMessage = new Message({
        roomId: data.room,
        sender: data.sender,
        message: data.message || "",
        imageUrl: data.imageUrl || "",
        type: data.type,
        timestamp: data.timestamp // Use the client's timestamp or let DB default to now
      });

      // 2. Save to MongoDB
      await newMessage.save();
      console.log("Message saved to DB");

      // 3. Broadcast to others in the room
      socket.to(data.room).emit("receive_message", data);

    } catch (err) {
      console.error("Error saving message to DB:", err);
    }
  });

  socket.on("disconnect", () => {
    console.log("User Disconnected", socket.id);
  });
});
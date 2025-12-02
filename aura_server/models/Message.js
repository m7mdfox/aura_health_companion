import mongoose from "mongoose";

const messageSchema = new mongoose.Schema({
  roomId: { type: String, required: true }, // "room_patientID_doctorID"
  sender: { type: String, required: true },
  message: { type: String, default: "" },
  imageUrl: { type: String, default: "" },
  type: { type: String, enum: ["text", "image"], default: "text" },
  timestamp: { type: Date, default: Date.now },
});

export default mongoose.model("Message", messageSchema);
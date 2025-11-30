// middleware/auth_middleware.js
import jwt from "jsonwebtoken";
import Profile from "../models/profile.js";

const JWT_SECRET = process.env.JWT_SECRET || "fallback-secret";

export default async function authMiddleware(req, res, next) {
  try {
    const header = req.headers['authorization'] || req.headers['Authorization'];
    if (!header) return res.status(401).json({ error: "Missing Authorization header" });

    const parts = String(header).split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer')
      return res.status(401).json({ error: "Invalid Authorization header" });

    const token = parts[1];
    const decoded = jwt.verify(token, JWT_SECRET);

    if (!decoded || !decoded.auth_id)
      return res.status(401).json({ error: "Invalid token payload" });

    // جلب البروفايل (اختياري لكن مفيد)
    const profile = await Profile.findOne({ auth_id: decoded.auth_id }).lean();

    // نضمن إن req.user دايمًا فيه auth_id
    req.user = {
      auth_id: decoded.auth_id,
      email: profile?.email || decoded.email || null,
      profile: profile || null
    };

    next();
  } catch (e) {
    console.error("authMiddleware error:", e.message);
    return res.status(401).json({ error: "Unauthorized - Invalid or expired token" });
  }
}

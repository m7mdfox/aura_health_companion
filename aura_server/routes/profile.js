import express from "express";
import Profile from "../models/profile.js";

import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// هذا السطر هو الحل السحري النهائي
const authMiddlewareUrl = new URL("../middlewares/auth_middleware.js", import.meta.url);
const authMiddleware = (await import(authMiddlewareUrl.href)).default;

const router = express.Router();
/**
 * PATCH /api/profile/update
 * تحديث أي حقل أو كل الحقول في الملف الشخصي
 * يدعم تحديث جزئي (partial update)
 */
router.patch("/update", authMiddleware, async (req, res) => {
  // الحقول المسموح بتحديثها
  const allowedFields = [
    "full_name",
    "phone",
    "gender",
    "birthdate",
    "height_cm",
    "weight_kg",
    "chronic_conditions",
    "avatar_url",
    "locale",
  ];

  // نأخذ فقط الحقول المسموحة من الـ body
  const updates = {};
  for (const field of allowedFields) {
    if (req.body[field] !== undefined) {
      updates[field] = req.body[field];
    }
  }

  // إذا ما فيش أي تحديث
  if (Object.keys(updates).length === 0) {
    return res.status(400).json({ error: "لم يتم إرسال أي بيانات للتحديث" });
  }

  // تحقق خاص ببعض الحقول
  if (updates.gender && !["male", "female", "other"].includes(updates.gender)) {
    return res.status(400).json({ error: "الجنس غير صحيح" });
  }
  if (updates.height_cm) {
    const h = Number(updates.height_cm);
    if (isNaN(h) || h < 100 || h > 250)
      return res.status(400).json({ error: "الطول يجب أن يكون بين 100 و 250 سم" });
    updates.height_cm = h;
  }
  if (updates.weight_kg) {
    const w = Number(updates.weight_kg);
    if (isNaN(w) || w < 30 || w > 300)
      return res.status(400).json({ error: "الوزن يجب أن يكون بين 30 و 300 كجم" });
    updates.weight_kg = w;
  }
  if (updates.birthdate) {
    const date = new Date(updates.birthdate);
    if (isNaN(date.getTime()))
      return res.status(400).json({ error: "تاريخ الميلاد غير صحيح" });
    updates.birthdate = date;
  }
  if (updates.chronic_conditions && !Array.isArray(updates.chronic_conditions)) {
    return res.status(400).json({ error: "الأمراض المزمنة يجب أن تكون مصفوفة" });
  }

  try {
    const updatedProfile = await Profile.findOneAndUpdate(
      { auth_id: req.user.auth_id }, // أو req.user.id حسب اللي بتحطه في الـ token
      {
        ...updates,
        updated_at: new Date(), // نضيف حقل تحديث اختياري (لو حابب تضيفه في السكيما)
      },
      { new: true, runValidators: true } // يرجع البيانات بعد التحديث + يشتغل الـ validators
    ).select("-password -__v"); // ما نرجعش الباسورد

    if (!updatedProfile) {
      return res.status(404).json({ error: "الملف الشخصي غير موجود" });
    }

    res.json({
      message: "تم تحديث الملف الشخصي بنجاح",
      profile: updatedProfile,
    });
  } catch (err) {
    console.error("Profile update error:", err);
    res.status(500).json({ error: "حدث خطأ أثناء تحديث الملف الشخصي" });
  }
});

/**
 * GET /api/profile/me
 * جلب بيانات المستخدم الحالي (مفيدة جدًا دايمًا)
 */
router.get("/me", authMiddleware, async (req, res) => {
  try {
    const profile = await Profile.findOne({ auth_id: req.user.auth_id }).select("-password -__v");
    if (!profile) return res.status(404).json({ error: "الملف الشخصي غير موجود" });
    res.json({ profile });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "فشل جلب البيانات" });
  }
});

export default router;
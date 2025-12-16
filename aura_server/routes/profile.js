import express from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";
import { dirname } from "path";
import Profile from "../models/profile.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// استيراد middleware المصادقة
const authMiddlewareUrl = new URL("../middlewares/auth_middleware.js", import.meta.url);
const authMiddleware = (await import(authMiddlewareUrl.href)).default;

const router = express.Router();

// ========================================
// إعداد Multer لرفع الصور
// ========================================
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../uploads/avatars');
    // إنشاء المجلد إذا لم يكن موجوداً
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueName = `avatar-${req.user.auth_id}-${Date.now()}-${Math.floor(Math.random() * 1000000000)}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB حد أقصى
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(new Error('فقط ملفات الصور مسموح بها!'));
    }
  }
});

// ========================================
// POST /api/profile/upload-avatar
// رفع صورة الملف الشخصي
// ========================================
router.post('/upload-avatar', authMiddleware, upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'لم يتم رفع أي ملف' });
    }

    // حذف الصورة القديمة إذا كانت موجودة
    const oldProfile = await Profile.findOne({ auth_id: req.user.auth_id });
    if (oldProfile && oldProfile.avatar_url) {
      const oldPath = path.join(__dirname, '..', oldProfile.avatar_url);
      if (fs.existsSync(oldPath)) {
        try {
          fs.unlinkSync(oldPath);
          console.log('✅ تم حذف الصورة القديمة');
        } catch (err) {
          console.log('⚠️ فشل حذف الصورة القديمة:', err.message);
        }
      }
    }

    // حفظ المسار في قاعدة البيانات
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;
    
    const updatedProfile = await Profile.findOneAndUpdate(
      { auth_id: req.user.auth_id },
      { avatar_url: avatarUrl },
      { new: true }
    ).select('-password -__v');

    if (!updatedProfile) {
      return res.status(404).json({ error: 'الملف الشخصي غير موجود' });
    }

    res.json({ 
      message: 'تم رفع الصورة بنجاح',
      avatar_url: avatarUrl,
      profile: updatedProfile
    });
  } catch (error) {
    console.error('❌ خطأ في رفع الصورة:', error);
    res.status(500).json({ error: error.message });
  }
});

// ========================================
// PATCH /api/profile/update
// تحديث بيانات الملف الشخصي
// ========================================
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
    "blood_type",
    "activity_level",
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
  
  if (updates.activity_level) {
    const validLevels = ["sedentary", "lightly_active", "moderately_active", "very_active", "extra_active"];
    if (!validLevels.includes(updates.activity_level)) {
      return res.status(400).json({ error: "مستوى النشاط غير صحيح" });
    }
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
      { auth_id: req.user.auth_id },
      {
        ...updates,
        updated_at: new Date(),
      },
      { new: true, runValidators: true }
    ).select("-password -__v");

    if (!updatedProfile) {
      return res.status(404).json({ error: "الملف الشخصي غير موجود" });
    }

    res.json({
      message: "تم تحديث الملف الشخصي بنجاح",
      profile: updatedProfile,
    });
  } catch (err) {
    console.error("❌ Profile update error:", err);
    res.status(500).json({ error: "حدث خطأ أثناء تحديث الملف الشخصي" });
  }
});

// ========================================
// GET /api/profile/me
// جلب بيانات المستخدم الحالي
// ========================================
router.get("/me", authMiddleware, async (req, res) => {
  try {
    const profile = await Profile.findOne({ auth_id: req.user.auth_id }).select("-password -__v");
    if (!profile) {
      return res.status(404).json({ error: "الملف الشخصي غير موجود" });
    }
    res.json({ profile });
  } catch (err) {
    console.error("❌ Get profile error:", err);
    res.status(500).json({ error: "فشل جلب البيانات" });
  }
});

// ========================================
// DELETE /api/profile/delete-avatar
// حذف صورة الملف الشخصي
// ========================================
router.delete('/delete-avatar', authMiddleware, async (req, res) => {
  try {
    const profile = await Profile.findOne({ auth_id: req.user.auth_id });
    
    if (!profile) {
      return res.status(404).json({ error: 'الملف الشخصي غير موجود' });
    }

    if (!profile.avatar_url) {
      return res.status(400).json({ error: 'لا توجد صورة لحذفها' });
    }

    // حذف الملف الفعلي
    const avatarPath = path.join(__dirname, '..', profile.avatar_url);
    if (fs.existsSync(avatarPath)) {
      fs.unlinkSync(avatarPath);
    }

    // حذف المسار من قاعدة البيانات
    profile.avatar_url = null;
    await profile.save();

    res.json({ 
      message: 'تم حذف الصورة بنجاح',
      profile: profile
    });
  } catch (error) {
    console.error('❌ خطأ في حذف الصورة:', error);
    res.status(500).json({ error: error.message });
  }
});

export default router;
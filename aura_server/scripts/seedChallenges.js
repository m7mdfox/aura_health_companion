// scripts/seedChallenges.js - Seed sample challenges with progress tracking
import mongoose from "mongoose";
import dotenv from "dotenv";
import Challenge from "../models/Challenge.js";

dotenv.config();

const MONGODB_URI = process.env.MONGO_URI || "mongodb://localhost:27017/aura_health";

const sampleChallenges = [
    // Medication Challenges
    {
        title: "Take 3 Pills",
        title_ar: "تناول 3 حبات",
        description: "Take your medicine 3 times to complete this challenge",
        description_ar: "تناول دوائك 3 مرات لإكمال هذا التحدي",
        points_reward: 50,
        category: "medication",
        difficulty: "easy",
        requirements: { type: "count", target: 3, unit: "doses" },
        action_trigger: "medicine_taken",
        icon: "💊",
        is_active: true,
        sort_order: 1
    },
    {
        title: "Weekly Medicine Master",
        title_ar: "سيد الدواء الأسبوعي",
        description: "Take your medicine 7 times this week",
        description_ar: "تناول دوائك 7 مرات هذا الأسبوع",
        points_reward: 150,
        category: "medication",
        difficulty: "medium",
        requirements: { type: "count", target: 7, unit: "doses" },
        duration_days: 7,
        action_trigger: "medicine_taken",
        icon: "💪",
        is_active: true,
        sort_order: 2
    },
    {
        title: "Medicine Champion",
        title_ar: "بطل الأدوية",
        description: "Take your medicine 14 times in two weeks",
        description_ar: "تناول دوائك 14 مرة في أسبوعين",
        points_reward: 300,
        category: "medication",
        difficulty: "hard",
        requirements: { type: "count", target: 14, unit: "doses" },
        duration_days: 14,
        action_trigger: "medicine_taken",
        icon: "🏆",
        is_active: true,
        sort_order: 3
    },

    // Wellness / Mood Challenges
    {
        title: "Mood Tracker Starter",
        title_ar: "مبتدئ تتبع المزاج",
        description: "Log your mood 3 times",
        description_ar: "سجل مزاجك 3 مرات",
        points_reward: 40,
        category: "wellness",
        difficulty: "easy",
        requirements: { type: "count", target: 3, unit: "logs" },
        action_trigger: "mood_log",
        icon: "😊",
        is_active: true,
        sort_order: 1
    },
    {
        title: "7-Day Mood Journey",
        title_ar: "رحلة المزاج لـ 7 أيام",
        description: "Log your mood for 7 days",
        description_ar: "سجل مزاجك لمدة 7 أيام",
        points_reward: 120,
        category: "wellness",
        difficulty: "medium",
        requirements: { type: "count", target: 7, unit: "days" },
        duration_days: 7,
        action_trigger: "mood_log",
        icon: "🌟",
        is_active: true,
        sort_order: 2
    },
    {
        title: "Mindfulness Master",
        title_ar: "سيد اليقظة",
        description: "Log your mood for 14 consecutive days",
        description_ar: "سجل مزاجك لمدة 14 يوماً متتالياً",
        points_reward: 250,
        category: "wellness",
        difficulty: "hard",
        requirements: { type: "count", target: 14, unit: "days" },
        duration_days: 14,
        action_trigger: "mood_log",
        icon: "🧘",
        is_active: true,
        sort_order: 3
    },

    // Daily Login Challenges
    {
        title: "Welcome Back",
        title_ar: "مرحباً بعودتك",
        description: "Log in 3 days in a row",
        description_ar: "سجل دخولك 3 أيام متتالية",
        points_reward: 30,
        category: "wellness",
        difficulty: "easy",
        requirements: { type: "count", target: 3, unit: "days" },
        action_trigger: "daily_login",
        icon: "👋",
        is_active: true,
        sort_order: 4
    },
    {
        title: "Daily Login Champion",
        title_ar: "بطل تسجيل الدخول اليومي",
        description: "Log in every day for a week",
        description_ar: "سجل دخولك كل يوم لمدة أسبوع",
        points_reward: 100,
        category: "wellness",
        difficulty: "medium",
        requirements: { type: "count", target: 7, unit: "days" },
        duration_days: 7,
        action_trigger: "daily_login",
        icon: "🔥",
        is_active: true,
        sort_order: 5
    },

    // Hydration Challenges
    {
        title: "Hydration Hero",
        title_ar: "بطل الترطيب",
        description: "Reach your water goal 5 times",
        description_ar: "حقق هدف الماء 5 مرات",
        points_reward: 80,
        category: "hydration",
        difficulty: "easy",
        requirements: { type: "count", target: 5, unit: "goals" },
        action_trigger: "water_goal",
        icon: "💧",
        is_active: true,
        sort_order: 1
    },
    {
        title: "10-Day Water Warrior",
        title_ar: "محارب الماء لـ 10 أيام",
        description: "Reach your daily water goal for 10 days",
        description_ar: "حقق هدف الماء اليومي لمدة 10 أيام",
        points_reward: 200,
        category: "hydration",
        difficulty: "hard",
        requirements: { type: "count", target: 10, unit: "days" },
        duration_days: 14,
        action_trigger: "water_goal",
        icon: "🌊",
        is_active: true,
        sort_order: 2
    },

    // Exercise Challenges
    {
        title: "Get Moving",
        title_ar: "ابدأ الحركة",
        description: "Complete 3 exercise sessions",
        description_ar: "أكمل 3 جلسات تمرين",
        points_reward: 60,
        category: "fitness",
        difficulty: "easy",
        requirements: { type: "count", target: 3, unit: "sessions" },
        action_trigger: "exercise",
        icon: "🏃",
        is_active: true,
        sort_order: 1
    },
    {
        title: "Fitness Fighter",
        title_ar: "محارب اللياقة",
        description: "Complete 7 exercise sessions this week",
        description_ar: "أكمل 7 جلسات تمرين هذا الأسبوع",
        points_reward: 180,
        category: "fitness",
        difficulty: "medium",
        requirements: { type: "count", target: 7, unit: "sessions" },
        duration_days: 7,
        action_trigger: "exercise",
        icon: "💪",
        is_active: true,
        sort_order: 2
    }
];

async function seedChallenges() {
    try {
        console.log("🔌 Connecting to MongoDB...");
        await mongoose.connect(MONGODB_URI);
        console.log("✅ Connected to MongoDB");

        // Clear existing challenges (optional - comment out to keep existing)
        // await Challenge.deleteMany({});
        // console.log("🗑️ Cleared existing challenges");

        // Insert challenges (upsert by title to avoid duplicates)
        let inserted = 0;
        let updated = 0;

        for (const challenge of sampleChallenges) {
            const result = await Challenge.findOneAndUpdate(
                { title: challenge.title },
                challenge,
                { upsert: true, new: true }
            );
            if (result.createdAt && result.updatedAt &&
                result.createdAt.getTime() === result.updatedAt.getTime()) {
                inserted++;
            } else {
                updated++;
            }
        }

        console.log(`✅ Seeded ${inserted} new challenges, updated ${updated} existing`);
        console.log("\n📋 Challenges by category:");

        const categories = await Challenge.aggregate([
            { $match: { is_active: true } },
            { $group: { _id: "$category", count: { $sum: 1 } } }
        ]);

        categories.forEach(cat => {
            console.log(`   ${cat._id}: ${cat.count} challenges`);
        });

        console.log("\n🎯 All challenges:");
        const all = await Challenge.find({ is_active: true }).sort({ category: 1, sort_order: 1 });
        all.forEach(c => {
            console.log(`   [${c.category}] ${c.icon} ${c.title} (${c.difficulty}) - ${c.points_reward} pts | trigger: ${c.action_trigger}`);
        });

    } catch (error) {
        console.error("❌ Error seeding challenges:", error);
    } finally {
        await mongoose.disconnect();
        console.log("\n🔌 Disconnected from MongoDB");
    }
}

seedChallenges();

// utils/gemini.js
import { GoogleGenerativeAI } from "@google/generative-ai";
import fetch from "node-fetch";
globalThis.fetch = fetch;

const genAI = new GoogleGenerativeAI("AIzaSyCjiczTIoQcBHu8j6ig-QMcggLG00VSQ-A");
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

export async function generateInsights(mood_type, answers, language = "en") {
  const isArabic = language === "ar";

  const prompt = isArabic
    ? `
أنت مرشد نفسي ذكي، تُقدّم نصائح قصيرة جدًا (سطر واحد أو سطرين فقط).
المزاج: ${mood_type}

الإجابات:
${Object.entries(answers)
  .map(([q, a]) => `• ${q.replace(/_/g, " ")}: ${a}`)
  .join("\n")}

أرجع الرد في صيغة JSON صالحة فقط، بدون أي نص إضافي:

{
  "notes": [
    "ملاحظة قصيرة 1",
    "ملاحظة قصيرة 2",
    "نصيحة سريعة 1",
    "نصيحة سريعة 2",
    "خطوة للغد 1",
    "خطوة للغد 2",
    "متى تطلب المساعدة؟"
  ]
}

- لا تكتب أكثر من 12 كلمة لكل ملاحظة
- استخدم لغة بسيطة ومباشرة
- لا تُكرر، لا تُشرح، فقط الملاحظات
`
    : `
You are an AI emotional coach. Return ONLY valid JSON.

Mood: ${mood_type}
Answers: ${JSON.stringify(answers, null, 2)}

Return:
{
  "notes": [
    "Short note 1",
    "Short note 2",
    "Quick tip 1",
    "Quick tip 2",
    "Tomorrow step 1",
    "Tomorrow step 2",
    "When to seek help?"
  ]
}

Rules:
- Max 12 words per note
- Simple, direct, no fluff
- No extra text outside JSON
`;

  try {
    console.log("Calling Gemini for insights...");
    const result = await model.generateContent(prompt);
    await new Promise(r => setTimeout(r, 1500));

    let text = result?.response?.text() || "";
    console.log("Raw Gemini response:", text);

    // تنظيف النص واستخراج JSON
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("No JSON found in Gemini response");

    const jsonStr = jsonMatch[0];
    const data = JSON.parse(jsonStr);

    if (!data.notes || !Array.isArray(data.notes)) {
      throw new Error("Invalid notes format");
    }

    // تحديد 7 ملاحظات فقط (إذا زادت)
    const notes = data.notes.slice(0, 7).map(note => note.trim());

    return JSON.stringify({ notes }); // نُعيد JSON كـ string للـ API

  } catch (error) {
    console.error("Gemini Error:", error.message);
    // fallback ملاحظات عامة
    const fallback = isArabic
      ? [
          "أنت تشعر بالتوتر حاليًا",
          "خذ نفس عميق الآن",
          "اشرب ماء",
          "امشِ 5 دقائق",
          "راجع مهامك غدًا",
          "رتب أولوياتك",
          "إذا استمر الضغط، استشر مختص"
        ]
      : [
          "You're feeling stressed",
          "Take a deep breath now",
          "Drink water",
          "Walk for 5 mins",
          "Plan tomorrow morning",
          "Prioritize your tasks",
          "Seek help if stress continues"
        ];

    return JSON.stringify({ notes: fallback });
  }
}
// utils/geminiNutrition.js (ENHANCED AI RESPONSE)
import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI("AIzaSyDOmf3BK3RfzPCGxzn3CP9YIjSCx5KE59g");
const WORKING_MODEL = "gemini-2.0-flash";

function calculateTDEE(data) {
  const { age, gender, weightKg, heightCm, activityLevel } = data;

  let bmr;
  if (gender === 'male') {
    bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
  } else {
    bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
  }

  const activityMultipliers = {
    sedentary: 1.2,
    lightly_active: 1.375,
    moderately_active: 1.55,
    very_active: 1.725,
    extra_active: 1.9
  };

  const multiplier = activityMultipliers[activityLevel] || 1.2;
  return Math.round(bmr * multiplier);
}

function calculateTargetCalories(tdee, goalType) {
  const adjustments = {
    lose_weight: -500,
    gain_weight: 300,
    maintain: 0,
    build_muscle: 200
  };

  return Math.round(tdee + (adjustments[goalType] || 0));
}

function calculateMacros(targetCalories, dietType, goalType) {
  let proteinPercent, carbsPercent, fatsPercent;

  switch (dietType) {
    case 'keto':
      proteinPercent = 0.25;
      carbsPercent = 0.05;
      fatsPercent = 0.70;
      break;
    case 'low_carb':
      proteinPercent = 0.30;
      carbsPercent = 0.20;
      fatsPercent = 0.50;
      break;
    case 'balanced':
    default:
      if (goalType === 'build_muscle' || goalType === 'gain_weight') {
        proteinPercent = 0.30;
        carbsPercent = 0.45;
        fatsPercent = 0.25;
      } else {
        proteinPercent = 0.30;
        carbsPercent = 0.40;
        fatsPercent = 0.30;
      }
  }

  return {
    proteinGrams: Math.round((targetCalories * proteinPercent) / 4),
    carbsGrams: Math.round((targetCalories * carbsPercent) / 4),
    fatsGrams: Math.round((targetCalories * fatsPercent) / 9)
  };
}

export async function generateNutritionPlan(userData) {
  try {
    const {
      fullName,
      age,
      gender,
      weightKg,
      heightCm,
      activityLevel,
      goalType,
      dietType,
      ifSchedule,
      chronicDiseases,
      lifestyle,
      eatingRelation,
      mealTimes,
      improvementGoal
    } = userData;

    console.log("🔄 Starting nutrition plan generation for:", fullName);

    const tdee = calculateTDEE({ age, gender, weightKg, heightCm, activityLevel });
    const targetCalories = calculateTargetCalories(tdee, goalType);
    const macros = calculateMacros(targetCalories, dietType, goalType);

    console.log("✅ Calculations:", { tdee, targetCalories, macros });

    const goalTypeArabic = {
      lose_weight: 'خسارة وزن',
      gain_weight: 'زيادة وزن',
      maintain: 'تثبيت وزن',
      build_muscle: 'بناء عضل'
    }[goalType] || goalType;

    const dietTypeArabic = {
      balanced: 'دايت متوازن',
      keto: 'كيتو دايت',
      low_carb: 'لو كارب',
      intermittent_fasting: 'صيام متقطع'
    }[dietType] || dietType;

    const prompt = `أنت خبير تغذية. أنشئ خطة غذائية أسبوعية بصيغة JSON فقط.

معلومات المستخدم:
- الاسم: ${fullName}
- العمر: ${age} | الجنس: ${gender === 'male' ? 'ذكر' : 'أنثى'}
- الوزن: ${weightKg} كجم | الطول: ${heightCm} سم
- النشاط: ${activityLevel}
- الهدف: ${goalTypeArabic}
- الدايت: ${dietTypeArabic}
- السعرات: ${targetCalories}
- البروتين: ${macros.proteinGrams}g | كارب: ${macros.carbsGrams}g | دهون: ${macros.fatsGrams}g

أرجع JSON بالضبط (بدون أي نص إضافي):

{
  "weeklyPlan": [
    {
      "day": 1,
      "dayName": "السبت",
      "meals": {
        "breakfast": {
          "name": "شوفان بالموز",
          "ingredients": ["نصف كوب شوفان", "موزة", "ملعقة عسل"],
          "calories": 350,
          "protein": 12,
          "carbs": 55,
          "fats": 8,
          "preparation": "اخلط واسخّن دقيقتين"
        },
        "lunch": {
          "name": "دجاج مع أرز",
          "ingredients": ["150جم دجاج", "كوب أرز", "سلطة"],
          "calories": 550,
          "protein": 45,
          "carbs": 60,
          "fats": 10,
          "preparation": "شوي الدجاج وسلق الأرز"
        },
        "dinner": {
          "name": "سمك مشوي",
          "ingredients": ["150جم سمك", "بطاطس", "خضار"],
          "calories": 400,
          "protein": 35,
          "carbs": 40,
          "fats": 8,
          "preparation": "شوي في الفرن"
        }
      },
      "totalCalories": 1300,
      "totalProtein": 92,
      "totalCarbs": 155,
      "totalFats": 26
    }
  ],
  "tips": [
    "اشرب 2 لتر ماء",
    "نم 8 ساعات",
    "مارس رياضة"
  ],
  "shoppingList": [
    "شوفان",
    "موز",
    "دجاج",
    "أرز",
    "سمك"
  ]
}

كرر لـ 7 أيام كاملة. نوّع الوجبات. مجموع السعرات قريب من ${targetCalories}.`;

    console.log(`🔄 Using model: ${WORKING_MODEL}`);
    const model = genAI.getGenerativeModel({ 
      model: WORKING_MODEL,
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 8000,
      }
    });

    console.log("🔄 Calling Gemini API...");
    const result = await model.generateContent(prompt);
    const response = await result.response;
    let text = response.text();

    console.log("✅ Response received, length:", text.length);

    text = text
      .replace(/```json\n?/g, '')
      .replace(/```\n?/g, '')
      .trim();
    
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error("No valid JSON found");
    }

    const jsonStr = jsonMatch[0];
    console.log("🔄 Parsing JSON...");
    const nutritionPlan = JSON.parse(jsonStr);

    if (!nutritionPlan.weeklyPlan || !Array.isArray(nutritionPlan.weeklyPlan) || nutritionPlan.weeklyPlan.length === 0) {
      throw new Error("Invalid plan structure");
    }

    console.log("✅ Plan generated successfully!");
    console.log(`📅 Days in plan: ${nutritionPlan.weeklyPlan.length}`);

    return {
      success: true,
      calculations: {
        tdee,
        targetCalories,
        ...macros
      },
      plan: nutritionPlan
    };

  } catch (error) {
    console.error("❌ Error:", error.message);
    throw new Error("فشل توليد الخطة: " + error.message);
  }
}

// ==================== 🆕 SUGGEST MEAL ====================
export async function suggestMeal(userData) {
  try {
    const {
      goalType,
      dietType,
      chronicDiseases,
      remainingCalories,
      availableIngredients
    } = userData;

    const goalTypeArabic = {
      lose_weight: 'خسارة وزن',
      gain_weight: 'زيادة وزن',
      maintain: 'تثبيت وزن',
      build_muscle: 'بناء عضل'
    }[goalType] || goalType;

    const dietTypeArabic = {
      balanced: 'دايت متوازن',
      keto: 'كيتو دايت',
      low_carb: 'لو كارب',
      intermittent_fasting: 'صيام متقطع'
    }[dietType] || dietType;

    const ingredientsText = availableIngredients && availableIngredients.length > 0
      ? `المكونات المتوفرة: ${availableIngredients.join('، ')}`
      : '';

    const chronicDiseasesText = chronicDiseases && chronicDiseases.length > 0
      ? `الأمراض المزمنة: ${chronicDiseases.join('، ')}`
      : '';

    const prompt = `أنت خبير تغذية. المستخدم تبقى له ${remainingCalories} سعرة حرارية اليوم.

معلومات:
- الهدف: ${goalTypeArabic}
- النظام: ${dietTypeArabic}
${chronicDiseasesText}
${ingredientsText}

اقترح وجبة واحدة مناسبة بصيغة JSON فقط (بدون نص إضافي):

{
  "name": "اسم الوجبة",
  "ingredients": ["مكون 1", "مكون 2"],
  "calories": 400,
  "protein": 30,
  "carbs": 40,
  "fats": 10,
  "preparation": "طريقة التحضير",
  "reason": "سبب الاقتراح"
}`;

    const model = genAI.getGenerativeModel({ 
      model: WORKING_MODEL,
      generationConfig: {
        temperature: 0.8,
        maxOutputTokens: 1000,
      }
    });

    const result = await model.generateContent(prompt);
    const response = await result.response;
    let text = response.text();

    text = text
      .replace(/```json\n?/g, '')
      .replace(/```\n?/g, '')
      .trim();
    
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error("No valid JSON found");
    }

    const meal = JSON.parse(jsonMatch[0]);

    return meal;

  } catch (error) {
    console.error("❌ suggestMeal error:", error.message);
    throw new Error("فشل اقتراح الوجبة: " + error.message);
  }
}

// ==================== 🆕 ANSWER NUTRITION QUESTION (ENHANCED) ====================
export async function answerNutritionQuestion(question, context) {
  try {
    console.log('🔄 Starting answerNutritionQuestion');
    console.log('📝 Question:', question);
    console.log('📝 Context:', context);

    const {
      goalType,
      dietType,
      chronicDiseases,
      targetCalories,
      currentWeight
    } = context;

    const goalTypeArabic = {
      lose_weight: 'خسارة وزن',
      gain_weight: 'زيادة وزن',
      maintain: 'تثبيت وزن',
      build_muscle: 'بناء عضل'
    }[goalType] || 'غير محدد';

    const dietTypeArabic = {
      balanced: 'دايت متوازن',
      keto: 'كيتو دايت',
      low_carb: 'لو كارب',
      intermittent_fasting: 'صيام متقطع'
    }[dietType] || 'غير محدد';

    const chronicDiseasesText = chronicDiseases && chronicDiseases.length > 0
      ? `الأمراض المزمنة: ${chronicDiseases.join('، ')}`
      : 'لا يعاني من أمراض مزمنة';

    const prompt = `أنت خبير تغذية محترف. أجب بأسلوب ودي ومختصر.

معلومات المستخدم:
- الهدف: ${goalTypeArabic}
- النظام: ${dietTypeArabic}
- السعرات اليومية: ${targetCalories || 'غير محدد'}
- الوزن: ${currentWeight || 'غير محدد'} كجم
- ${chronicDiseasesText}

سؤال المستخدم: "${question}"

📋 قواعد الإجابة المهمة:
1. اكتب بالعربية البسيطة والواضحة
2. الإجابة لا تزيد عن 4-5 أسطر فقط
3. استخدم الإيموجي مرة واحدة فقط في البداية
4. لا تستخدم رموز markdown (* - #)
5. اكتب نقاط مختصرة وواضحة
6. قدم نصيحة عملية واحدة محددة
7. كن إيجابياً ومشجعاً

مثال للأسلوب المطلوب:
"💡 بالنسبة للمكرونة والدجاج، الدجاج اختيار ممتاز! لكن المكرونة تحتوي كارب عالي.

لإكمال اليوم بشكل صحي:
• وجبتك القادمة: سلطة خضراء كبيرة مع زيت زيتون وأفوكادو
• سناك خفيف: حفنة مكسرات (30 جرام)
• اشرب ماء كثير باقي اليوم

هدفك ${targetCalories} سعرة يومياً، تأكد تكمل باقي احتياجك من البروتين والدهون الصحية."

ابدأ الإجابة مباشرة:`;

    console.log('🔄 Calling Gemini API...');
    const model = genAI.getGenerativeModel({ 
      model: WORKING_MODEL,
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 500,  // 🔥 قللت العدد عشان الرد يبقى أقصر
        topP: 0.9,
        topK: 40,
      }
    });

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const answer = response.text();

    console.log('✅ Got answer from Gemini');
    console.log('📝 Answer length:', answer.length);

    // Clean up the answer - remove ALL markdown
    const cleanAnswer = answer
      .replace(/```json/g, '')
      .replace(/```/g, '')
      .replace(/\*\*/g, '')
      .replace(/\*/g, '')
      .replace(/^#+\s/gm, '')  // Remove headers
      .replace(/^-\s/gm, '• ')  // Convert - to •
      .trim();

    return cleanAnswer;

  } catch (error) {
    console.error('❌ answerNutritionQuestion error:', error);
    console.error('❌ Error stack:', error.stack);
    
    // Return a fallback response instead of throwing
    return `عذراً، حدث خطأ في معالجة سؤالك. 😔

لكن يمكنني مساعدتك بشكل عام:

${getFallbackAnswer(question)}

يرجى المحاولة مرة أخرى أو إعادة صياغة السؤال.`;
  }
}

// Fallback answers for common questions
function getFallbackAnswer(question) {
  const lowerQ = question.toLowerCase();
  
  if (lowerQ.includes('ماء') || lowerQ.includes('شرب')) {
    return '💧 اشرب 2-3 لتر ماء يومياً. احسب وزنك × 30 مل للحصول على احتياجك الدقيق.';
  }
  
  if (lowerQ.includes('بروتين')) {
    return '🥩 احتياجك من البروتين: 1.6-2.2 جرام لكل كيلو من وزنك يومياً إذا كنت تمارس الرياضة.';
  }
  
  if (lowerQ.includes('سكر') || lowerQ.includes('سكري')) {
    return '🍬 قلل السكريات المصنعة، واختر الفواكه الطبيعية بكميات معتدلة. تابع قياس السكر بانتظام.';
  }
  
  if (lowerQ.includes('وجبة') || lowerQ.includes('أكل')) {
    return '🍽️ ركز على البروتين (دجاج، سمك، بيض) + خضروات + كارب معقد (أرز بني، شوفان).';
  }
  
  if (lowerQ.includes('وزن') || lowerQ.includes('تخسيس')) {
    return '⚖️ لخسارة الوزن: عجز سعرات 300-500 + رياضة 3-4 مرات أسبوعياً + نوم كافٍ.';
  }
  
  return '🌟 أهم النصائح: نوّع طعامك، اشرب ماء كثير، نم جيداً، ومارس الرياضة بانتظام.';
}
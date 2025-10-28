// lib/data/questions.dart
enum QuestionType { text, number, true_false, multiple_choice, scale }

class Question {
  final String en;
  final String ar;
  final QuestionType type;
  final String? hintEn;
  final String? hintAr;
  final List<String>? optionsEn; // for multiple_choice
  final List<String>? optionsAr; // for multiple_choice

  const Question({
    required this.en,
    required this.ar,
    required this.type,
    this.hintEn,
    this.hintAr,
    this.optionsEn,
    this.optionsAr,
  });

  String get text => LocaleProvider.currentLocale == 'ar' ? ar : en;
  String get hint => LocaleProvider.currentLocale == 'ar' ? (hintAr ?? '') : (hintEn ?? '');
  List<String> get options => LocaleProvider.currentLocale == 'ar' ? (optionsAr ?? []) : (optionsEn ?? []);
}

class LocaleProvider {
  static String currentLocale = 'en'; // default
}

// ────────────────────── Expanded Mood-Specific Questions ──────────────────────
final Map<String, List<Question>> moodQuestions = {
  'happy': [
    Question(
      en: "What made you happy today?",
      ar: "ما الذي جعلك سعيدًا اليوم؟",
      type: QuestionType.text,
      hintEn: "e.g., I got a promotion, saw a friend",
      hintAr: "مثل: حصلت على ترقية، شفت صديق",
    ),
    Question(
      en: "Who were you with when you felt this joy?",
      ar: "مع من كنت عندما شعرت بهذه الفرحة؟",
      type: QuestionType.text,
      hintEn: "Family, friend, alone, colleague...",
      hintAr: "عائلة، صديق، لوحدي، زميل...",
    ),
    Question(
      en: "How strong is your happiness right now? (1-10)",
      ar: "ما مدى قوة سعادتك الآن؟ (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you laugh out loud today?",
      ar: "هل ضحكت بصوت عالٍ اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did this happiness come suddenly or build up?",
      ar: "هل جاءت هذه السعادة فجأة أم تراكمت؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Suddenly", "Gradually", "From an event", "All day"],
      optionsAr: ["فجأة", "تدريجيًا", "من حدث", "طوال اليوم"],
    ),
    Question(
      en: "Did you share this happiness with someone?",
      ar: "هل شاركت هذه السعادة مع أحد؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How many times did you smile today?",
      ar: "كم مرة ابتسمت اليوم؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Was music, nature, or food involved?",
      ar: "هل كان هناك موسيقى، طبيعة، أو أكل؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Music", "Nature", "Food", "None", "All"],
      optionsAr: ["موسيقى", "طبيعة", "أكل", "لا شيء", "الكل"],
    ),
    Question(
      en: "Do you expect this happiness to last tomorrow?",
      ar: "هل تتوقع أن تستمر هذه السعادة غدًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate your energy level now (1-10)",
      ar: "قيّم مستوى طاقتك الآن (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you feel any physical warmth or lightness?",
      ar: "هل شعرت بدفء أو خفة جسدية؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "What time of day did you feel happiest?",
      ar: "في أي وقت من اليوم شعرت بأكبر سعادة؟",
      type: QuestionType.text,
      hintEn: "Morning, noon, evening...",
      hintAr: "صباحًا، ظهرًا، مساءً...",
    ),
    Question(
      en: "Is this happiness related to achievement or connection?",
      ar: "هل هذه السعادة مرتبطة بإنجاز أم تواصل؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Achievement", "Connection", "Both", "Neither"],
      optionsAr: ["إنجاز", "تواصل", "كلاهما", "لا شيء"],
    ),
    Question(
      en: "Did you take any photos or record this moment?",
      ar: "هل التقطت صور أو سجلت هذه اللحظة؟",
      type: QuestionType.true_false,
    ),
  ],

  'relaxed': [
    Question(
      en: "What helped you feel relaxed today?",
      ar: "ما الذي ساعدك على الشعور بالاسترخاء اليوم؟",
      type: QuestionType.text,
      hintEn: "Meditation, bath, walk, music...",
      hintAr: "تأمل، حمام، مشي، موسيقى...",
    ),
    Question(
      en: "Did you do any breathing exercises?",
      ar: "هل قمت بتمارين التنفس؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How many minutes did you spend relaxing?",
      ar: "كم دقيقة قضيتها في الاسترخاء؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Where were you when you felt most calm?",
      ar: "أين كنت عندما شعرت بأكبر قدر من الهدوء؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Was your breathing slow and deep?",
      ar: "هل كان تنفسك بطيئًا وعميقًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel any muscle relaxation?",
      ar: "هل شعرت باسترخاء عضلي؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate your heart rate now (1-10, 1=very slow)",
      ar: "قيّم معدل نبضك الآن (1-10، 1=بطيء جدًا)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you listen to calming sounds?",
      ar: "هل استمعت لأصوات مهدئة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Were you alone or with someone?",
      ar: "كنت وحدك أم مع شخص؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Alone", "With someone", "In nature", "Doesn't matter"],
      optionsAr: ["وحدي", "مع شخص", "في الطبيعة", "لا يهم"],
    ),
    Question(
      en: "Did you practice mindfulness or meditation?",
      ar: "هل مارست التأمل أو اليقظة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How warm was your body during relaxation?",
      ar: "ما مدى دفء جسمك أثناء الاسترخاء؟ (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you drink herbal tea or water?",
      ar: "هل شربت شاي أعشاب أو ماء؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was the lighting dim or natural?",
      ar: "هل كانت الإضاءة خافتة أم طبيعية؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Dim", "Natural", "Bright", "Dark"],
      optionsAr: ["خافتة", "طبيعية", "ساطعة", "مظلمة"],
    ),
    Question(
      en: "Do you feel ready to sleep now?",
      ar: "هل تشعر أنك جاهز للنوم الآن؟",
      type: QuestionType.true_false,
    ),
  ],

  'anxious': [
    Question(
      en: "What triggered your anxiety today?",
      ar: "ما الذي أثار قلقك اليوم؟",
      type: QuestionType.text,
      hintEn: "Work, future, health, people...",
      hintAr: "عمل، مستقبل، صحة، ناس...",
    ),
    Question(
      en: "On a scale of 1–10, how intense is your anxiety?",
      ar: "على مقياس من 1 إلى 10، ما مدى شدة قلقك؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Are you experiencing any of these? (Check all)",
      ar: "هل تعاني من أي من هذه الأعراض؟ (اختر الكل)",
      type: QuestionType.text,
      hintEn: "Racing heart, sweating, trembling, nausea, dizziness...",
      hintAr: "تسارع نبض، تعرق، رعشة، غثيان، دوخة...",
    ),
    Question(
      en: "Did you use any coping technique?",
      ar: "هل استخدمت أي تقنية للتعامل مع القلق؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Is your mind racing with thoughts?",
      ar: "هل عقلك يسابق بالأفكار؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you avoiding any situation because of anxiety?",
      ar: "هل تتجنب موقف بسبب القلق؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How fast is your breathing right now? (1-10)",
      ar: "ما سرعة تنفسك الآن؟ (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Do you feel tension in chest, neck, or jaw?",
      ar: "هل تشعر بتوتر في الصدر، الرقبة، أو الفك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did anxiety start after a specific event?",
      ar: "هل بدأ القلق بعد حدث معين؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you worried about something that hasn’t happened?",
      ar: "هل قلقك بشأن شيء لم يحدث بعد؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate your muscle tension (1-10)",
      ar: "قيّم توتر عضلاتك (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you try grounding techniques (5-4-3-2-1)?",
      ar: "هل جربت تقنيات التأريض (5-4-3-2-1)؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Is this anxiety familiar or new?",
      ar: "هل هذا القلق مألوف أم جديد؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Familiar", "New", "Worse than usual", "Better than usual"],
      optionsAr: ["مألوف", "جديد", "أسوأ من المعتاد", "أفضل من المعتاد"],
    ),
    Question(
      en: "Did you consume caffeine today?",
      ar: "هل تناولت كافيين اليوم؟",
      type: QuestionType.true_false,
    ),
  ],

  'sad': [
    Question(
      en: "What made you feel sad today?",
      ar: "ما الذي جعلك تشعر بالحزن اليوم؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Did you cry today?",
      ar: "هل بكيت اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How long have you felt this way? (hours)",
      ar: "منذ متى وأنت تشعر بهذه الطريقة؟ (بالساعات)",
      type: QuestionType.number,
    ),
    Question(
      en: "Who can you talk to about this?",
      ar: "من يمكنك التحدث إليه عن هذا؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Do you feel heaviness in your chest?",
      ar: "هل تشعر بثقل في صدرك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Is your appetite lower than usual?",
      ar: "هل شهيتك أقل من المعتاد؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you lose interest in things you usually enjoy?",
      ar: "هل فقدت الاهتمام بأشياء تستمتع بها عادة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate your energy level (1-10)",
      ar: "قيّم مستوى طاقتك (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Are you blaming yourself for something?",
      ar: "هل تلوم نفسك على شيء؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did someone hurt you emotionally?",
      ar: "هل جرحك أحد عاطفيًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Do you feel lonely even around people?",
      ar: "هل تشعر بالوحدة حتى وأنت مع الناس؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How many hours did you sleep last night?",
      ar: "كم ساعة نمت الليلة الماضية؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you avoid social interaction today?",
      ar: "هل تجنبت التفاعل الاجتماعي اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Is this sadness tied to a memory?",
      ar: "هل هذا الحزن مرتبط بذكرى؟",
      type: QuestionType.true_false,
    ),
  ],

  'angry': [
    Question(
      en: "What made you angry today?",
      ar: "ما الذي أغضبك اليوم؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Did you raise your voice?",
      ar: "هل رفعت صوتك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How intense was your anger? (1-10)",
      ar: "ما مدى شدة غضبك؟ (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "What usually helps you cool down?",
      ar: "ما الذي يساعدك عادة على الهدوء؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Did you feel heat in your face or body?",
      ar: "هل شعرت بحرارة في وجهك أو جسمك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you clench your fists or jaw?",
      ar: "هل قبضت قبضتك أو شددت فكك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was this anger justified or exaggerated?",
      ar: "هل كان هذا الغضب مبرر أم مبالغ فيه؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Justified", "Exaggerated", "Both", "Unsure"],
      optionsAr: ["مبرر", "مبالغ فيه", "كلاهما", "غير متأكد"],
    ),
    Question(
      en: "Did you say something you regret?",
      ar: "هل قلت شيئًا نادم عليه؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How fast was your heart beating? (1-10)",
      ar: "ما سرعة نبض قلبك؟ (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you feel the need to move or hit something?",
      ar: "هل شعرت بحاجة للحركة أو ضرب شيء؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you take a break to calm down?",
      ar: "هل أخذت استراحة لتهدأ؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Is this anger about control or injustice?",
      ar: "هل هذا الغضب بسبب السيطرة أم الظلم؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Control", "Injustice", "Betrayal", "Frustration"],
      optionsAr: ["سيطرة", "ظلم", "خيانة", "إحباط"],
    ),
    Question(
      en: "Did you apologize after calming down?",
      ar: "هل اعتذرت بعد الهدوء؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How long did the anger last? (minutes)",
      ar: "كم استمر الغضب؟ (بالدقائق)",
      type: QuestionType.number,
    ),
  ],

  'tired': [
    Question(
      en: "How many hours did you sleep last night?",
      ar: "كم ساعة نمت الليلة الماضية؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Do you feel physically or mentally tired?",
      ar: "هل تشعر بالإرهاق الجسدي أم الذهني؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Physical", "Mental", "Both", "Neither"],
      optionsAr: ["جسدي", "ذهني", "كلاهما", "لا شيء"],
    ),
    Question(
      en: "Did you take a nap today?",
      ar: "هل أخذت قيلولة اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "What’s draining your energy?",
      ar: "ما الذي يستنزف طاقتك؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Do your eyes feel heavy?",
      ar: "هل عيناك ثقيلتان؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you wake up multiple times at night?",
      ar: "هل استيقظت عدة مرات ليلاً؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate your focus level (1-10)",
      ar: "قيّم مستوى تركيزك (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you drink enough water today?",
      ar: "هل شربت ماء كافي اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you sitting or moving a lot?",
      ar: "هل تجلس كثيرًا أم تتحرك؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Mostly sitting", "Moving a lot", "Balanced"],
      optionsAr: ["جالس معظم الوقت", "متحرك كثيرًا", "متوازن"],
    ),
    Question(
      en: "Did you eat heavy or light meals?",
      ar: "هل أكلت وجبات ثقيلة أم خفيفة؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Heavy", "Light", "Skipped", "Normal"],
      optionsAr: ["ثقيلة", "خفيفة", "تخطيت", "عادية"],
    ),
    Question(
      en: "Do you feel muscle soreness?",
      ar: "هل تشعر بألم عضلي؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How many screens did you use today? (hours)",
      ar: "كم ساعة استخدمت الشاشات اليوم؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you exercise today?",
      ar: "هل مارست الرياضة اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Is this tiredness sudden or chronic?",
      ar: "هل هذا الإرهاق مفاجئ أم مزمن؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Sudden", "Chronic", "After effort", "No reason"],
      optionsAr: ["مفاجئ", "مزمن", "بعد مجهود", "بلا سبب"],
    ),
  ],

  'stressed': [
    Question(
      en: "What’s the main source of stress?",
      ar: "ما هو المصدر الرئيسي للتوتر؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Are you experiencing muscle tension?",
      ar: "هل تعاني من توتر عضلي؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How many stressful events today?",
      ar: "كم حدثًا مرهقًا اليوم؟",
      type: QuestionType.number,
    ),
    Question(
      en: "What helps you manage stress?",
      ar: "ما الذي يساعدك على إدارة التوتر؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Do you feel pressure in your head?",
      ar: "هل تشعر بضغط في رأسك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you procrastinating tasks?",
      ar: "هل تؤجل المهام؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate your mental load (1-10)",
      ar: "قيّم الحمل الذهني (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you miss a meal due to stress?",
      ar: "هل فوّت وجبة بسبب التوتر؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Is your to-do list overwhelming?",
      ar: "هل قائمة مهامك مرهقة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel irritable with others?",
      ar: "هل شعرت بالانزعاج من الآخرين؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How many deadlines are you facing?",
      ar: "كم موعد نهائي تواجهه؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you take any breaks today?",
      ar: "هل أخذت استراحات اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Is this stress short-term or ongoing?",
      ar: "هل هذا التوتر قصير الأمد أم مستمر؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Short-term", "Ongoing", "Peak day", "Burnout"],
      optionsAr: ["قصير الأمد", "مستمر", "يوم ذروة", "احتراق"],
    ),
    Question(
      en: "Did you ask for help?",
      ar: "هل طلبت مساعدة؟",
      type: QuestionType.true_false,
    ),
  ],

  'neutral': [
    Question(
      en: "What’s on your mind right now?",
      ar: "ما الذي يشغل بالك الآن؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Did anything notable happen today?",
      ar: "هل حدث شيء ملحوظ اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How was your energy level today? (1-10)",
      ar: "ما مستوى طاقتك اليوم؟ (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "How do you feel about tomorrow?",
      ar: "كيف تشعر تجاه الغد؟",
      type: QuestionType.text,
    ),
    Question(
      en: "Did you feel any emotion strongly today?",
      ar: "هل شعرت بأي عاطفة بقوة اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was your day routine or different?",
      ar: "هل كان يومك روتيني أم مختلف؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Routine", "Different", "Mixed"],
      optionsAr: ["روتيني", "مختلف", "مختلط"],
    ),
    Question(
      en: "Did you achieve any small goal?",
      ar: "هل حققت هدف صغير؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How connected do you feel to others?",
      ar: "ما مدى شعورك بالارتباط بالآخرين؟ (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you learn something new?",
      ar: "هل تعلمت شيئًا جديدًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate your satisfaction with today (1-10)",
      ar: "قيّم رضاك عن اليوم (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you spend time outdoors?",
      ar: "هل قضيت وقت في الهواء الطلق؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you looking forward to anything?",
      ar: "هل تنتظر شيئًا بفارغ الصبر؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How balanced was your day?",
      ar: "ما مدى توازن يومك؟ (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you reflect on your day yet?",
      ar: "هل فكرت في يومك بعد؟",
      type: QuestionType.true_false,
    ),
  ],
};
// lib/data/questions.dart
enum QuestionType { text, number, true_false, multiple_choice, scale }

class Question {
  final String en;
  final String ar;
  final QuestionType type;
  final String? hintEn;
  final String? hintAr;
  final List<String>? optionsEn;
  final List<String>? optionsAr;

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

// ────────────────────── Expanded Mood-Specific Questions (400+ Qs) ──────────────────────
final Map<String, List<Question>> moodQuestions = {
  // ==================== HAPPY (30 Qs) ====================
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
    Question(
      en: "Did you feel grateful for something specific?",
      ar: "هل شعرت بالامتنان لشيء معين؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was this happiness louder or quieter than usual?",
      ar: "هل كانت هذه السعادة أعلى أم أهدأ من المعتاد؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Louder", "Quieter", "Same"],
      optionsAr: ["أعلى", "أهدأ", "نفسها"],
    ),
    Question(
      en: "Did you dance, sing, or jump?",
      ar: "هل رقصت، غنيت، أو قفزت؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did this joy make you more productive?",
      ar: "هل جعلتك هذه الفرحة أكثر إنتاجية؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you receive a compliment or praise?",
      ar: "هل تلقيت مجاملة أو مدح؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was the weather a factor?",
      ar: "هل كان الطقس عاملاً؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you help someone today?",
      ar: "هل ساعدت أحد اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel proud of yourself?",
      ar: "هل شعرت بالفخر بنفسك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How long did this happiness last? (minutes)",
      ar: "كم استمرت هذه السعادة؟ (بالدقائق)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you feel butterflies in your stomach?",
      ar: "هل شعرت بفراشات في معدتك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you share it on social media?",
      ar: "هل شاركتها على السوشيال ميديا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was it a small or big moment?",
      ar: "هل كانت لحظة صغيرة أم كبيرة؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Small", "Big", "Series of small"],
      optionsAr: ["صغيرة", "كبيرة", "سلسلة من الصغيرة"],
    ),
    Question(
      en: "Did you feel more creative?",
      ar: "هل شعرت بإبداع أكثر؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you hug someone?",
      ar: "هل عانقت أحد؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate how contagious your happiness was (1-10)",
      ar: "قيّم مدى عدوى سعادتك (1-10)",
      type: QuestionType.number,
    ),
  ],

  // ==================== RELAXED (28 Qs) ====================
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
    Question(
      en: "Did you stretch or do yoga?",
      ar: "هل مارست تمدد أو يوغا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was there silence or soft background noise?",
      ar: "هل كان هناك صمت أم ضوضاء خلفية ناعمة؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Silence", "Soft noise", "Music", "Nature sounds"],
      optionsAr: ["صمت", "ضوضاء ناعمة", "موسيقى", "أصوات طبيعة"],
    ),
    Question(
      en: "Did you feel heavy or light in your body?",
      ar: "هل شعرت بثقل أم خفة في جسمك؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Heavy", "Light", "Balanced"],
      optionsAr: ["ثقل", "خفة", "متوازن"],
    ),
    Question(
      en: "Did you avoid screens during this time?",
      ar: "هل تجنبت الشاشات خلال هذا الوقت؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was this relaxation planned or spontaneous?",
      ar: "هل كان هذا الاسترخاء مخططًا أم عفويًا؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Planned", "Spontaneous", "Both"],
      optionsAr: ["مخطط", "عفوي", "كلاهما"],
    ),
    Question(
      en: "Did you feel safe and secure?",
      ar: "هل شعرت بالأمان والطمأنينة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you use aromatherapy or scents?",
      ar: "هل استخدمت العلاج بالروائح؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did your thoughts slow down?",
      ar: "هل تباطأت أفكارك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel present in the moment?",
      ar: "هل شعرت بالحضور في اللحظة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How long did this calm feeling last? (minutes)",
      ar: "كم استمر شعور الهدوء؟ (بالدقائق)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you feel any tingling or warmth in hands/feet?",
      ar: "هل شعرت بوخز أو دفء في اليدين/القدمين؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was this the deepest relaxation this week?",
      ar: "هل كان هذا أعمق استرخاء هذا الأسبوع؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel connected to your body?",
      ar: "هل شعرت بالارتباط بجسمك؟",
      type: QuestionType.true_false,
    ),
  ],

  // ==================== ANXIOUS (30 Qs) ====================
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
    Question(
      en: "Do you feel restless or need to move?",
      ar: "هل تشعر بالقلق أو الحاجة للحركة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you overthinking past conversations?",
      ar: "هل تفكر كثيرًا في محادثات سابقة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you check your phone repeatedly?",
      ar: "هل فحصت هاتفك بشكل متكرر؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Do you feel a knot in your stomach?",
      ar: "هل تشعر بعقدة في معدتك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you have trouble falling asleep recently?",
      ar: "هل واجهت صعوبة في النوم مؤخرًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you afraid of losing control?",
      ar: "هل تخاف من فقدان السيطرة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you cancel any plans due to anxiety?",
      ar: "هل ألغيت خطط بسبب القلق؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How many hours did you worry today?",
      ar: "كم ساعة قضيتها في القلق اليوم؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you feel detached or unreal?",
      ar: "هل شعرت بالانفصال أو عدم الواقعية؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you sensitive to noise or light?",
      ar: "هل أنت حساس للضوضاء أو الضوء؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you seek reassurance from others?",
      ar: "هل طلبت طمأنة من الآخرين؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Is this anxiety about health, money, or relationships?",
      ar: "هل هذا القلق بشأن الصحة، المال، أو العلاقات؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Health", "Money", "Relationships", "Other"],
      optionsAr: ["الصحة", "المال", "العلاقات", "أخرى"],
    ),
    Question(
      en: "Did you feel a sudden panic attack?",
      ar: "هل شعرت بنوبة هلع مفاجئة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Do you feel like running away?",
      ar: "هل تشعر برغبة في الهروب؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate how manageable this anxiety feels (1-10)",
      ar: "قيّم مدى قابلية التحكم في هذا القلق (1-10)",
      type: QuestionType.number,
    ),
  ],

  // ==================== SAD (28 Qs) ====================
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
    Question(
      en: "Did you feel empty or numb?",
      ar: "هل شعرت بالفراغ أو الخدر؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Do you feel guilty without reason?",
      ar: "هل تشعر بالذنب بلا سبب؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you listen to sad music?",
      ar: "هل استمعت لموسيقى حزينة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Do you feel like a burden to others?",
      ar: "هل تشعر أنك عبء على الآخرين؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you isolate yourself on purpose?",
      ar: "هل عزلت نفسك عمدًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How intense is this sadness? (1-10)",
      ar: "ما مدى شدة هذا الحزن؟ (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you think about the past a lot?",
      ar: "هل فكرت كثيرًا في الماضي؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Do you feel hopeless about the future?",
      ar: "هل تشعر باليأس من المستقبل؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you skip any meals?",
      ar: "هل فوّتت وجبة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel physical pain with sadness?",
      ar: "هل شعرت بألم جسدي مع الحزن؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you want to be alone or with someone?",
      ar: "هل أردت أن تكون وحدك أم مع شخص؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Alone", "With someone", "Doesn't matter"],
      optionsAr: ["وحدي", "مع شخص", "لا يهم"],
    ),
    Question(
      en: "Did you feel tears without crying?",
      ar: "هل شعرت بالدموع دون بكاء؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did this sadness come in waves?",
      ar: "هل جاء هذا الحزن على شكل موجات؟",
      type: QuestionType.true_false,
    ),
  ],

  // ==================== ANGRY (28 Qs) ====================
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
    Question(
      en: "Did you throw or break anything?",
      ar: "هل رميت أو كسرت شيئًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel rage or irritation?",
      ar: "هل شعرت بالغضب الشديد أم الانزعاج؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Rage", "Irritation", "Both"],
      optionsAr: ["غضب شديد", "انزعاج", "كلاهما"],
    ),
    Question(
      en: "Was this person-specific or general?",
      ar: "هل كان موجهًا لشخص أم عام؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Person", "General", "Situation"],
      optionsAr: ["شخص", "عام", "موقف"],
    ),
    Question(
      en: "Did you feel misunderstood?",
      ar: "هل شعرت بعدم الفهم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you want revenge or resolution?",
      ar: "هل أردت الانتقام أم الحل؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Revenge", "Resolution", "Both", "Neither"],
      optionsAr: ["انتقام", "حل", "كلاهما", "لا شيء"],
    ),
    Question(
      en: "Did you feel your blood pressure rise?",
      ar: "هل شعرت بارتفاع ضغط الدم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you curse or swear?",
      ar: "هل شتمت أو لعنت؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel powerless?",
      ar: "هل شعرت بالعجز؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you storm out of a room?",
      ar: "هل خرجت من غرفة بعنف؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was this anger building up over time?",
      ar: "هل كان هذا الغضب متراكمًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel hot-headed or cold rage?",
      ar: "هل كان غضبًا حارًا أم باردًا؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Hot", "Cold", "Mixed"],
      optionsAr: ["حار", "بارد", "مختلط"],
    ),
    Question(
      en: "Did you write down your feelings?",
      ar: "هل كتبت مشاعرك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate how in control you felt (1-10)",
      ar: "قيّم مدى سيطرتك على نفسك (1-10)",
      type: QuestionType.number,
    ),
  ],

  // ==================== TIRED (28 Qs) ====================
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
    Question(
      en: "Did you feel foggy or confused?",
      ar: "هل شعرت بالضبابية أو الارتباك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you yawn frequently?",
      ar: "هل تثاءبت كثيرًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel cold or low body temperature?",
      ar: "هل شعرت بالبرد أو انخفاض درجة الحرارة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you skip caffeine or sugar?",
      ar: "هل تخطيت الكافيين أو السكر؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you emotionally drained?",
      ar: "هل أنت مستنزف عاطفيًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel heavy limbs?",
      ar: "هل شعرت بثقل في الأطراف؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you have trouble getting out of bed?",
      ar: "هل واجهت صعوبة في النهوض من السرير؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How many tasks did you postpone?",
      ar: "كم مهمة أجلتها؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you feel irritable due to tiredness?",
      ar: "هل شعرت بالانزعاج بسبب التعب؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel dizzy or lightheaded?",
      ar: "هل شعرت بالدوار؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was your sleep quality poor?",
      ar: "هل كانت جودة نومك سيئة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel unmotivated all day?",
      ar: "هل شعرت بعدم الدافعية طوال اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate how rested you feel (1-10)",
      ar: "قيّم مدى شعورك بالراحة (1-10)",
      type: QuestionType.number,
    ),
  ],

  // ==================== STRESSED (30 Qs) ====================
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
    Question(
      en: "Do you feel overwhelmed by choices?",
      ar: "هل تشعر بالإرهاق من الخيارات؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel rushed all day?",
      ar: "هل شعرت بالعجلة طوال اليوم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you overcommitting?",
      ar: "هل تُفرط في الالتزامات؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel chest tightness?",
      ar: "هل شعرت بضيق في الصدر؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you forget something important?",
      ar: "هل نسيت شيئًا مهمًا؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Are you worried about money?",
      ar: "هل قلقك بشأن المال؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel time slipping away?",
      ar: "هل شعرت أن الوقت يمر بسرعة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you snap at someone?",
      ar: "هل انفعلت على أحد؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "How many tabs are open in your mind?",
      ar: "كم تبويب مفتوح في عقلك؟",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you feel paralyzed by decisions?",
      ar: "هل شعرت بالشلل بسبب القرارات؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel a headache coming?",
      ar: "هل شعرت بصداع قادم؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you drink more coffee than usual?",
      ar: "هل شربت قهوة أكثر من المعتاد؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Do you feel behind on everything?",
      ar: "هل تشعر أنك متأخر في كل شيء؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate how in control you feel (1-10)",
      ar: "قيّم مدى شعورك بالسيطرة (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you say 'I can't' today?",
      ar: "هل قلت 'لا أستطيع' اليوم؟",
      type: QuestionType.true_false,
    ),
  ],

  // ==================== NEUTRAL (25 Qs) ====================
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
    Question(
      en: "Did you feel bored at any point?",
      ar: "هل شعرت بالملل في أي لحظة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel neutral or just 'okay'?",
      ar: "هل شعرت بـ'محايد' أم 'بخير فقط'؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Neutral", "Okay", "Empty"],
      optionsAr: ["محايد", "بخير", "فارغ"],
    ),
    Question(
      en: "Did you have any deep thoughts?",
      ar: "هل كان لديك أفكار عميقة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Was your mind quiet or busy?",
      ar: "هل كان عقلك هادئًا أم مشغولًا؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Quiet", "Busy", "Balanced"],
      optionsAr: ["هادئ", "مشغول", "متوازن"],
    ),
    Question(
      en: "Did you feel in control of your day?",
      ar: "هل شعرت بسيطرة على يومك؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel time passed normally?",
      ar: "هل مر الوقت بشكل طبيعي؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel any physical sensation strongly?",
      ar: "هل شعرت بأي إحساس جسدي بقوة؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Did you feel present or distracted?",
      ar: "هل شعرت بالحضور أم التشتت؟",
      type: QuestionType.multiple_choice,
      optionsEn: ["Present", "Distracted", "Mixed"],
      optionsAr: ["حاضر", "مشتت", "مختلط"],
    ),
    Question(
      en: "Did you feel any subtle emotion?",
      ar: "هل شعرت بعاطفة خفية؟",
      type: QuestionType.true_false,
    ),
    Question(
      en: "Rate how 'alive' you felt today (1-10)",
      ar: "قيّم مدى شعورك بـ'الحياة' اليوم (1-10)",
      type: QuestionType.number,
    ),
    Question(
      en: "Did you feel the day was meaningful?",
      ar: "هل شعرت أن اليوم كان له معنى؟",
      type: QuestionType.true_false,
    ),
  ],
};
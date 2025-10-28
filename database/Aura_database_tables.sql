
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Profiles (linked to auth.users)
CREATE TABLE profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id uuid UNIQUE, -- link to auth.users.id
  full_name text,
  phone text,
  gender text,
  birthdate date,
  height_cm numeric(5,2),
  weight_kg numeric(6,2),
  chronic_conditions text[], -- e.g. ['diabetes','hypertension ']
  avatar_url text,
  locale text DEFAULT 'ar',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Devices / Watch
CREATE TABLE devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  device_name text,
  device_type text, -- e.g. 'watch','phone'
  vendor text,
  model text,
  connected_at timestamptz,
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);

-- Time-series vitals (heartbeat, spo2, sleep_quality, calories...)
CREATE TABLE vitals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  device_id uuid REFERENCES devices(id),
  vital_type text NOT NULL, -- e.g. 'heart_rate','spo2','sleep_quality','calories'
  value numeric NOT NULL,
  unit text,
  recorded_at timestamptz NOT NULL,
  source jsonb, -- raw payload from watch
  processed boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);
CREATE INDEX idx_vitals_profile_time ON vitals(profile_id, recorded_at DESC);
CREATE INDEX idx_vitals_type_time ON vitals(vital_type, recorded_at DESC);

-- Medicines catalog
CREATE TABLE medicines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  brand text,
  active_ingredient text NOT NULL,
  atc_code text, -- optional classification
  form text, -- e.g. 'tablet','capsule','syrup'
  strength text, -- e.g. '500 mg'
  default_dose text, -- description
  description text,
  created_at timestamptz DEFAULT now()
);

-- User's medicines (what user is taking/has)
CREATE TABLE user_medicines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  medicine_id uuid REFERENCES medicines(id) ON DELETE RESTRICT,
  start_date date,
  end_date date,
  dose text, -- e.g. '1 tablet'
  frequency text, -- e.g. '2 times/day'
  quantity_left integer, -- number of pills left
  requires_prescription boolean DEFAULT false,
  prescription_url text, -- storage URL
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
CREATE INDEX idx_user_meds_profile ON user_medicines(profile_id);

-- Medicine interactions (pairwise)
CREATE TABLE medicine_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  med_a uuid REFERENCES medicines(id) ON DELETE CASCADE,
  med_b uuid REFERENCES medicines(id) ON DELETE CASCADE,
  severity text, -- 'low','moderate','high'
  description text,
  created_at timestamptz DEFAULT now(),
  UNIQUE (med_a, med_b)
);
-- ensure symmetric lookup (we'll query both directions). You can add constraint that med_a < med_b if desired.

-- Medicine alternatives (same active ingredient)
CREATE TABLE medicine_alternatives (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  medicine_id uuid REFERENCES medicines(id) ON DELETE CASCADE,
  alternative_id uuid REFERENCES medicines(id) ON DELETE CASCADE,
  notes text
);

-- Doses taken (for animation & tracking)
CREATE TABLE doses_taken (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_medicine_id uuid REFERENCES user_medicines(id) ON DELETE CASCADE,
  taken_at timestamptz DEFAULT now(),
  amount text,
  device_event jsonb,
  created_at timestamptz DEFAULT now()
);

-- Medication orders (online order)
CREATE TABLE medicine_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  medicine_id uuid REFERENCES medicines(id),
  quantity integer,
  address text,
  requires_prescription boolean DEFAULT false,
  prescription_url text,
  status text DEFAULT 'pending', -- pending, confirmed, shipped, delivered, cancelled
  placed_at timestamptz DEFAULT now()
);

-- Reminders (meds, water, exercise, prayer, etc.)
CREATE TABLE reminders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  title text,
  type text, -- 'medicine','water','exercise','sleep','prayer',...
  schedule jsonb, -- e.g. {"cron":"0 9 * * *"} or {"every":"day","time":"09:00"}
  medicine_id uuid REFERENCES medicines(id),
  active boolean DEFAULT true,
  last_sent timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Notifications
CREATE TABLE notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  title text,
  body text,
  payload jsonb,
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Mental health assessments (question sets)
CREATE TABLE mh_assessments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text,
  description text,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE mh_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assessment_id uuid REFERENCES mh_assessments(id) ON DELETE CASCADE,
  question_text text,
  question_type text DEFAULT 'mcq', -- 'mcq','truefalse','scale'
  options jsonb, -- for mcq
  weight numeric DEFAULT 1
);

-- User responses to mental health assessments
CREATE TABLE mh_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  assessment_id uuid REFERENCES mh_assessments(id),
  responses jsonb, -- e.g. [{question_id:..., answer:...},...]
  score numeric,
  created_at timestamptz DEFAULT now()
);

-- Recommendations for mental health (link to content)
CREATE TABLE mh_recommendations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  condition text,
  content_type text, -- 'exercise','video','podcast','quran','chatbot'
  content jsonb, -- urls, texts, reciter choices...
  created_at timestamptz DEFAULT now()
);

-- Nutrition plans & meals
CREATE TABLE nutrition_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  goal text, -- 'lose_weight','maintain','gain'
  notes text,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE meals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id uuid REFERENCES nutrition_plans(id) ON DELETE CASCADE,
  name text,
  time_of_day text,
  calories numeric,
  macros jsonb, -- {protein:..,carbs:..,fat:..}
  recipe jsonb,
  created_at timestamptz DEFAULT now()
);

-- Fasting tracking
CREATE TABLE fasting_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  start_time timestamptz,
  end_time timestamptz,
  duration_minutes integer,
  created_at timestamptz DEFAULT now()
);

-- Fitness plans/exercises
CREATE TABLE fitness_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  title text,
  mode text, -- 'home','gym'
  split text, -- 'push-pull-legs','full-body',...
  goal text,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id uuid REFERENCES fitness_plans(id) ON DELETE CASCADE,
  name text,
  sets integer,
  reps text,
  rest_seconds integer,
  notes text
);
CREATE TABLE exercise_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  exercise_id uuid REFERENCES exercises(id),
  feedback jsonb, -- e.g. {form_ok: true, comments: "..."}
  created_at timestamptz DEFAULT now()
);

-- Emergency contacts + events
CREATE TABLE emergency_contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  name text,
  phone text,
  relation text,
  notify_on_event boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE emergency_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  event_type text, -- 'fall','arrhythmia','possible_stroke',...
  detected_at timestamptz DEFAULT now(),
  vitals_snapshot jsonb,
  location jsonb, -- {lat:..,lng:..,address:..}
  notified boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Genetic reports
CREATE TABLE genetic_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  report_url text, -- storage URL
  uploaded_at timestamptz DEFAULT now(),
  parsed_results jsonb, -- structured risk findings
  processed boolean DEFAULT false
);
CREATE TABLE genetic_findings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id uuid REFERENCES genetic_reports(id) ON DELETE CASCADE,
  gene text,
  risk text,
  details jsonb
);

-- Community: posts/comments
CREATE TABLE posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  title text,
  body text,
  media jsonb,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid REFERENCES posts(id) ON DELETE CASCADE,
  profile_id uuid REFERENCES profiles(id),
  body text,
  created_at timestamptz DEFAULT now()
);

-- Challenges & gamification
CREATE TABLE challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text,
  description text,
  start_date date,
  end_date date,
  reward jsonb,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE user_challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id uuid REFERENCES challenges(id) ON DELETE CASCADE,
  profile_id uuid REFERENCES profiles(id),
  progress jsonb,
  points integer DEFAULT 0,
  joined_at timestamptz DEFAULT now()
);
CREATE TABLE leaderboard (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  metric text, -- 'steps','points'
  value numeric,
  updated_at timestamptz DEFAULT now()
);

-- Doctors, schedules, consultations
CREATE TABLE doctors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text,
  specialty text,
  bio text,
  phone text,
  clinic_address text,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE doctor_schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id uuid REFERENCES doctors(id) ON DELETE CASCADE,
  day_of_week integer, -- 0..6
  start_time time,
  end_time time,
  timezone text DEFAULT 'Africa/Cairo'
);
CREATE TABLE consultations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  doctor_id uuid REFERENCES doctors(id),
  scheduled_at timestamptz,
  duration_minutes integer,
  status text DEFAULT 'scheduled', -- scheduled,ongoing,completed,cancelled
  notes text,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE consultation_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  consultation_id uuid REFERENCES consultations(id) ON DELETE CASCADE,
  sender text, -- 'patient' or 'doctor' or 'system'
  body text,
  attachments jsonb,
  created_at timestamptz DEFAULT now()
);

-- Admins & audit logs
CREATE TABLE admins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id uuid UNIQUE,
  role text,
  created_at timestamptz DEFAULT now()
);
CREATE TABLE audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id uuid,
  actor_type text,
  action text,
  table_name text,
  record_id uuid,
  diff jsonb,
  created_at timestamptz DEFAULT now()
);
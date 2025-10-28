// aura_server/utils/testGemini.js
import { generateInsights } from './gemini.js';

const answers = {
  what_made_you_happy_today: 'الشمس والقهوة',
  how_strong_is_your_happiness_right_now: '7',
  did_you_laugh_out_loud_today: false,
};

console.log('جاري توليد التحليل...\n');

generateInsights('happy', answers, 'ar')
  .then(result => {
    console.log('✅ النتيجة من Gemini:\n');
    console.log(result);
  })
  .catch(err => {
    console.error('❌ خطأ في Gemini:', err.message);
    if (err.response) console.error(err.response.data);
  });

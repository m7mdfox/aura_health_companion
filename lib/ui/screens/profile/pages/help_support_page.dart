import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I connect my smartwatch?',
      answer: 'Go to Profile > Connected Devices > Tap on your device > Turn on the connection toggle. Make sure Bluetooth is enabled on your phone.',
      category: 'Devices',
    ),
    FAQItem(
      question: 'How can I set medicine reminders?',
      answer: 'Navigate to Medicines section, add your medicine with dosage details, and set reminder times. You\'ll receive notifications at scheduled times.',
      category: 'Medicines',
    ),
    FAQItem(
      question: 'Can I track multiple health metrics?',
      answer: 'Yes! You can track heart rate, sleep quality, steps, calories, water intake, mood, and more through your connected smartwatch and manual entries.',
      category: 'Health Tracking',
    ),
    FAQItem(
      question: 'How do I create a nutrition plan?',
      answer: 'Go to Nutrition section, complete the onboarding questionnaire with your goals, and our AI will generate a personalized meal plan for you.',
      category: 'Nutrition',
    ),
    FAQItem(
      question: 'Is my health data secure?',
      answer: 'Absolutely! All your health data is encrypted end-to-end. We follow HIPAA compliance standards and never share your data without explicit consent.',
      category: 'Privacy',
    ),
    FAQItem(
      question: 'How can I contact a doctor?',
      answer: 'You can book appointments through the app. Go to Services > Find Doctors, select your specialty, choose a doctor, and book a time slot.',
      category: 'Appointments',
    ),
  ];

  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Devices',
    'Medicines',
    'Health Tracking',
    'Nutrition',
    'Privacy',
    'Appointments',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredFAQs = _selectedCategory == 'All'
        ? _faqs
        : _faqs.where((faq) => faq.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [const Color(0xFF1A1D2E), const Color(0xFF0F1120)]
                : [const Color(0xFF00177E), const Color(0xFF0F1120)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildQuickActionsCard(isDark),
          const SizedBox(height: 20),
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          _buildCategoryFilter(isDark),
          const SizedBox(height: 15),
          ...filteredFAQs.map((faq) => _buildFAQCard(faq, isDark)),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Need Help?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you\'d like to get support',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.email,
                  label: 'Email Us',
                  color: const Color(0xFF2196F3),
                  onTap: _contactEmail,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.phone,
                  label: 'Call Us',
                  color: const Color(0xFF4CAF50),
                  onTap: _contactPhone,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.chat,
                  label: 'Live Chat',
                  color: const Color(0xFF9C27B0),
                  onTap: _openLiveChat,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.bug_report,
                  label: 'Report Bug',
                  color: const Color(0xFFE91E63),
                  onTap: _reportBug,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? const Color(0xFF00177E)
                  : isDark ? const Color(0xFF1A1D2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                    ? const Color(0xFF00177E)
                    : isDark ? Colors.white24 : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                      ? Colors.white
                      : isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faq, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            faq.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
                  const SizedBox(height: 10),
                  Text(
                    faq.answer,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactEmail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact via Email'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You can reach us at:'),
            SizedBox(height: 10),
            SelectableText(
              'support@aurahealth.com',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF00177E),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening email app...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00177E),
            ),
            child: const Text('Open Email'),
          ),
        ],
      ),
    );
  }

  void _contactPhone() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact via Phone'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Call us at:'),
            SizedBox(height: 10),
            SelectableText(
              '+20 123 456 7890',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Available: 9 AM - 6 PM (Sun-Thu)',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening phone app...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _openLiveChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live Chat - Coming Soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _reportBug() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bug Report Form - Coming Soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}
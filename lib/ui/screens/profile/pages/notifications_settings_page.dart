import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  // Notification toggles
  bool _medicineReminders = true;
  bool _waterReminders = true;
  bool _sleepReminders = true;
  bool _exerciseReminders = false;
  bool _mealReminders = true;
  bool _appointmentReminders = true;
  bool _healthInsights = true;
  bool _communityUpdates = false;
  bool _achievementAlerts = true;
  
  // Sound & Vibration
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // Quiet hours
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Notifications'),
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
          _buildSection(
            title: 'Health Reminders',
            icon: Icons.favorite,
            color: const Color(0xFFE91E63),
            children: [
              _buildSwitchTile(
                title: 'Medicine Reminders',
                subtitle: 'Get notified to take your medicines',
                value: _medicineReminders,
                onChanged: (value) => setState(() => _medicineReminders = value),
                isDark: isDark,
              ),
              _buildSwitchTile(
                title: 'Water Reminders',
                subtitle: 'Stay hydrated throughout the day',
                value: _waterReminders,
                onChanged: (value) => setState(() => _waterReminders = value),
                isDark: isDark,
              ),
              _buildSwitchTile(
                title: 'Sleep Reminders',
                subtitle: 'Reminder to maintain sleep schedule',
                value: _sleepReminders,
                onChanged: (value) => setState(() => _sleepReminders = value),
                isDark: isDark,
              ),
              _buildSwitchTile(
                title: 'Exercise Reminders',
                subtitle: 'Motivate you to stay active',
                value: _exerciseReminders,
                onChanged: (value) => setState(() => _exerciseReminders = value),
                isDark: isDark,
              ),
              _buildSwitchTile(
                title: 'Meal Reminders',
                subtitle: 'Never miss your meal times',
                value: _mealReminders,
                onChanged: (value) => setState(() => _mealReminders = value),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Health Tracking',
            icon: Icons.insights,
            color: const Color(0xFF2196F3),
            children: [
              _buildSwitchTile(
                title: 'Appointment Reminders',
                subtitle: 'Upcoming doctor appointments',
                value: _appointmentReminders,
                onChanged: (value) => setState(() => _appointmentReminders = value),
                isDark: isDark,
              ),
              _buildSwitchTile(
                title: 'Health Insights',
                subtitle: 'Daily health tips and insights',
                value: _healthInsights,
                onChanged: (value) => setState(() => _healthInsights = value),
                isDark: isDark,
              ),
              _buildSwitchTile(
                title: 'Achievement Alerts',
                subtitle: 'Celebrate your milestones',
                value: _achievementAlerts,
                onChanged: (value) => setState(() => _achievementAlerts = value),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Community',
            icon: Icons.people,
            color: const Color(0xFF4CAF50),
            children: [
              _buildSwitchTile(
                title: 'Community Updates',
                subtitle: 'New posts and challenges',
                value: _communityUpdates,
                onChanged: (value) => setState(() => _communityUpdates = value),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Sound & Vibration',
            icon: Icons.volume_up,
            color: const Color(0xFFFF9800),
            children: [
              _buildSwitchTile(
                title: 'Sound',
                subtitle: 'Play notification sounds',
                value: _soundEnabled,
                onChanged: (value) => setState(() => _soundEnabled = value),
                isDark: isDark,
              ),
              _buildSwitchTile(
                title: 'Vibration',
                subtitle: 'Vibrate on notifications',
                value: _vibrationEnabled,
                onChanged: (value) => setState(() => _vibrationEnabled = value),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuietHoursSection(isDark),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? Colors.white12 : Colors.grey[200], height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white60 : Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF00177E),
      ),
    );
  }

  Widget _buildQuietHoursSection(bool isDark) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bedtime, color: Color(0xFF9C27B0), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Quiet Hours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Switch(
                  value: _quietHoursEnabled,
                  onChanged: (value) => setState(() => _quietHoursEnabled = value),
                  activeThumbColor: const Color(0xFF9C27B0),
                ),
              ],
            ),
          ),
          if (_quietHoursEnabled) ...[
            Divider(color: isDark ? Colors.white12 : Colors.grey[200], height: 1),
            ListTile(
              title: Text(
                'Start Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              trailing: TextButton(
                onPressed: () => _selectTime(context, true),
                child: Text(
                  _quietHoursStart.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ),
              ),
            ),
            Divider(color: isDark ? Colors.white12 : Colors.grey[200], height: 1),
            ListTile(
              title: Text(
                'End Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              trailing: TextButton(
                onPressed: () => _selectTime(context, false),
                child: Text(
                  _quietHoursEnd.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFF9C27B0)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Notifications will be silenced during quiet hours',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietHoursStart : _quietHoursEnd,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C27B0),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
    }
  }
}
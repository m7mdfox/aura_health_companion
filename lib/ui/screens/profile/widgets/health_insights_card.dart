import 'package:flutter/material.dart';

class HealthInsightsCard extends StatelessWidget {
  final double weight;
  final double height;
  final double bmi;
  final String bmiCategory;
  final String? bloodType;

  const HealthInsightsCard({
    super.key,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.bmiCategory,
    this.bloodType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: const Color(0xFFFF6B6B),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Health Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildHealthItem(
                  context,
                  icon: Icons.monitor_weight,
                  label: 'Weight',
                  value: '${weight.toStringAsFixed(1)} kg',
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthItem(
                  context,
                  icon: Icons.height,
                  label: 'Height',
                  value: '${height.toStringAsFixed(0)} cm',
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHealthItem(
                  context,
                  icon: Icons.analytics,
                  label: 'BMI',
                  value: bmi.toStringAsFixed(1),
                  subtitle: bmiCategory,
                  color: _getBMIColor(),
                ),
              ),
              if (bloodType != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthItem(
                    context,
                    icon: Icons.bloodtype,
                    label: 'Blood Type',
                    value: bloodType!,
                    color: const Color(0xFFE91E63),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBMIColor() {
    if (bmi < 18.5) return const Color(0xFF2196F3); // Underweight - Blue
    if (bmi < 25) return const Color(0xFF4CAF50); // Normal - Green
    if (bmi < 30) return const Color(0xFFFFB74D); // Overweight - Orange
    return const Color(0xFFE91E63); // Obese - Pink
  }
}
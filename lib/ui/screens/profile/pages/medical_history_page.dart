import 'package:flutter/material.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<MedicalRecord> _records = [
    MedicalRecord(
      id: '1',
      title: 'Annual Checkup',
      date: DateTime.now().subtract(const Duration(days: 30)),
      doctor: 'Dr. Ahmed Hassan',
      specialty: 'General Physician',
      notes: 'Regular checkup. All vitals normal.',
      type: RecordType.checkup,
    ),
    MedicalRecord(
      id: '2',
      title: 'Blood Test Results',
      date: DateTime.now().subtract(const Duration(days: 45)),
      doctor: 'Dr. Sara Mohamed',
      specialty: 'Laboratory',
      notes: 'Blood sugar: 95 mg/dL (Normal)\nCholesterol: 180 mg/dL (Good)',
      type: RecordType.labTest,
    ),
    MedicalRecord(
      id: '3',
      title: 'Diabetes Follow-up',
      date: DateTime.now().subtract(const Duration(days: 90)),
      doctor: 'Dr. Mahmoud Ali',
      specialty: 'Endocrinologist',
      notes: 'HbA1c: 6.2% - Good control. Continue current medication.',
      type: RecordType.followUp,
    ),
  ];

  final List<String> _chronicConditions = [
    'Type 2 Diabetes',
    'Hypertension',
  ];

  final List<String> _allergies = [
    'Penicillin',
    'Peanuts',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Medical History'),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Records'),
            Tab(text: 'Conditions'),
            Tab(text: 'Allergies'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordsTab(),
          _buildConditionsTab(),
          _buildAllergiesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRecord,
        backgroundColor: const Color(0xFF00177E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRecordsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        return _buildRecordCard(_records[index]);
      },
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: InkWell(
        onTap: () => _viewRecordDetails(record),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getRecordTypeColor(record.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getRecordTypeIcon(record.type),
                      color: _getRecordTypeColor(record.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(record.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: isDark ? Colors.white12 : Colors.grey[200], height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: isDark ? Colors.white60 : Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      record.doctor,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.medical_services, size: 16, color: isDark ? Colors.white60 : Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    record.specialty,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange[700], size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Chronic Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ..._chronicConditions.map((condition) => _buildConditionItem(condition, isDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionItem(String condition, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1120) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.circle, size: 8, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              condition,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Known Allergies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ..._allergies.map((allergy) => _buildAllergyItem(allergy, isDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllergyItem(String allergy, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1120) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning, size: 16, color: Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              allergy,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Color _getRecordTypeColor(RecordType type) {
    switch (type) {
      case RecordType.checkup:
        return const Color(0xFF4CAF50);
      case RecordType.labTest:
        return const Color(0xFF2196F3);
      case RecordType.followUp:
        return const Color(0xFFFF9800);
      case RecordType.surgery:
        return const Color(0xFFE91E63);
      case RecordType.vaccination:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getRecordTypeIcon(RecordType type) {
    switch (type) {
      case RecordType.checkup:
        return Icons.health_and_safety;
      case RecordType.labTest:
        return Icons.science;
      case RecordType.followUp:
        return Icons.event_repeat;
      case RecordType.surgery:
        return Icons.medical_services;
      case RecordType.vaccination:
        return Icons.vaccines;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _viewRecordDetails(MedicalRecord record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getRecordTypeColor(record.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getRecordTypeIcon(record.type),
                          color: _getRecordTypeColor(record.type),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(record.date),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildDetailRow(Icons.person, 'Doctor', record.doctor, isDark),
                  const SizedBox(height: 15),
                  _buildDetailRow(Icons.medical_services, 'Specialty', record.specialty, isDark),
                  const SizedBox(height: 25),
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F1120) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      record.notes,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
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

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white60 : Colors.grey[600]),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _addNewRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add New Record - Coming Soon')),
    );
  }
}

enum RecordType {
  checkup,
  labTest,
  followUp,
  surgery,
  vaccination,
}

class MedicalRecord {
  final String id;
  final String title;
  final DateTime date;
  final String doctor;
  final String specialty;
  final String notes;
  final RecordType type;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.doctor,
    required this.specialty,
    required this.notes,
    required this.type,
  });
}
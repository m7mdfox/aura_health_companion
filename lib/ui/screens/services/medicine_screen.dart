import 'dart:async';
import 'dart:convert';
// >>> MAKE SURE THIS LINE IS HERE <<<
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// >>> MAKE SURE THIS LINE IS HERE <<<<<
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:aura_health_companion/ui/screens/login_screen.dart';
import 'package:aura_health_companion/ui/screens/services/gemeni_alternative.dart';
// import 'package:aura_health_companion/ui/screens/services_screen.dart'; // Uncomment if you use this
// import 'package:aura_health_companion/ui/widgets/error_animation.dart';
// import 'package:aura_health_companion/ui/widgets/success_animation.dart';
import 'package:aura_health_companion/ui/screens/services/notification_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// We need this for the `Time` object
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:aura_health_companion/ui/widgets/points_notification.dart';

class Medicine {
  final String id;
  final String tradeName;
  final String? concentration;
  final String dose;
  final int frequency;
  final int durationDays;
  final int quantity;
  final String? activeIngredient;
  final List<String> doseTimes;

  Medicine({
    required this.id,
    required this.tradeName,
    this.concentration,
    required this.dose,
    required this.frequency,
    required this.durationDays,
    required this.quantity,
    this.activeIngredient,
    required this.doseTimes,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['_id'] as String,
      tradeName: json['trade_name'] as String,
      concentration: json['concentration'] as String?,
      dose: json['dose'] as String,
      frequency: (json['frequency'] is int
          ? json['frequency']
          : int.tryParse(json['frequency'].toString()) ?? 0) as int,
      durationDays: (json['duration_days'] is int
          ? json['duration_days']
          : int.tryParse(json['duration_days'].toString()) ?? 0) as int,
      quantity: (json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 0) as int,
      activeIngredient: json['active_ingredient'] as String?,
      doseTimes: (json['dose_times'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class MedicineScreenn extends StatefulWidget {
  const MedicineScreenn({super.key});

  @override
  State<MedicineScreenn> createState() => _MedicineScreenState();
}

/// +++ NEW WIDGET +++
/// This widget moves the dialog's state into its own
/// lifecycle, fixing the 'setState after dispose' error.
class _MedicineDetailsDialogContent extends StatefulWidget {
  final Medicine med;
  final bool isLoading;
  final Future<void> Function(Medicine) onTakeDose;
  final DateTime? Function(List<String>) getNextDoseTime;
  final String Function(Duration) formatDurationForDialog;

  const _MedicineDetailsDialogContent({
    required this.med,
    required this.isLoading,
    required this.onTakeDose,
    required this.getNextDoseTime,
    required this.formatDurationForDialog,
  });

  @override
  _MedicineDetailsDialogContentState createState() =>
      _MedicineDetailsDialogContentState();
}

class _MedicineDetailsDialogContentState
    extends State<_MedicineDetailsDialogContent> {
  Timer? _dialogTimer;
  String _countdown = "--:--:--";

  @override
  void initState() {
    super.initState();
    _updateCountdown(); // Initial update
    _dialogTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _dialogTimer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  void _updateCountdown() {
    final nextDose = widget.getNextDoseTime(widget.med.doseTimes);
    if (nextDose != null) {
      final duration = nextDose.difference(DateTime.now());
      _countdown = widget.formatDurationForDialog(duration);
    } else {
      _countdown = "No schedule";
    }

    // Check 'mounted' property of this State object
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.med.tradeName,
                      style: GoogleFonts.mulish(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1B4C),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.med.concentration ?? 'N/A'} - ${widget.med.dose}',
                style: GoogleFonts.mulish(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Countdown Timer
              Center(
                child: Column(
                  children: [
                    Text(
                      'TIME UNTIL NEXT DOSE',
                      style: GoogleFonts.mulish(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _countdown,
                      style: GoogleFonts.mulish(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1B4C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info Rows
              _buildInfoRow(Icons.access_time_filled, "Dose Times",
                  widget.med.doseTimes.join(', ')),
              _buildInfoRow(Icons.inventory, "Quantity Remaining",
                  "${widget.med.quantity} capsules"),

              const SizedBox(height: 24),

              // Action Buttons
              ElevatedButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        widget.onTakeDose(widget.med).then((_) {
                          // After _takeDose is complete, pop this dialog
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1B4C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Take Dose Now',
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper for the details dialog
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF0D1B4C), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.mulish(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "Not set" : value,
                  style: GoogleFonts.mulish(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ... This is the end of _MedicineDetailsDialogContentState
// <--- This is the LAST '}' of _MedicineDetailsDialogContentState

// 🔽 ADD THIS ENTIRE NEW WIDGET
/// +++ NEW WIDGET +++
/// This widget provides a UI for the Gemini AI feature.
class _GeminiAIDialogContent extends StatefulWidget {
  final GeminiFeatureService geminiService;

  const _GeminiAIDialogContent({required this.geminiService});

  @override
  _GeminiAIDialogContentState createState() => _GeminiAIDialogContentState();
}

class _GeminiAIDialogContentState extends State<_GeminiAIDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String? _response;
  bool _isAiLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // In _GeminiAIDialogContentState:

// In _GeminiAIDialogContentState:

  Future<void> _askGemini() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isAiLoading) return;

    setState(() {
      _isAiLoading = true;
      _response = null; // Clear previous response
    });

    // 🔽 UPDATED PROMPT FOR SPECIFIC FORMAT
    const String featurePrompt = """
You are a medicine alternative finder. The user will provide a medicine name.
Your task is to find ONE common alternative medicine that has the same active ingredient.

You MUST respond ONLY in the exact format required, with no other text, greetings, or disclaimers.

- If responding in English, use this format:
"the alternative of [User's Medicine Name] is [Alternative Medicine Name]"

- If responding in Arabic, use this format:
"البديل لـ [User's Medicine Name] هو [Alternative Medicine Name]"

Example (English):
User's Medicine: "Panadol"
Your Response:
"The alternative of Panadol is Tylenol"

Example (Arabic):
User's Medicine: "بنادول"
Your Response:
"البديل لـ بنادول هو تايلينول"
""";
    // 🔼

    try {
      final message = _textController.text.trim();
      final result = await widget.geminiService.sendMessage(
        featurePrompt: featurePrompt,
        message: message,
      );
      _response = result;
    } catch (e) {
      _response = "⚠️ Oops! An error occurred: $e";
    } finally {
      if (mounted) {
        setState(() {
          _isAiLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ask Aura AI',
                    style: GoogleFonts.mulish(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D1B4C),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Get a quick summary of a medication.',
                style: GoogleFonts.mulish(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Input Form
              Form(
                key: _formKey,
                child: buildEnhancedInputField(
                  // Use the helper function
                  controller: _textController,
                  label: 'Enter Medicine Name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a medicine name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Response Area
              if (_isAiLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFF0D1B4C),
                    ),
                  ),
                ),

              if (_response != null && !_isAiLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _response!,
                      style: GoogleFonts.mulish(
                        color: Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Action Button
              ElevatedButton(
                onPressed: _isAiLoading ? null : _askGemini,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1B4C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isAiLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Ask AI',
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineScreenState extends State<MedicineScreenn> {
  // Add this function inside _MedicineScreenState
  Future<void> _showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_channel_id', // Use the same channel ID
      'Medicine Reminders',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationService.flutterLocalNotificationsPlugin.show(
      999, // Unique ID for test
      'Test Notification',
      'If you see this, the plugin is working!',
      platformDetails,
    );
  }

  final NotificationService _notificationService = NotificationService();

  final GeminiFeatureService _geminiService = GeminiFeatureService();

  // ... other variables

  // ...
  // 🔽 ADD THIS NEW FUNCTION (e.g., after _showEnhancedErrorDialog)
  void _showGeminiAIDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Don't close on tap outside
      builder: (context) {
        // Pass the gemini service instance to the new dialog
        return _GeminiAIDialogContent(geminiService: _geminiService);
      },
    );
  }

  // +++ ADD THIS HELPER +++
  /// Generates a unique, predictable notification ID for a medicine's dose
  int _generateNotificationId(String medicineId, int doseIndex) {
    // Use the first 8 chars of the Mongo ID to create a unique int
    final int medIdHash = int.parse(medicineId.substring(0, 8), radix: 16);
    return medIdHash + doseIndex;
  }

  Future<void> _scheduleAllNotifications(Medicine medicine) async {
    for (int i = 0; i < medicine.doseTimes.length; i++) {
      final timeStr = medicine.doseTimes[i];
      try {
        final parts = timeStr.split(':');
        final int? hour = int.tryParse(parts[0]);
        final int? minute = int.tryParse(parts[1]);

        if (hour != null && minute != null) {
          final int notificationId = _generateNotificationId(medicine.id, i);

          // Corrected call without 'time: null'
          await _notificationService.scheduleDailyNotification(
            id: notificationId,
            title: 'Time for your dose!',
            body:
                'It\'s time to take your ${medicine.dose} of ${medicine.tradeName}.',
            hour: hour,
            minute: minute,
          );

          print('Scheduled notification $notificationId for $timeStr');
        } else {
          print('Error parsing time string, hour or minute was null: $timeStr');
        }
      } catch (e) {
        print('Error scheduling notification for $timeStr: $e');
      }
    }
  }

  // +++ ADD THIS FUNCTION +++
  Future<void> _cancelAllNotificationsForMedicine(
      String medicineId, int doseCount) async {
    for (int i = 0; i < doseCount; i++) {
      try {
        final int notificationId = _generateNotificationId(medicineId, i);
        await _notificationService.cancelNotification(notificationId);
        print('Cancelled notification $notificationId');
      } catch (e) {
        print('Error cancelling notification: $e');
      }
    }
  }

  final _addMedicineFormKey = GlobalKey<FormState>();
  final _checkInteractionFormKey = GlobalKey<FormState>();
  final _tradeNameController = TextEditingController();
  final _concentrationController = TextEditingController();
  final _doseController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _medicine1Controller = TextEditingController();
  final _medicine2Controller = TextEditingController();

  int _frequencyCount = 0;
  List<TimeOfDay?> _selectedDoseTimes = [];

  bool _isLoading = false;
  Timer? _debounce;
  Timer? _countdownTimer; // Timer to update card countdowns
  List<Medicine> _userMedicines = [];

  @override
  void initState() {
    super.initState();
    _fetchUserMedicines();
    _medicine1Controller.addListener(_onTextChanged);
    _medicine2Controller.addListener(_onTextChanged);

    // Timer to update countdowns on cards every minute
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _countdownTimer?.cancel(); // Cancel the card timer
    _tradeNameController.dispose();
    _concentrationController.dispose();
    _doseController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _quantityController.dispose();
    _medicine1Controller.dispose();
    _medicine2Controller.dispose();
    super.dispose();
  }

  // +------------------------------------------------------------+
  // |                COUNTDOWN & HELPER FUNCTIONS                |
  // +------------------------------------------------------------+

  /// Gets the next scheduled dose time as a DateTime object
  DateTime? _getNextDoseTime(List<String> doseTimes) {
    if (doseTimes.isEmpty) return null;

    final now = DateTime.now();
    List<DateTime> todayDoses = [];

    for (var timeStr in doseTimes) {
      try {
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        todayDoses.add(DateTime(now.year, now.month, now.day, hour, minute));
      } catch (e) {
        print("Error parsing time: $timeStr");
      }
    }

    todayDoses.sort();

    // Find the next dose today
    DateTime? nextDoseToday; // Declare as nullable
    try {
      // Find the first dose time that is after the current time
      nextDoseToday = todayDoses.firstWhere((dose) => dose.isAfter(now));
    } catch (e) {
      // 'firstWhere' throws an error if no element is found
      nextDoseToday = null; // Set to null if not found
    }

    if (nextDoseToday != null) {
      return nextDoseToday;
    }

    // If no dose later today, get the first dose tomorrow
    if (todayDoses.isNotEmpty) {
      return todayDoses.first.add(const Duration(days: 1));
    }

    return null;
  }

  /// Formats a duration for the main medicine card (e.g., "Next: 2h 15m")
  String _formatDurationForCard(Duration duration) {
    if (duration.isNegative) {
      return "Dose missed";
    }

    final int d = duration.inDays;
    final int h = duration.inHours.remainder(24);
    final int m = duration.inMinutes.remainder(60);

    if (d > 0) return "Next: ${d}d ${h}h";
    if (h > 0) return "Next: ${h}h ${m}m";
    if (m > 0) return "Next: ${m}m";
    return "Next: < 1m";
  }

  /// Formats a duration for the details dialog (e.g., "02:15:30")
  String _formatDurationForDialog(Duration duration) {
    if (duration.isNegative) {
      return "00:00:00 (Missed)";
    }

    // Format as HH:MM:SS
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  /// Gets the full countdown string for the card
  String _getCardCountdownText(List<String> doseTimes) {
    final nextDose = _getNextDoseTime(doseTimes);
    if (nextDose == null) {
      return "No schedule";
    }
    final duration = nextDose.difference(DateTime.now());
    return _formatDurationForCard(duration);
  }

  // +------------------------------------------------------------+
  // |                       API FUNCTIONS                      |
  // +------------------------------------------------------------+

  Future<void> _fetchUserMedicines() async {
    // ... (This function remains unchanged)
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse('http://10.0.2.2:4000/api/medicine/my-medicines');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print(
          'Fetch medicines response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _userMedicines = (data['medicines'] as List)
                .map((m) => Medicine.fromJson(m))
                .toList();
            print('Medicines updated: ${_userMedicines.length} medicines');
          });
        }
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to fetch medicines: ${response.body}');
      }
    } catch (e) {
      print('Fetch medicines error: $e');
      if (mounted) {
        await _showEnhancedErrorDialog(
          context: context,
          message: 'Failed to load medicines: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addMedicine() async {
    // ... (This function remains unchanged)
    if (!_addMedicineFormKey.currentState!.validate()) return;

    if (_selectedDoseTimes.any((t) => t == null)) {
      if (mounted) {
        await _showEnhancedErrorDialog(
          context: context,
          message: 'Please select all dose times for the frequency.',
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('User not logged in');
      }

      final formattedTimes = _selectedDoseTimes
          .map((time) =>
              '${time!.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}')
          .toList();

      final body = {
        'trade_name': _tradeNameController.text.trim(),
        'concentration': _concentrationController.text.trim(),
        'dose': _doseController.text.trim(),
        'frequency': int.parse(_frequencyController.text.trim()),
        'duration_days': int.parse(_durationController.text.trim()),
        'quantity': int.parse(_quantityController.text.trim()),
        'dose_times': formattedTimes,
      };

      final url = Uri.parse('http://10.0.2.2:4000/api/medicine/add-medicine');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Add medicine response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 201) {
        if (mounted) {
          // 1. Reset the form and clear controllers FIRST (while the dialog still exists)
          _addMedicineFormKey.currentState!.reset();
          _tradeNameController.clear();
          _concentrationController.clear();
          _doseController.clear();
          _frequencyController.clear();
          _durationController.clear();
          _quantityController.clear();
          setState(() {
            _frequencyCount = 0;
            _selectedDoseTimes = [];
          });

          // 2. NOW, close the "Add Medicine" dialog
          Navigator.of(context).pop();

          // +++ ADD THIS SECTION +++
          // We need the newly created medicine to get its ID
          final newMedicineData = jsonDecode(response.body)['medicine'];
          final newMedicine = Medicine.fromJson(newMedicineData);
          _scheduleAllNotifications(newMedicine); // Schedule notifications
          // ++++++++++++++++++++++++

          // 3. Show the "Success" dialog
          await _showEnhancedSuccessDialog(
            context: context,
            message: 'Medicine added successfully!',
            onOk: () {
              Navigator.of(context).pop(); // Closes the success dialog
              _fetchUserMedicines(); // Refresh the main list
            },
          );
        }
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 409) {
        final data = jsonDecode(response.body);
        final conflicts = data['conflicts'] ?? [];
        final conflictMessages = conflicts
            .map((c) => '${c['conflictingMedicine']}: ${c['description']}')
            .join('\n');
        if (mounted) {
          await _showEnhancedErrorDialog(
            context: context,
            message: 'Medicine conflicts detected:\n$conflictMessages',
          );
        }
      } else {
        throw Exception('Failed to add medicine: ${response.body}');
      }
    } catch (e) {
      print('Add medicine error: $e');
      if (mounted) {
        await _showEnhancedErrorDialog(
          context: context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkInteraction() async {
    // ... (This function remains unchanged)
    if (_checkInteractionFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final url =
            Uri.parse('http://10.0.2.2:4000/api/medicine/check-interaction');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'medicine1': _medicine1Controller.text.trim(),
            'medicine2': _medicine2Controller.text.trim(),
          }),
        );

        print(
            'Check interaction response: ${response.statusCode} ${response.body}');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (mounted) {
            final message = data['interaction']
                ? 'Interaction found: ${data['description']}'
                : 'No interaction found between these medicines.';

            if (data['interaction']) {
              await _showEnhancedErrorDialog(
                context: context,
                message: message,
                showCloseButton: true,
              );
            } else {
              await _showEnhancedSuccessDialog(
                context: context,
                message: message,
                showCloseButton: true,
              );
            }

            _checkInteractionFormKey.currentState!.reset();
            _medicine1Controller.clear();
            _medicine2Controller.clear();
          }
        } else {
          throw Exception('Failed to check interaction: ${response.body}');
        }
      } catch (e) {
        print('Check interaction error: $e');
        if (mounted) {
          await _showEnhancedErrorDialog(
            context: context,
            message: e.toString(),
            showCloseButton: true,
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // +++ DOSE TIMING FUNCTIONS +++

  /// Fetch the last dose time for a medicine from API
  Future<DateTime?> _getLastDoseTime(String medicineId) async {
    try {
      final token = AuthService.token;
      if (token == null) return null;

      final url =
          Uri.parse('http://10.0.2.2:4000/api/medicine/$medicineId/last-dose');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['created_at'] != null) {
          return DateTime.parse(data['data']['created_at']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching last dose time: $e');
      return null;
    }
  }

  /// Get the next scheduled dose time
  DateTime? _getScheduledDoseTime(List<String> doseTimes) {
    return _getNextDoseTime(doseTimes);
  }

  /// Calculate hours and minutes until next dose for display
  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) return "now";
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return "$hours hours $minutes minutes";
    if (hours > 0) return "$hours hours";
    if (minutes > 0) return "$minutes minutes";
    return "less than a minute";
  }

  /// Show blocked dialog (took dose too recently)
  Future<void> _showBlockedDoseDialog(Duration timeRemaining) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Already Taken')),
          ],
        ),
        content: Text(
          'You already took this dose recently.\n\nNext dose available in ${_formatTimeRemaining(timeRemaining)}.',
          style: GoogleFonts.mulish(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show early dose confirmation dialog
  Future<bool> _showEarlyDoseConfirmation(Duration earlyBy) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Taking Early')),
          ],
        ),
        content: Text(
          'You are taking this dose ${_formatTimeRemaining(earlyBy)} early.\n\nDo you want to continue?',
          style: GoogleFonts.mulish(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D1B4C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('Take Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show late dose confirmation dialog
  Future<bool> _showLateDoseConfirmation(Duration lateBy) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.deepOrange, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Taking Late')),
          ],
        ),
        content: Text(
          'This dose is ${_formatTimeRemaining(lateBy)} late.\n\nWould you still like to take it?',
          style: GoogleFonts.mulish(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('Take Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _takeDose(Medicine med) async {
    // Check quantity first
    if (med.quantity <= 0) {
      if (mounted) {
        await _showEnhancedErrorDialog(
          context: context,
          message:
              'Out of Stock! You have no more doses of ${med.tradeName}. Please reorder.',
        );
      }
      return;
    }

    // +++ DOSE TIMING CHECK +++
    setState(() => _isLoading = true);

    // Get last dose time
    final lastDoseTime = await _getLastDoseTime(med.id);
    final now = DateTime.now();

    // Constants for timing
    const minHoursBetweenDoses = 4;
    const toleranceMinutes = 15;

    if (lastDoseTime != null) {
      final timeSinceLastDose = now.difference(lastDoseTime);

      // BLOCK: Less than 4 hours since last dose
      if (timeSinceLastDose.inHours < minHoursBetweenDoses) {
        setState(() => _isLoading = false);
        final timeRemaining =
            Duration(hours: minHoursBetweenDoses) - timeSinceLastDose;
        await _showBlockedDoseDialog(timeRemaining);
        return;
      }
    }

    // Check scheduled time for early/late
    final scheduledTime = _getScheduledDoseTime(med.doseTimes);
    if (scheduledTime != null) {
      final difference = scheduledTime.difference(now);

      // EARLY: More than 15 minutes before scheduled time (and at least 4h passed)
      if (difference.inMinutes > toleranceMinutes) {
        setState(() => _isLoading = false);
        final shouldContinue = await _showEarlyDoseConfirmation(difference);
        if (!shouldContinue) return;
        setState(() => _isLoading = true);
      }
      // LATE: More than 15 minutes after scheduled time
      else if (difference.inMinutes < -toleranceMinutes) {
        setState(() => _isLoading = false);
        final lateBy = Duration(minutes: -difference.inMinutes);
        final shouldContinue = await _showLateDoseConfirmation(lateBy);
        if (!shouldContinue) return;
        setState(() => _isLoading = true);
      }
    }
    // +++ END DOSE TIMING CHECK +++

    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('User not logged in');
      }

      final url =
          Uri.parse('http://10.0.2.2:4000/api/medicine/update-quantity');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'medicineId': med.id,
          'quantity': med.quantity - 1,
        }),
      );

      print(
          'Update quantity response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        // Check for points awarded and show notification
        final responseData = jsonDecode(response.body);
        if (responseData['pointsAwarded'] != null) {
          final points = responseData['pointsAwarded']['points'] as int;
          final message = responseData['pointsAwarded']['message'] as String;
          PointsNotification.show(
            context,
            points: points,
            message: message,
            action: 'medicine_taken',
          );
        }

        if (mounted) {
          await _showEnhancedSuccessDialog(
            context: context,
            message:
                'You have successfully taken your dose of ${med.tradeName}.',
            onOk: () {
              Navigator.of(context).pop();
              setState(() {
                _userMedicines = [];
              });
              _fetchUserMedicines();
            },
          );
          if (med.quantity == 6) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${med.tradeName} is running out! Only 5 doses left. Time to order.'),
                backgroundColor: Colors.orange.shade800,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to update quantity: ${response.body}');
      }
    } catch (e) {
      print('Update quantity error: $e');
      if (mounted) {
        await _showEnhancedErrorDialog(
          context: context,
          message:
              'Failed to update dose: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMedicine(String medicineId, String tradeName) async {
    // +++ ADD THIS +++
    // Find the medicine in the list to know its dose count
    Medicine? medToDelete;
    try {
      medToDelete = _userMedicines.firstWhere((med) => med.id == medicineId);
    } catch (e) {
      medToDelete = null;
    }
    // ++++++++++++++++
    setState(() => _isLoading = true);
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('User not logged in');
      }

      final url =
          Uri.parse('http://10.0.2.2:4000/api/medicine/delete/$medicineId');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print(
          'Delete medicine response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        if (mounted) {
          // +++ ADD THIS +++
          if (medToDelete != null) {
            await _cancelAllNotificationsForMedicine(
                medToDelete.id, medToDelete.doseTimes.length);
          }
          // ++++++++++++++++
          // +++ FIX +++
          // Use the correct, standardized success dialog
          // This dialog doesn't have a race condition.
          await _showEnhancedSuccessDialog(
            context: context,
            message: '$tradeName removed successfully!',
            onOk: () {
              Navigator.of(context).pop(); // Close success dialog
              _fetchUserMedicines(); // Refresh the list
            },
          );
        }
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception(
            'Medicine not found or you do not have permission to delete it.');
      } else {
        throw Exception('Failed to delete medicine: ${response.body}');
      }
    } catch (e) {
      print('Delete medicine error: $e');
      if (mounted) {
        // +++ FIX +++
        // Use the correct, standardized error dialog
        await _showEnhancedErrorDialog(
          context: context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // +------------------------------------------------------------+
  // |                       DIALOG WIDGETS                       |
  // +------------------------------------------------------------+

  Future<void> _showEnhancedSuccessDialog(
      {/*... (This function remains unchanged) ...*/
      required BuildContext context,
      required String message,
      VoidCallback? onOk,
      bool showCloseButton = false}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1B4C), Color(0xFF162C7A)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade400.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Success!',
                  style: GoogleFonts.mulish(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mulish(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (showCloseButton) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.mulish(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onOk ?? () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D1B4C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: Colors.white.withOpacity(0.3),
                        ),
                        child: Text(
                          'OK',
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEnhancedErrorDialog(
      {/*... (This function remains unchanged) ...*/
      required BuildContext context,
      required String message,
      bool showCloseButton = false}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1B4C), Color(0xFF162C7A)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade400.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Attention Needed',
                  style: GoogleFonts.mulish(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mulish(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (showCloseButton) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.mulish(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D1B4C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: Colors.white.withOpacity(0.3),
                        ),
                        child: Text(
                          'OK',
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMedicineDialog() {
    // ... (This function remains unchanged)
    _frequencyController.clear();
    _tradeNameController.clear();
    _concentrationController.clear();
    _doseController.clear();
    _durationController.clear();
    _quantityController.clear();

    _frequencyCount = 0;
    _selectedDoseTimes = [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, dialogSetState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add New Medicine',
                          style: GoogleFonts.mulish(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D1B4C),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _addMedicineFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildEnhancedInputField(
                                controller: _tradeNameController,
                                label: 'Trade Name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter trade name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              buildEnhancedInputField(
                                controller: _concentrationController,
                                label: 'Concentration (e.g., 500 mg)',
                              ),
                              const SizedBox(height: 16),
                              buildEnhancedInputField(
                                controller: _doseController,
                                label: 'Dose (e.g., 1 tablet)',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter dose';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              buildEnhancedInputField(
                                controller: _frequencyController,
                                label: 'Frequency (times per day)',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  int count = int.tryParse(value) ?? 0;
                                  if (count > 10) count = 10;
                                  if (count < 0) count = 0;
                                  dialogSetState(() {
                                    _frequencyCount = count;
                                    if (_selectedDoseTimes.length > count) {
                                      _selectedDoseTimes =
                                          _selectedDoseTimes.sublist(0, count);
                                    } else {
                                      _selectedDoseTimes.addAll(List.generate(
                                          count - _selectedDoseTimes.length,
                                          (i) => null));
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter frequency';
                                  }
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) <= 0) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              ...List.generate(_frequencyCount, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Material(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime:
                                              _selectedDoseTimes[index] ??
                                                  TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          // +++ VALIDATE 4 HOUR GAP +++
                                          final newTimeMinutes =
                                              time.hour * 60 + time.minute;
                                          bool tooClose = false;
                                          String conflictingTime = '';

                                          for (int i = 0;
                                              i < _selectedDoseTimes.length;
                                              i++) {
                                            if (i == index)
                                              continue; // Skip self
                                            final existingTime =
                                                _selectedDoseTimes[i];
                                            if (existingTime == null) continue;

                                            final existingMinutes =
                                                existingTime.hour * 60 +
                                                    existingTime.minute;
                                            int diff = (newTimeMinutes -
                                                    existingMinutes)
                                                .abs();
                                            // Handle wrap-around (e.g., 23:00 and 01:00)
                                            if (diff > 12 * 60)
                                              diff = 24 * 60 - diff;

                                            if (diff < 4 * 60) {
                                              // Less than 4 hours
                                              tooClose = true;
                                              conflictingTime =
                                                  existingTime.format(context);
                                              break;
                                            }
                                          }

                                          if (tooClose) {
                                            await _showEnhancedErrorDialog(
                                              context: context,
                                              message:
                                                  'Dose times must be at least 4 hours apart.\n\nThe selected time ${time.format(context)} is too close to $conflictingTime.',
                                            );
                                            return;
                                          }
                                          // +++ END VALIDATION +++

                                          dialogSetState(() {
                                            _selectedDoseTimes[index] = time;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.grey.shade300)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.access_time_filled,
                                                    color: Color(0xFF0D1B4C),
                                                    size: 20),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Dose ${index + 1} Time',
                                                  style: GoogleFonts.mulish(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF0D1B4C)),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              _selectedDoseTimes[index]
                                                      ?.format(context) ??
                                                  'Not Set',
                                              style: GoogleFonts.mulish(
                                                  color: _selectedDoseTimes[
                                                              index] ==
                                                          null
                                                      ? Colors.red.shade400
                                                      : Colors.black87,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                              buildEnhancedInputField(
                                controller: _durationController,
                                label: 'Duration (days)',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter duration';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              buildEnhancedInputField(
                                controller: _quantityController,
                                label: 'Quantity',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter quantity';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0D1B4C),
                              side: const BorderSide(color: Color(0xFF0D1B4C)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.mulish(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_addMedicineFormKey.currentState!
                                        .validate()) {
                                      if (_selectedDoseTimes
                                          .any((t) => t == null)) {
                                        _showEnhancedErrorDialog(
                                          context: context,
                                          message:
                                              'Please select all dose times.',
                                        );
                                      } else {
                                        _addMedicine();
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B4C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor:
                                  const Color(0xFF0D1B4C).withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Add Medicine',
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCheckInteractionDialog() {
    // ... (This function remains unchanged)
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Check Drug Interaction',
                      style: GoogleFonts.mulish(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1B4C),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _checkInteractionFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildEnhancedInputField(
                        controller: _medicine1Controller,
                        label: 'Medicine 1',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first medicine';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      buildEnhancedInputField(
                        controller: _medicine2Controller,
                        label: 'Medicine 2',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter second medicine';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D1B4C),
                          side: const BorderSide(color: Color(0xFF0D1B4C)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _checkInteraction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D1B4C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF0D1B4C).withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Check Interaction',
                                style: GoogleFonts.mulish(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// +++ MODIFIED FUNCTION +++
  /// Shows the details for a specific medicine using the new widget
  void _showMedicineDetailsDialog(Medicine med) {
    showDialog(
      context: context,
      builder: (context) {
        return _MedicineDetailsDialogContent(
          med: med,
          // Pass the main screen's _isLoading state to the dialog
          isLoading: _isLoading,
          // Pass the functions from _MedicineScreenState to the dialog
          onTakeDose: _takeDose,
          getNextDoseTime: _getNextDoseTime,
          formatDurationForDialog: _formatDurationForDialog,
        );
      },
    );
  }

  /// Helper for the details dialog
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF0D1B4C), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.mulish(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "Not set" : value,
                  style: GoogleFonts.mulish(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // +------------------------------------------------------------+
  // |                       BUILD WIDGETS                      |
  // +------------------------------------------------------------+

  void _showActionBottomSheet() {
    // ... (This function remains unchanged)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1B4C), Color(0xFF162C7A)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose Action',
                      style: GoogleFonts.mulish(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildActionButton(
                      icon: Icons.add_circle_outline,
                      text: 'Add Medicine',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showAddMedicineDialog();
                      },
                    ),
                    const SizedBox(height: 16),
                    // 🔽 ADD THESE 3 LINES
                    _buildActionButton(
                      icon: Icons.auto_awesome, // AI icon
                      text: 'Ask Aura AI',
                      onTap: () {
                        Navigator.of(context).pop(); // Close bottom sheet
                        _showGeminiAIDialog(); // Open new AI dialog
                      },
                    ),
                    const SizedBox(height: 16),
                    // 🔼
                    _buildActionButton(
                      icon: Icons.mediation_outlined,
                      text: 'Check Interaction',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showCheckInteractionDialog();
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      icon: Icons.close,
                      text: 'Cancel',
                      isCancel: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    // ... (This function remains unchanged)
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isCancel = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isCancel ? Colors.transparent : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: isCancel
                ? Border.all(color: Colors.white.withOpacity(0.3))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isCancel ? Colors.white70 : Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: GoogleFonts.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCancel ? Colors.white70 : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    // ... (This function remains unchanged)
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final currentDay = DateFormat('E').format(DateTime.now()).substring(0, 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Medications',
            style: GoogleFonts.mulish(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1B4C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              final isToday = day == currentDay;
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF0D1B4C) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isToday ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineStrip(Medicine med) {
    // ... (This function remains unchanged)
    int totalPills = med.quantity;
    int maxPillsToShow = 10;
    List<Widget> pills = [];

    Color pillColor =
        totalPills <= 5 ? Colors.red.shade300 : Colors.teal.shade300;
    String warningText = totalPills <= 5 ? 'Running Out!' : '';

    for (int i = 0; i < maxPillsToShow && i < totalPills; i++) {
      pills.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Container(
            width: 20,
            height: 10,
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (totalPills > maxPillsToShow) {
      pills.add(
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '+${totalPills - maxPillsToShow} more',
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (warningText.isNotEmpty)
          Row(
            children: [
              Icon(Icons.notification_important,
                  color: Colors.red.shade400, size: 18),
              const SizedBox(width: 4),
              Text(
                warningText,
                style: GoogleFonts.mulish(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Row(children: pills),
      ],
    );
  }

  Widget _buildDeleteButton(Medicine med) {
    // ... (This function remains unchanged)
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _deleteMedicine(med.id, med.tradeName); // Call delete function
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.delete_outline,
            color: const Color(0xFF0D1B4C),
            size: 18,
          ),
        ),
      ),
    );
  }

  /// +++ MODIFIED +++
  /// Card is now clickable and shows countdown
  Widget _buildMedicineCard(Medicine med) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: Color(0x0000001A).withOpacity(0.1),
        child: InkWell(
          onTap: () {
            // +++ ADDED +++
            _showMedicineDetailsDialog(med);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade100,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        med.tradeName,
                        style: GoogleFonts.mulish(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D1B4C),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildDeleteButton(med),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${med.concentration ?? 'N/A'} - ${med.dose}',
                  style: GoogleFonts.mulish(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Reminder section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B4C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notifications_none,
                        color: const Color(0xFF0D1B4C),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        // +++ MODIFIED +++
                        // Show countdown instead of static times
                        _getCardCountdownText(med.doseTimes),
                        style: GoogleFonts.mulish(
                          color: const Color(0xFF0D1B4C),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMedicineStrip(med),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _takeDose(med),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(
                      'Take Dose',
                      style: GoogleFonts.mulish(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B4C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      elevation: 2,
                      shadowColor: const Color(0xFF0D1B4C).withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // +------------------------------------------------------------+
  // |                       MAIN BUILD METHOD                    |
  // +------------------------------------------------------------+

  @override
  Widget build(BuildContext context) {
    // ... (This function remains unchanged)
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B4C),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D1B4C).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
        title: Text(
          'Medicine Manager',
          style: GoogleFonts.mulish(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: [Color(0xFF00177E), Color(0xFF0F1120)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/PatternLogin.png',
                width: screenWidth * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => SizedBox(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildWeekDaysHeader(),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFF0D1B4C),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading your medications...',
                                style: GoogleFonts.mulish(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _userMedicines.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.medication_liquid_outlined,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No medications added yet',
                                    style: GoogleFonts.mulish(
                                      fontSize: 18,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to add your first medication',
                                    style: GoogleFonts.mulish(
                                      color: Colors.grey.shade400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _userMedicines.length,
                              itemBuilder: (context, index) {
                                return _buildMedicineCard(
                                    _userMedicines[index]);
                              },
                            ),
                ),
                const SizedBox(height: 80),
                ElevatedButton(
                  onPressed: _showTestNotification,
                  child: Text('Test Immediate Notification'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: _showActionBottomSheet,
          backgroundColor: const Color(0xFF0D1B4C),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

Widget buildEnhancedInputField({
  // ... (This function remains unchanged)

  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    onChanged: onChanged,
    style: GoogleFonts.mulish(
      color: const Color(0xFF0D1B4C),
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.mulish(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B4C), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      errorStyle: GoogleFonts.mulish(
        color: Colors.red.shade400,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

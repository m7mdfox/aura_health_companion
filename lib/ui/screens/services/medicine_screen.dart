import 'dart:async';
import 'dart:convert';
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:aura_health_companion/ui/screens/login_screen.dart';
import 'package:aura_health_companion/ui/screens/services_screen.dart';
import 'package:aura_health_companion/ui/widgets/error_animation.dart';
import 'package:aura_health_companion/ui/widgets/success_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Medicine {
  final String id;
  final String tradeName;
  final String? concentration;
  final String dose;
  final String frequency;
  final int durationDays;
  final int quantity;
  final String activeIngredient;

  Medicine({
    required this.id,
    required this.tradeName,
    this.concentration,
    required this.dose,
    required this.frequency,
    required this.durationDays,
    required this.quantity,
    required this.activeIngredient,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['_id'] as String,
      tradeName: json['trade_name'] as String,
      concentration: json['concentration'] as String?,
      dose: json['dose'] as String,
      frequency: (json['frequency'] is int
              ? json['frequency'].toString()
              : json['frequency'] as String?) ??
          'Unknown',
      durationDays: (json['duration_days'] is int
          ? json['duration_days']
          : int.tryParse(json['duration_days'].toString()) ?? 0) as int,
      quantity: (json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 0) as int,
      activeIngredient: json['active_ingredient'] as String,
    );
  }
}

class MedicineScreenn extends StatefulWidget {
  const MedicineScreenn({super.key});

  @override
  State<MedicineScreenn> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreenn> {
  final _addMedicineFormKey = GlobalKey<FormState>();
  final _checkInteractionFormKey = GlobalKey<FormState>();
  final _tradeNameController = TextEditingController();
  final _concentrationController = TextEditingController();
  final _doseController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _activeIngredientController = TextEditingController();
  final _medicine1Controller = TextEditingController();
  final _medicine2Controller = TextEditingController();
  bool _isLoading = false;
  Timer? _debounce;
  List<Medicine> _userMedicines = [];
  int _currentIndex = 1; // Profile is active

  @override
  void initState() {
    super.initState();
    _fetchUserMedicines();
    _medicine1Controller.addListener(_onTextChanged);
    _medicine2Controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tradeNameController.dispose();
    _concentrationController.dispose();
    _doseController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _quantityController.dispose();
    _activeIngredientController.dispose();
    _medicine1Controller.dispose();
    _medicine2Controller.dispose();
    super.dispose();
  }

  Future<void> _fetchUserMedicines() async {
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
    if (_addMedicineFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final token = AuthService.token;
        if (token == null) {
          throw Exception('User not logged in');
        }

        final body = {
          'trade_name': _tradeNameController.text.trim(),
          'concentration': _concentrationController.text.trim(),
          'dose': _doseController.text.trim(),
          'frequency': _frequencyController.text.trim(),
          'active_ingredient': _activeIngredientController.text.trim(),
          'duration_days':
              int.parse(_durationController.text.trim()).toString(),
          'quantity': int.parse(_quantityController.text.trim()).toString(),
        };

        try {
          int.parse(_durationController.text.trim());
          int.parse(_quantityController.text.trim());
        } catch (e) {
          if (mounted) {
            await _showEnhancedErrorDialog(
              context: context,
              message: 'Please enter valid numbers for duration and quantity',
            );
          }
          return;
        }

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
            await _showEnhancedSuccessDialog(
              context: context,
              message: 'Medicine added successfully!',
              onOk: () {
                Navigator.of(context).pop();
                _fetchUserMedicines();
              },
            );
            _addMedicineFormKey.currentState!.reset();
            _tradeNameController.clear();
            _concentrationController.clear();
            _doseController.clear();
            _frequencyController.clear();
            _durationController.clear();
            _quantityController.clear();
            _activeIngredientController.clear();
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
  }

  Future<void> _checkInteraction() async {
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
            Navigator.of(context).pop();
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

  Future<void> _takeDose(Medicine med) async {
    if (med.quantity <= 0) {
      if (mounted) {
        await _showEnhancedErrorDialog(
          context: context,
          message: 'Out of Stock! You have no more doses of ${med.tradeName}. Please reorder.',
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

      final url = Uri.parse('http://10.0.2.2:4000/api/medicine/update-quantity');
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

      print('Update quantity response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        if (mounted) {
          await _showEnhancedSuccessDialog(
            context: context,
            message: 'You have successfully taken your dose of ${med.tradeName}.',
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
                content: Text('${med.tradeName} is running out! Only 5 doses left. Time to order.'),
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
          message: 'Failed to update dose: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Enhanced Dialog Methods
  Future<void> _showEnhancedSuccessDialog({
    required BuildContext context,
    required String message,
    VoidCallback? onOk,
    bool showCloseButton = false,
  }) async {
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

  Future<void> _showEnhancedErrorDialog({
    required BuildContext context,
    required String message,
    bool showCloseButton = false,
  }) async {
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

  Widget _buildMedicineStrip(Medicine med) {
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

  void _showAddMedicineDialog() {
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
                          _buildEnhancedInputField(
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
                          _buildEnhancedInputField(
                            controller: _concentrationController,
                            label: 'Concentration (e.g., 500 mg)',
                          ),
                          const SizedBox(height: 16),
                          _buildEnhancedInputField(
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
                          _buildEnhancedInputField(
                            controller: _frequencyController,
                            label: 'Frequency (e.g., twice daily)',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter frequency';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildEnhancedInputField(
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
                          _buildEnhancedInputField(
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
                          const SizedBox(height: 16),
                          _buildEnhancedInputField(
                            controller: _activeIngredientController,
                            label: 'Active Ingredient',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter active ingredient';
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
                        onPressed: _isLoading ? null : _addMedicine,
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
        ),
      ),
    );
  }

  void _showCheckInteractionDialog() {
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
                      _buildEnhancedInputField(
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
                      _buildEnhancedInputField(
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

  Widget _buildEnhancedInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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

  void _showActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
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
            color: isCancel
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
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
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
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
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: day == 'Mo' ? const Color(0xFF0D1B4C) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: day == 'Mo' ? Colors.white : Colors.grey.shade600,
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

  Widget _buildMedicineCard(Medicine med) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: const Color(0x0000001A),
        child: InkWell(
          onTap: () {},
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
                  '${med.concentration ?? '500mg'} BAYER, ${med.dose.contains('tablet') ? 'Tablet' : 'Capsule'}',
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
                    Text(
                      _getNextReminderTime(med.frequency),
                      style: GoogleFonts.mulish(
                        color: const Color(0xFF0D1B4C),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

Future<void> _deleteMedicine(String medicineId, String tradeName) async {
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
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.all(16.0),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.4,
                  maxWidth: MediaQuery.of(dialogContext).size.width * 0.8,
                ),
                child: SingleChildScrollView(
                  child: SuccessAnimation(
                    message: '$tradeName removed successfully!',
                    onComplete: () {}, // No auto-dismiss
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close dialog only
                    if (mounted) {
                      _fetchUserMedicines(); // Refresh the medicine list
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0025CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
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
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(16.0),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(dialogContext).size.height * 0.4,
                maxWidth: MediaQuery.of(dialogContext).size.width * 0.8,
              ),
              child: SingleChildScrollView(
                child: ErrorAnimation(
                  message: e.toString().replaceFirst('Exception: ', ''),
                  onDismiss: () {}, // No auto-dismiss
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0025CC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


Widget _buildDeleteButton(Medicine med) {
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


  String _getNextReminderTime(String frequency) {
    final now = DateTime.now();
    if (frequency.toLowerCase().contains('morning')) {
      return '08:00 AM';
    } else if (frequency.toLowerCase().contains('evening')) {
      return '08:00 PM';
    } else if (frequency.toLowerCase().contains('twice')) {
      return '08:00 AM, 08:00 PM';
    } else if (frequency.toLowerCase().contains('three')) {
      return '08:00 AM, 02:00 PM, 08:00 PM';
    } else {
      return '08:00 AM';
    }
  }


  @override
  Widget build(BuildContext context) {
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
          // Background pattern
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
                                return _buildMedicineCard(_userMedicines[index]);
                              },
                            ),
                ),
                const SizedBox(height: 80), // Space for FAB
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
      // bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
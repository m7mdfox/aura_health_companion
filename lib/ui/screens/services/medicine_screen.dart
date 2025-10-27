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

      print('Fetch medicines response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userMedicines = (data['medicines'] as List)
              .map((m) => Medicine.fromJson(m))
              .toList();
        });
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
        await showDialog(
          context: context,
          builder: (context) => ErrorAnimation(
            message: 'Failed to load medicines: $e',
            onDismiss: () => Navigator.of(context).pop(),
          ),
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
          'duration_days': int.parse(_durationController.text.trim()).toString(),
          'quantity': int.parse(_quantityController.text.trim()).toString(),
        };

        try {
          int.parse(_durationController.text.trim());
          int.parse(_quantityController.text.trim());
        } catch (e) {
          if (mounted) {
            await showDialog(
              context: context,
              builder: (context) => ErrorAnimation(
                message: 'Please enter valid numbers for duration and quantity',
                onDismiss: () => Navigator.of(context).pop(),
              ),
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
            await showDialog(
              context: context,
              builder: (context) => SuccessAnimation(
                message: 'Medicine added successfully!',
                onComplete: () {
                  Navigator.of(context).pop();
                  _fetchUserMedicines();
                },
              ),
            );
            _addMedicineFormKey.currentState!.reset();
            _tradeNameController.clear();
            _concentrationController.clear();
            _doseController.clear();
            _frequencyController.clear();
            _durationController.clear();
            _quantityController.clear();
            _activeIngredientController.clear();
            Navigator.of(context).pop();
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
            await showDialog(
              context: context,
              builder: (context) => ErrorAnimation(
                message: 'Medicine conflicts detected:\n$conflictMessages',
                onDismiss: () => Navigator.of(context).pop(),
              ),
            );
          }
        } else {
          throw Exception('Failed to add medicine: ${response.body}');
        }
      } catch (e) {
        print('Add medicine error: $e');
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => ErrorAnimation(
              message: e.toString(),
              onDismiss: () => Navigator.of(context).pop(),
            ),
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
        final url = Uri.parse('http://10.0.2.2:4000/api/medicine/check-interaction');
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

        print('Check interaction response: ${response.statusCode} ${response.body}');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (mounted) {
            final message = data['interaction']
                ? 'Interaction found: ${data['description']}'
                : 'No interaction found between these medicines.';
            await showDialog(
              context: context,
              builder: (context) => data['interaction']
                  ? ErrorAnimation(
                      message: message,
                      onDismiss: () => Navigator.of(context).pop(),
                    )
                  : SuccessAnimation(
                      message: message,
                      onComplete: () => Navigator.of(context).pop(),
                    ),
            );
            _checkInteractionFormKey.currentState!.reset();
            _medicine1Controller.clear();
            _medicine2Controller.clear();
            Navigator.of(context).pop(); // Close the dialog
          }
        } else {
          throw Exception('Failed to check interaction: ${response.body}');
        }
      } catch (e) {
        print('Check interaction error: $e');
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => ErrorAnimation(
              message: e.toString(),
              onDismiss: () => Navigator.of(context).pop(),
            ),
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
      await showDialog(
        context: context,
        builder: (context) => ErrorAnimation(
          message: 'Out of Stock! You have no more doses of ${med.tradeName}. Please reorder.',
          onDismiss: () => Navigator.of(context).pop(),
        ),
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
        await showDialog(
          context: context,
          builder: (context) => SuccessAnimation(
            message: 'You have successfully taken your dose of ${med.tradeName}.',
            onComplete: () {
              Navigator.of(context).pop();
              _fetchUserMedicines(); // Refresh the medicine list
            },
          ),
        );
      }
      // Show warning if quantity is low
      if (med.quantity == 6) { // Check before decrement
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${med.tradeName} is running out! Only 5 doses left. Time to order.'),
              backgroundColor: Colors.orange.shade800,
              duration: const Duration(seconds: 5),
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
      await showDialog(
        context: context,
        builder: (context) => ErrorAnimation(
          message: 'Failed to update dose: $e',
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}



  Widget _buildMedicineStrip(Medicine med) {
    int totalPills = med.quantity;
    int maxPillsToShow = 10;
    List<Widget> pills = [];

    Color pillColor = totalPills <= 5 ? Colors.red.shade300 : Colors.teal.shade300;
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
            style: const TextStyle(fontWeight: FontWeight.w500),
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
              const Icon(Icons.notification_important, color: Colors.red, size: 18),
              const SizedBox(width: 4),
              Text(
                warningText,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        const SizedBox(height: 4),
        Row(children: pills),
      ],
    );
  }

  void _showAddMedicineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Medicine', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: _addMedicineFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tradeNameController,
                  decoration: _buildInputDecoration('Trade Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter trade name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _concentrationController,
                  decoration: _buildInputDecoration('Concentration (e.g., 500 mg)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _doseController,
                  decoration: _buildInputDecoration('Dose (e.g., 1 tablet)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter dose';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _frequencyController,
                  decoration: _buildInputDecoration('Frequency (e.g., twice daily)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter frequency';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: _buildInputDecoration('Duration (days)'),
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
                TextFormField(
                  controller: _quantityController,
                  decoration: _buildInputDecoration('Quantity'),
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
                TextFormField(
                  controller: _activeIngredientController,
                  decoration: _buildInputDecoration('Active Ingredient'),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addMedicine,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0025CC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Add Medicine'),
          ),
        ],
      ),
    );
  }

  void _showCheckInteractionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Check Drug Interaction', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: _checkInteractionFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _medicine1Controller,
                  decoration: _buildInputDecoration('Medicine 1'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first medicine';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _medicine2Controller,
                  decoration: _buildInputDecoration('Medicine 2'),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _checkInteraction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0025CC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Check Interaction'),
          ),
        ],
      ),
    );
  }

  void _showActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Action',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close bottom sheet
                _showAddMedicineDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0025CC),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Medicine', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close bottom sheet
                _showCheckInteractionDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0025CC),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Check Interaction', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0025CC), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F1120), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: TextStyle(
        color: Colors.red,
        fontFamily: GoogleFonts.inter().fontFamily,
        fontSize: 12,
      ),
    );
  }

  Widget _buildMedicineCard(Medicine med) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  med.tradeName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00177E),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () {
                    // TODO: Implement API call to delete medicine
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${med.tradeName} removed')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${med.dose} - ${med.frequency}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Active Ingredient: ${med.activeIngredient}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (med.concentration != null && med.concentration!.isNotEmpty)
              Text(
                'Concentration: ${med.concentration}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            Text(
              'Quantity: ${med.quantity} capsules',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              'Duration: ${med.durationDays} days',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Divider(height: 20),
            // Medicine Strip Visualization
            _buildMedicineStrip(med),
            const SizedBox(height: 16),
            // Take Dose Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _takeDose(med),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Take Dose Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medicine Manager',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ServicesScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              opacity: 0.3,
              child: Image.asset(
                'assets/PatternLogin.png',
                width: screenWidth,
                height: MediaQuery.of(context).size.height * 0.5,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
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
                            const Text(
                              'No medicines added yet.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _userMedicines.length,
                        itemBuilder: (context, index) {
                          return _buildMedicineCard(_userMedicines[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showActionBottomSheet,
        backgroundColor: const Color(0xFF00177E),
        foregroundColor: Colors.white,
        label: const Text('Actions'),
      ),
    );
  }
}
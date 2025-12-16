import 'dart:io';
import 'package:aura_health_companion/ui/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:aura_health_companion/data/profile_service.dart';
import 'package:aura_health_companion/data/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileModel userProfile;

  const EditProfilePage({super.key, required this.userProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _birthdateController;
  
  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _selectedBirthdate;
  bool _isSaving = false;
  
  File? _selectedImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['male', 'female', 'other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(text: widget.userProfile.phone ?? '');
    _weightController = TextEditingController(
      text: widget.userProfile.weight > 0 ? widget.userProfile.weight.toString() : ''
    );
    _heightController = TextEditingController(
      text: widget.userProfile.height > 0 ? widget.userProfile.height.toString() : ''
    );
    
    if (widget.userProfile.age > 0) {
      final now = DateTime.now();
      _selectedBirthdate = DateTime(now.year - widget.userProfile.age, now.month, now.day);
      _birthdateController = TextEditingController(
        text: "${_selectedBirthdate!.year}-${_selectedBirthdate!.month.toString().padLeft(2, '0')}-${_selectedBirthdate!.day.toString().padLeft(2, '0')}"
      );
    } else {
      _birthdateController = TextEditingController();
    }
    
    _selectedGender = widget.userProfile.gender;
    _selectedBloodType = widget.userProfile.bloodType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildAvatarSection(),
                const SizedBox(height: 30),
                _buildPersonalInfoSection(),
                const SizedBox(height: 20),
                _buildHealthInfoSection(),
                const SizedBox(height: 30),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    String? fullAvatarUrl;
    if (widget.userProfile.avatarUrl != null && 
        widget.userProfile.avatarUrl!.isNotEmpty && 
        widget.userProfile.avatarUrl != '') {
      if (widget.userProfile.avatarUrl!.startsWith('http://') || 
          widget.userProfile.avatarUrl!.startsWith('https://')) {
        fullAvatarUrl = widget.userProfile.avatarUrl;
      } else {
        fullAvatarUrl = '${AuthService.baseUrl}${widget.userProfile.avatarUrl}';
      }
    }

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF00177E).withOpacity(0.2),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: _selectedImageFile != null
                  ? FileImage(_selectedImageFile!) as ImageProvider
                  : (fullAvatarUrl != null 
                      ? NetworkImage(fullAvatarUrl)
                      : null),
                onBackgroundImageError: fullAvatarUrl != null
                  ? (exception, stackTrace) {
                      print('Failed to load avatar: $exception');
                    }
                  : null,
                child: (_selectedImageFile == null && fullAvatarUrl == null)
                  ? Text(
                      widget.userProfile.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00177E),
                      ),
                    )
                  : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _changeAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00177E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        if (_selectedImageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'New image selected',
              style: TextStyle(
                color: Colors.green[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
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
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person,
            validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            enabled: false,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          _buildDateField(),
          const SizedBox(height: 15),
          _buildDropdown(
            value: _selectedGender,
            items: _genders,
            label: 'Gender',
            icon: Icons.wc,
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
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
          Text(
            'Health Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final weight = double.tryParse(value!);
                    if (weight == null || weight < 20 || weight > 300) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final height = double.tryParse(value!);
                    if (height == null || height < 50 || height > 300) return 'Invalid';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildDropdown(
            value: _selectedBloodType,
            items: _bloodTypes,
            label: 'Blood Type',
            icon: Icons.bloodtype,
            onChanged: (value) => setState(() => _selectedBloodType = value),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? const Color(0xFF00177E) : Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00177E), width: 2),
        ),
        filled: true,
        fillColor: enabled 
          ? (isDark ? const Color(0xFF0F1120) : Colors.grey[50])
          : (isDark ? const Color(0xFF0A0C15) : Colors.grey[200]),
      ),
    );
  }

  Widget _buildDateField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: _birthdateController,
      readOnly: true,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: 'Birthdate',
        prefixIcon: const Icon(Icons.cake, color: Color(0xFF00177E)),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, color: isDark ? Colors.white54 : Colors.grey),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedBirthdate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedBirthdate = date;
                _birthdateController.text =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
              });
            }
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00177E), width: 2),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F1120) : Colors.grey[50],
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Please select birthdate' : null,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00177E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00177E), width: 2),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F1120) : Colors.grey[50],
      ),
      dropdownColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item.toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00177E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }

  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF00177E)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF00177E)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImageFile != null || widget.userProfile.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImageFile = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updates = <String, dynamic>{
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'weight_kg': double.parse(_weightController.text),
        'height_cm': double.parse(_heightController.text),
        'chronic_conditions': widget.userProfile.chronicDiseases,
      };

      if (_selectedGender != null) {
        updates['gender'] = _selectedGender;
      }

      if (_selectedBloodType != null) {
        updates['blood_type'] = _selectedBloodType;
      }

      if (_selectedBirthdate != null) {
        updates['birthdate'] = _selectedBirthdate!.toIso8601String();
      }

      String? uploadedAvatarUrl;
      if (_selectedImageFile != null) {
        try {
          uploadedAvatarUrl = await ProfileService.uploadAvatar(_selectedImageFile!.path);
          updates['avatar_url'] = uploadedAvatarUrl;
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Avatar upload failed: ${e.toString()}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      final updatedProfile = await ProfileService.updateProfile(updates);

      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        
        Navigator.pop(context, updatedProfile);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
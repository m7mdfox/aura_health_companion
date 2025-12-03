import 'package:aura_health_companion/models/appointment_model.dart';
import 'package:aura_health_companion/models/doctor_model.dart';
import 'package:aura_health_companion/services/api_service.dart';
import 'package:aura_health_companion/ui/screens/doctor/chat-screen.dart';
// ⚠️ Ensure this path matches your project structure
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';

class DoctorRequestScreen extends StatefulWidget {
  const DoctorRequestScreen({super.key});

  @override
  State<DoctorRequestScreen> createState() => _DoctorRequestScreenState();
}

class _DoctorRequestScreenState extends State<DoctorRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // ⚠️ YOUR PATIENT ID (Ensure this matches your MongoDB User ID)
  final String currentPatientId = "656a1b2c9d8e7f9999999999"; 

  late Future<List<Doctor>> _doctorsFuture;
  late Future<List<Appointment>> _appointmentsFuture;

  // Search & Filter State
  int _selectedFilterIndex = 0;
  String _searchQuery = "";
  final List<String> _filters = ["All", "Cardiology", "Neurology", "Dermatology", "Psychiatry"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _doctorsFuture = ApiService.getDoctors();
      _appointmentsFuture = ApiService.getPatientAppointments(currentPatientId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 🔍 THE ROBUST "IS CHAT ACTIVE?" LOGIC
  // ---------------------------------------------------------------------------
  bool _isAppointmentActive(Appointment appt) {
    // 1. Check Status
    if (appt.status.toLowerCase() != 'confirmed') return false;

    final now = DateTime.now();

    // 2. CONVERT UTC TO LOCAL TIME
    // This is critical. MongoDB dates are UTC. Your phone is Local.
    // Without this, "Today" might look like "Yesterday" or "Tomorrow".
    final apptDateLocal = appt.date.toLocal();

    // 3. Check Date Match
    bool isSameDay = apptDateLocal.year == now.year && 
                     apptDateLocal.month == now.month && 
                     apptDateLocal.day == now.day;
    
    if (!isSameDay) return false;

    try {
      // 4. Parse "HH:mm" Strings
      DateFormat timeFormat = DateFormat("HH:mm");
      DateTime startParsed = timeFormat.parse(appt.startTime);
      DateTime endParsed = timeFormat.parse(appt.endTime);

      // 5. Build Today's Date Objects
      // We take the HOURS from the parsed string and combine them with TODAY'S date.
      DateTime startDateTime = DateTime(now.year, now.month, now.day, startParsed.hour, startParsed.minute);
      DateTime endDateTime = DateTime(now.year, now.month, now.day, endParsed.hour, endParsed.minute);

      // 6. Check Time Window (Inclusive)
      // We subtract/add 1 minute buffer to handle exact minute matches
      return now.isAfter(startDateTime.subtract(const Duration(minutes: 1))) && 
             now.isBefore(endDateTime.add(const Duration(minutes: 1)));

    } catch (e) {
      print("Error parsing appointment time: $e");
      return false;
    }
  }

  // --- Helper: Calculate End Time String ---
  String _calculateEndTime(String startTime, int durationMinutes) {
    final format = DateFormat("HH:mm"); 
    final start = format.parse(startTime);
    final end = start.add(Duration(minutes: durationMinutes));
    return format.format(end);
  }

  // --- Helper: Submit to Backend ---
  Future<void> _submitAppointmentRequest(
      Doctor doctor, DateTime date, TimeOfDay time, String type, String notes) async {
    
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator())
    );

    try {
      final String startStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      
      final int duration = type.toLowerCase() == 'examination' 
          ? doctor.examDuration 
          : doctor.consultDuration;

      final String endStr = _calculateEndTime(startStr, duration);

      await ApiService.createAppointment(
        doctorId: doctor.id,
        patientId: currentPatientId,
        date: date,
        startTime: startStr,
        endTime: endStr,
        type: type,
        notes: notes,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close summary
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request Sent Successfully!"), backgroundColor: Colors.green),
        );
        
        _fetchData(); 
        _tabController.animateTo(1); 
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString().replaceAll('Exception:', '')}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // UI BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Doctor Services', style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00177E),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00177E),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [Tab(text: "Find Doctor"), Tab(text: "Requests"), Tab(text: "Chat")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindDoctorTab(),
          _buildRequestsTab(),
          _buildChatTab(), 
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: FIND DOCTOR (Dynamic Search & Filter)
  // ---------------------------------------------------------------------------
  Widget _buildFindDoctorTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: "Search doctor name or specialty...",
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Ionicons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        // Filters
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedFilterIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilterIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00177E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    _filters[index],
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: FutureBuilder<List<Doctor>>(
            future: _doctorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No doctors found"));
              }

              // Filter Logic
              List<Doctor> doctors = snapshot.data!;
              
              // 1. Category Filter
              if (_selectedFilterIndex != 0) {
                 final filter = _filters[_selectedFilterIndex].toLowerCase();
                 doctors = doctors.where((d) => d.specialty.toLowerCase().contains(filter)).toList();
              }
              // 2. Search Filter
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                doctors = doctors.where((d) => 
                  d.name.toLowerCase().contains(query) || 
                  d.specialty.toLowerCase().contains(query)
                ).toList();
              }

              if (doctors.isEmpty) return const Center(child: Text("No doctors found"));

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _buildDoctorCard(doctors[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70, width: 70,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Ionicons.person, size: 30, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(doctor.specialty, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF3B82F6))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startAppointmentFlow(doctor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00177E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Request Appointment", style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: REQUESTS
  // ---------------------------------------------------------------------------
  Widget _buildRequestsTab() {
    return FutureBuilder<List<Appointment>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No requests yet", style: GoogleFonts.poppins(color: Colors.grey)));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final req = snapshot.data![index];
            Color statusColor = req.status == 'confirmed' ? Colors.green : Colors.orange;
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Ionicons.calendar, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(req.doctor?.name ?? "Unknown", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        Text("${req.type} • ${req.startTime}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                        Text(DateFormat('yyyy-MM-dd').format(req.date), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(req.status.toUpperCase(), style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: CHAT (Uses _isAppointmentActive)
  // ---------------------------------------------------------------------------
  Widget _buildChatTab() {
    return FutureBuilder<List<Appointment>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No appointments found", style: GoogleFonts.poppins(color: Colors.grey)));
        }

        // 🔍 FILTER LIST: Only show appointments valid RIGHT NOW
        final activeChats = snapshot.data!.where((appt) => _isAppointmentActive(appt)).toList();

        if (activeChats.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Ionicons.chatbubble_ellipses_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text("No Active Chats", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(
                    "Chat opens only during the confirmed appointment time.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeChats.length,
          itemBuilder: (context, index) {
            final appt = activeChats[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00177E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF00177E).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Ionicons.chatbubbles, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Session Active", style: GoogleFonts.poppins(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(appt.doctor?.name ?? "Doctor", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Ends at ${appt.endTime}", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            doctorId: appt.doctor?.id ?? "",
                            doctorName: appt.doctor?.name ?? "Doctor",
                            patientId: currentPatientId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00177E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Join"),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // APPOINTMENT FLOW
  // ---------------------------------------------------------------------------
  void _startAppointmentFlow(Doctor doctor, {
    DateTime? initialDate,
    TimeOfDay? initialTime,
    String? initialType,
    String? initialDesc,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentFormSheet(
        doctor: doctor,
        initialDate: initialDate,
        initialTime: initialTime,
        initialType: initialType,
        initialDesc: initialDesc,
        onSubmit: (date, time, type, desc) {
          Navigator.pop(context); // Close Form
          _showSummaryDialog(doctor, date, time, type, desc);
        },
      ),
    );
  }

  void _showSummaryDialog(
      Doctor doctor, DateTime date, TimeOfDay time, String type, String desc) {
    double price = type == 'Examination' ? doctor.examPrice : doctor.consultPrice;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text("Review Request", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Confirm booking?", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 10),
            _summaryRow("Date", DateFormat('yyyy-MM-dd').format(date)),
            _summaryRow("Time", time.format(context)),
            _summaryRow("Type", type),
            _summaryRow("Price", "\$${price.toInt()}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () => _submitAppointmentRequest(doctor, date, time, type, desc),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00177E)),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LOCAL WIDGET: FORM SHEET (Dynamic Pricing)
// -----------------------------------------------------------------------------
class _AppointmentFormSheet extends StatefulWidget {
  final Doctor doctor;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final String? initialType;
  final String? initialDesc;
  final Function(DateTime, TimeOfDay, String, String) onSubmit;

  const _AppointmentFormSheet({
    required this.doctor,
    required this.onSubmit,
    this.initialDate,
    this.initialTime,
    this.initialType,
    this.initialDesc,
  });

  @override
  State<_AppointmentFormSheet> createState() => _AppointmentFormSheetState();
}

class _AppointmentFormSheetState extends State<_AppointmentFormSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _visitType = 'Examination';
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    _visitType = widget.initialType ?? 'Examination';
    _descController = TextEditingController(text: widget.initialDesc);
  }
  
  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Pricing Calculation
    double currentPrice = _visitType == 'Examination' 
        ? widget.doctor.examPrice 
        : widget.doctor.consultPrice;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text("Book with ${widget.doctor.name}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _typeOption('Examination', "\$${widget.doctor.examPrice.toInt()}")),
              const SizedBox(width: 15),
              Expanded(child: _typeOption('Consultation', "\$${widget.doctor.consultPrice.toInt()}")),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Ionicons.calendar),
                  label: Text(_selectedDate == null ? "Date" : DateFormat('MM/dd').format(_selectedDate!)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Ionicons.time),
                  label: Text(_selectedTime == null ? "Time" : _selectedTime!.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Briefly describe symptoms...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_selectedDate != null && _selectedTime != null) {
                widget.onSubmit(_selectedDate!, _selectedTime!, _visitType, _descController.text);
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select date and time")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00177E),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("Review (\$${currentPrice.toInt()})", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _typeOption(String label, String price) {
    bool isSelected = _visitType == label;
    return GestureDetector(
      onTap: () => setState(() => _visitType = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00177E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF00177E) : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF00177E).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(price, style: GoogleFonts.poppins(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
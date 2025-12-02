import 'doctor_model.dart';

class Appointment {
  final String id;
  final Doctor? doctor; // Populated doctor object
  final DateTime date;
  final String startTime;
  final String endTime; // <--- Added this field
  final String status; // requested, confirmed, etc.
  final String type;

  Appointment({
    required this.id,
    this.doctor,
    required this.date,
    required this.startTime,
    required this.endTime, // <--- Added to constructor
    required this.status,
    required this.type,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'],
      // Handle populated doctor field or raw ID if not populated
      doctor: json['doctor_id'] is Map<String, dynamic> 
          ? Doctor.fromJson(json['doctor_id']) 
          : null,
      date: DateTime.parse(json['appointment_date']),
      startTime: json['start_time'],
      // Ensure your backend sends 'end_time'. If it might be null, provide a default or handle it.
      endTime: json['end_time'] ?? _calculateDefaultEnd(json['start_time']), 
      status: json['status'],
      type: json['type'],
    );
  }

  // Helper: If backend forgets to send end_time, estimate it (e.g. +30 mins)
  // This prevents the app from crashing if the field is missing
  static String _calculateDefaultEnd(String start) {
    try {
      // Simple parse HH:mm
      final parts = start.split(":");
      final dt = DateTime(2024, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      final end = dt.add(const Duration(minutes: 30));
      return "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return start; // Fallback
    }
  }
}
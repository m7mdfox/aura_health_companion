import 'doctor_model.dart';

class Appointment {
  final String id;
  final Doctor? doctor; // Populated doctor object
  final DateTime date;
  final String startTime;
  final String status; // requested, confirmed, etc.
  final String type;

  Appointment({
    required this.id,
    this.doctor,
    required this.date,
    required this.startTime,
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
      status: json['status'],
      type: json['type'],
    );
  }
}
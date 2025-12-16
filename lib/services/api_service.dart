import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

class ApiService {
  // ✅ تأكد أن البورت هو 4000 كما هو في server.js الخاص بك
  static const String baseUrl = 'http://10.0.2.2:4000';

  // --- Doctors ---

  static Future<List<Doctor>> getDoctors() async {
    // ✅ إضافة /api لتتوافق مع server.js
    final url = Uri.parse('$baseUrl/api/doctors');

    print("Flutter Request: $url"); // للمراقبة

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Doctor.fromJson(json)).toList();
    } else {
      print("Server Error: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to load doctors');
    }
  }

  // --- Appointments ---

  static Future<void> createAppointment({
    required String doctorId,
    required String patientId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String type,
    required String notes,
  }) async {
    // ✅ إضافة /api
    final url = Uri.parse('$baseUrl/api/appointments/request');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'doctor_id': doctorId,
        'patient_id': patientId,
        'appointment_date': date.toIso8601String(),
        'start_time': startTime,
        'end_time': endTime,
        'type': type.toLowerCase(),
        'notes': notes,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed: ${response.body}');
    }
  }

  static Future<List<Appointment>> getPatientAppointments(
      String patientId) async {
    // ✅ إضافة /api
    final url = Uri.parse('$baseUrl/api/appointments/patient/$patientId');

    print("Flutter Request: $url"); // للمراقبة

    final response = await http.get(url);

    print("Appointments Response Status: ${response.statusCode}");
    print(
        "Appointments Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load appointments: ${response.statusCode} - ${response.body}');
    }
  }
}

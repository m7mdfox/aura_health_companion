class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String clinicAddress;
  final double examPrice;
  final int examDuration;
  final double consultPrice;
  final int consultDuration;
  final double rating;
  
  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.clinicAddress,
    required this.examPrice,
    required this.examDuration,
    required this.consultPrice,
    required this.consultDuration,
    required this.rating,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'],
      name: json['name'],
      specialty: json['specialty'] ?? 'General',
      bio: json['bio'] ?? '',
      clinicAddress: json['clinic_address'] ?? '',
      examPrice: (json['price_examination'] ?? 0).toDouble(),
      examDuration: json['duration_of_examination'] ?? 20,
      consultPrice: (json['price_consultation'] ?? 0).toDouble(),
      consultDuration: json['duration_of_consultation'] ?? 30,
      rating: (json['rating_avg'] ?? 0).toDouble(),
    );
  }
}
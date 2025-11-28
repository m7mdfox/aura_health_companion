import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutritionService extends StatefulWidget {
  const NutritionService({super.key});

  @override
  State<NutritionService> createState() => _NutritionServiceState();
}

class _NutritionServiceState extends State<NutritionService> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
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
          'Nutrition Service',
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
      body: const Center(
        child: Text(
          'Welcome to the Nutrition Service!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
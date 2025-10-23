import 'package:aura_health_companion/ui/screens/services_screen.dart';
import 'package:flutter/material.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        
        // Button on the left side
        leading: IconButton(
          onPressed: () async {
            try {
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ServicesScreen(),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error navigating to Services Screen')),
                );
              }
            }
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


      
      body: const Center(
        child: Text(
          'Medicine Screennnnnnnnnnnnn',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
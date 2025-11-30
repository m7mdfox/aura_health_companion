import 'package:flutter/material.dart';

class NutritionLoadingScreen extends StatefulWidget {
  const NutritionLoadingScreen({super.key});

  @override
  State<NutritionLoadingScreen> createState() => _NutritionLoadingScreenState();
}

class _NutritionLoadingScreenState extends State<NutritionLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Nutrition Plan'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
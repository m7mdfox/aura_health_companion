import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessAnimation extends StatelessWidget {
  final String message;
  final VoidCallback onComplete;

  const SuccessAnimation({
    super.key,
    required this.message,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/Success.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                // Automatically close dialog after animation completes
                Future.delayed(composition.duration, () {
                  Navigator.of(context).pop();
                  onComplete();
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     onComplete();
            //   },
            //   child: const Text('OK'),
            // ),
          ],
        ),
      ),
    );
  }
}

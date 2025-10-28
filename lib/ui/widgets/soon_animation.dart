import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SoonAnimation extends StatelessWidget {
  final String message;
  final VoidCallback onComplete;

  const SoonAnimation({
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
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.4, // Reduced to 40% of screen height
          maxWidth:
              MediaQuery.of(context).size.width * 0.8, // 80% of screen width
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie animation with strict constraints
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                      // border: Border.all(color: Colors.grey, width: 1), // Debug border
                      ),
                  child: Lottie.asset(
                    'assets/animations/soon2.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                    onLoaded: (composition) {
                      if (context.mounted) {
                        Future.delayed(composition.duration, () {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            onComplete();
                          }
                        });
                      }
                    },
                  ),
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
                // Optional: Manual close button for testing
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
        ),
      ),
    );
  }
}

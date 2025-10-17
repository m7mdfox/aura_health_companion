import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class ErrorAnimation extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const ErrorAnimation({
    super.key,
    required this.message,
    required this.onDismiss,
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
            // Try to load the Lottie JSON at runtime. On some platforms the
            // asset may not be bundled or the path case may differ (Android
            // treats asset names case-sensitively). If loading fails, fall
            // back to a simple error icon so the dialog still appears.
            FutureBuilder<String>(
              future: rootBundle.loadString('assets/animations/Error.json'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Lottie.asset(
                    'assets/animations/Error.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  );
                }

                // Loading failed or still in progress: show a fallback icon.
                return SizedBox(
                  width: 150,
                  height: 150,
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 96,
                      color: Colors.red.shade400,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Login Failed',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onDismiss,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

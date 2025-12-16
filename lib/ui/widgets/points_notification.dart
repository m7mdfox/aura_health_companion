import 'package:flutter/material.dart';

/// A beautiful animated notification widget for showing points earned
class PointsNotification {
  /// Show a points earned notification
  static void show(
    BuildContext context, {
    required int points,
    required String message,
    String? action,
    VoidCallback? onDismiss,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PointsNotificationWidget(
        points: points,
        message: message,
        action: action,
        onDismiss: () {
          overlayEntry.remove();
          onDismiss?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        onDismiss?.call();
      }
    });
  }

  /// Show points notification using a SnackBar (simpler alternative)
  static void showSnackBar(
    BuildContext context, {
    required int points,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars,
                color: Colors.amber,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+$points Health Points! 🎉',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1D2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _PointsNotificationWidget extends StatefulWidget {
  final int points;
  final String message;
  final String? action;
  final VoidCallback onDismiss;

  const _PointsNotificationWidget({
    required this.points,
    required this.message,
    this.action,
    required this.onDismiss,
  });

  @override
  State<_PointsNotificationWidget> createState() =>
      _PointsNotificationWidgetState();
}

class _PointsNotificationWidgetState extends State<_PointsNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: widget.onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00177E), Color(0xFF1A1D2E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00177E).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Animated star icon
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: value * 2 * 3.14159,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.stars,
                                color: Colors.amber,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Points and message
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TweenAnimationBuilder<int>(
                              duration: const Duration(milliseconds: 600),
                              tween: IntTween(begin: 0, end: widget.points),
                              builder: (context, value, child) {
                                return Text(
                                  '+$value Health Points! 🎉',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.message,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close button
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        onPressed: widget.onDismiss,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

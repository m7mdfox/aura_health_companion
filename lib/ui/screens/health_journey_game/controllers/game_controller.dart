import 'package:flutter/material.dart';

class EnhancedGameControls extends StatelessWidget {
  final VoidCallback onLeftPressed;
  final VoidCallback onRightPressed;
  final VoidCallback onMoveStop;
  final VoidCallback onJump;
  final VoidCallback onDash;
  final VoidCallback onPunch;
  final VoidCallback onKick;
  
  const EnhancedGameControls({
    super.key,
    required this.onLeftPressed,
    required this.onRightPressed,
    required this.onMoveStop,
    required this.onJump,
    required this.onDash,
    required this.onPunch,
    required this.onKick,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left side - D-Pad Style Movement
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Jump button above
                _ModernButton(
                  icon: Icons.arrow_upward_rounded,
                  color: Colors.green,
                  label: 'قفز',
                  size: 70,
                  onPressed: onJump,
                  isToggle: false, onReleased: () {  },
                ),
                const SizedBox(height: 8),
                // Movement buttons
                Row(
                  children: [
                    _ModernButton(
                      icon: Icons.arrow_back_rounded,
                      color: Colors.blue,
                      label: '',
                      size: 65,
                      onPressed: onLeftPressed,
                      onReleased: onMoveStop,
                      isToggle: true,
                    ),
                    const SizedBox(width: 10),
                    _ModernButton(
                      icon: Icons.arrow_forward_rounded,
                      color: Colors.blue,
                      label: '',
                      size: 65,
                      onPressed: onRightPressed,
                      onReleased: onMoveStop,
                      isToggle: true,
                    ),
                  ],
                ),
              ],
            ),
            
            // Center - Dash Button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DashButton(onPressed: onDash),
              ],
            ),
            
            // Right side - Combat Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _ModernButton(
                      icon: Icons.sports_mma_rounded,
                      color: Colors.red,
                      label: 'لكمة',
                      size: 65,
                      onPressed: onPunch,
                      onReleased: () {},
                      isToggle: false,
                    ),
                    const SizedBox(width: 10),
                    _ModernButton(
                      icon: Icons.sports_kabaddi_rounded,
                      color: Colors.orange,
                      label: 'ركلة',
                      size: 65,
                      onPressed: onKick,
                      onReleased: () {},
                      isToggle: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double size;
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final bool isToggle;
  
  const _ModernButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.size,
    required this.onPressed,
    required this.onReleased,
    this.isToggle = false,
  });
  
  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton> with SingleTickerProviderStateMixin {
  bool isPressed = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  
  void _handlePress() {
    setState(() => isPressed = true);
    _animController.forward();
    widget.onPressed();
  }
  
  void _handleRelease() {
    setState(() => isPressed = false);
    _animController.reverse();
    widget.onReleased();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isToggle ? (_) => _handlePress() : null,
      onTapUp: widget.isToggle ? (_) => _handleRelease() : null,
      onTapCancel: widget.isToggle ? _handleRelease : null,
      onTap: !widget.isToggle ? () {
        _handlePress();
        Future.delayed(const Duration(milliseconds: 150), _handleRelease);
      } : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isPressed
                      ? [widget.color, widget.color.withOpacity(0.7)]
                      : [widget.color.withOpacity(0.9), widget.color.withOpacity(0.6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(isPressed ? 0.8 : 0.5),
                    blurRadius: isPressed ? 20 : 12,
                    spreadRadius: isPressed ? 4 : 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: widget.size * 0.45,
                  ),
                  if (widget.label.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.size * 0.15,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashButton extends StatefulWidget {
  final VoidCallback onPressed;
  
  const _DashButton({required this.onPressed});
  
  @override
  State<_DashButton> createState() => _DashButtonState();
}

class _DashButtonState extends State<_DashButton> with SingleTickerProviderStateMixin {
  bool isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => isPressed = true);
        widget.onPressed();
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => isPressed = false);
        });
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isPressed ? 0.85 : _pulseAnimation.value,
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isPressed
                      ? [Colors.deepPurple, Colors.purple.shade700]
                      : [Colors.purple, Colors.deepPurple.shade700],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isPressed ? Colors.deepPurple : Colors.purple).withOpacity(0.7),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 3,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Speed lines
                  ...List.generate(3, (index) {
                    return Positioned(
                      left: 15 + index * 8,
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white.withOpacity(0.3 - index * 0.1),
                        size: 30,
                      ),
                    );
                  }),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'اندفاع',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
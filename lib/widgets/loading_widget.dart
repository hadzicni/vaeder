import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Start animations
    _fadeController.repeat(reverse: true);
    _scaleController.forward();
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeAnimation,
          _scaleAnimation,
          _rotationAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glassmorphism container with rotating elements
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer rotating ring
                      Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CustomPaint(
                            painter: LoadingRingPainter(
                              progress: _rotationAnimation.value,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                      // Inner pulsing circle
                      Transform.scale(
                        scale: 0.8 + (_fadeAnimation.value * 0.2),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.3),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Weather icon
                      Icon(
                        Icons.wb_sunny_outlined,
                        color: Colors.white.withOpacity(_fadeAnimation.value),
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Animated text with dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Loading weather',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Animated dots
                    Row(
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _fadeController,
                          builder: (context, child) {
                            double delay = index * 0.3;
                            double animValue =
                                (_fadeController.value + delay) % 1.0;
                            return Opacity(
                              opacity: animValue < 0.5 ? 0.3 : 1.0,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Fetching current conditions...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for the loading ring
class LoadingRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  LoadingRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const double startAngle = -3.14159 / 2; // Start from top
    final double sweepAngle = 2 * 3.14159 * 0.75; // 75% of circle

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

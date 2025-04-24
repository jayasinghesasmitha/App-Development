import 'package:flutter/material.dart';
import 'package:my_app/pages/login.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _sunController;
  late AnimationController _textController;
  late Animation<double> _cloudAnimation;
  late Animation<double> _sunAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Cloud animation: moves clouds across the screen
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _cloudAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.linear),
    );

    // Sun animation: pulsates the sun
    _sunController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _sunAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _sunController, curve: Curves.easeInOut),
    );

    // Text slide-in animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _sunController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade300,
                    Colors.blue.shade900,
                  ],
                ),
              ),
            ),
          ),
          // Animated rain effect
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: RainPainter(),
              ),
            ),
          ),
          // Animated clouds
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _cloudAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CloudPainter(offset: _cloudAnimation.value),
                );
              },
            ),
          ),
          // Animated sun/moon
          Positioned(
            top: 50,
            right: 50,
            child: AnimatedBuilder(
              animation: _sunAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _sunAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow.shade300,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.shade200.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Text and button with slide-in animation
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
              child: SlideTransition(
                position: _textSlideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WeatherWise',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 6.0,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Real-time weather insights at your fingertips. Plan your day with confidence.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated button with scale and color transition
class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.orange,
      end: Colors.orange.shade700,
    ).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _buttonController.forward(),
      onExit: (_) => _buttonController.reverse(),
      child: AnimatedBuilder(
        animation: _buttonController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorAnimation.value,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: const Text(
                'Explore Now',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Cloud painter for animated clouds
class CloudPainter extends CustomPainter {
  final double offset;

  CloudPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Draw multiple clouds at different positions
    for (int i = 0; i < 3; i++) {
      final x = (size.width * (offset + i * 0.5)) % (size.width * 1.5) - size.width * 0.25;
      final y = size.height * (0.2 + i * 0.1);

      canvas.drawPath(
        Path()
          ..addOval(Rect.fromLTWH(x, y, 100, 50))
          ..addOval(Rect.fromLTWH(x + 50, y - 20, 80, 60))
          ..addOval(Rect.fromLTWH(x + 80, y, 90, 50)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CloudPainter oldDelegate) => oldDelegate.offset != offset;
}

// Rain painter for animated raindrops
class RainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0;

    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final speed = random.nextDouble() * 20 + 10;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 5, y + speed),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
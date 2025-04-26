import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:my_app/pages/login.dart';
import 'dart:math' as math;

class ResultsPage extends StatefulWidget {
  final String email;
  final String? weather;
  final int? rainAmount;
  final latlong2.LatLng location;

  const ResultsPage({
    Key? key,
    required this.email,
    required this.weather,
    required this.rainAmount,
    required this.location,
  }) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _lightningController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation for text and elements
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Lightning flash animation
    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _lightningController.dispose();
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
                    Colors.grey.shade900,
                    Colors.yellow.shade700,
                  ],
                ),
              ),
            ),
          ),
          // Animated lightning flashes
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _lightningController,
              builder: (context, child) {
                return CustomPaint(
                  painter: LightningPainter(animationValue: _lightningController.value),
                );
              },
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
                          ),
                        ),
                        child: const Text(
                          'Weather Report',
                          style: TextStyle(
                            fontSize: 32,
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
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
                          ),
                        ),
                        child: const Text(
                          'Current conditions at your selected location.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                          ),
                        ),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.white.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.cloud, color: Colors.blue, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'Weather Conditions',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (widget.weather != null && widget.rainAmount != null) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        widget.weather == "Sunny"
                                            ? Icons.wb_sunny
                                            : widget.weather == "Rainy"
                                                ? Icons.water_drop
                                                : widget.weather == "Windy"
                                                    ? Icons.air
                                                    : Icons.cloud,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Weather: ${widget.weather}',
                                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rain Amount: ${widget.rainAmount} mm',
                                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Row(
                                    children: const [
                                      Icon(Icons.error, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Data is not enough',
                                        style: TextStyle(fontSize: 16, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                          ),
                        ),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.white.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.location_on, color: Colors.blue, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'Location',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Coordinates: ${widget.location.latitude.toStringAsFixed(4)}, ${widget.location.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 300,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: widget.location,
                                        initialZoom: 14,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          subdomains: const ['a', 'b', 'c'],
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: widget.location,
                                              width: 80,
                                              height: 80,
                                              child: const Icon(
                                                Icons.location_pin,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                          ),
                        ),
                        child: AnimatedSubmitButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                              (route) => false,
                            );
                          },
                          text: 'Back to Login',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedSubmitButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AnimatedSubmitButton({required this.onPressed, required this.text, super.key});

  @override
  _AnimatedSubmitButtonState createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<AnimatedSubmitButton> with SingleTickerProviderStateMixin {
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

    _scaleAnimation = Tween<double>(begin: 1, end: 1.05).animate(
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
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorAnimation.value,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: Text(
                widget.text,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LightningPainter extends CustomPainter {
  final double animationValue;

  LightningPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final random = math.Random();
    final progress = animationValue;
    if (progress < 0.1) { // Flash occurs briefly
      final startX = size.width * random.nextDouble();
      final endX = startX + (random.nextDouble() * 100 - 50);
      final path = Path()
        ..moveTo(startX, 0)
        ..lineTo(startX + (endX - startX) * 0.3, size.height * 0.3)
        ..lineTo(startX + (endX - startX) * 0.6, size.height * 0.2)
        ..lineTo(endX, size.height * 0.5);

      canvas.drawPath(
        path,
        paint..color = Colors.white.withOpacity(progress / 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LightningPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
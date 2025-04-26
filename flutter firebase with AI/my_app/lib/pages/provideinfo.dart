import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_app/pages/confirmation.dart';
import 'dart:math' as math;

class ProvideInfoPage extends StatefulWidget {
  final String email;

  const ProvideInfoPage({Key? key, required this.email}) : super(key: key);

  @override
  _ProvideInfoPageState createState() => _ProvideInfoPageState();
}

class _ProvideInfoPageState extends State<ProvideInfoPage> with TickerProviderStateMixin {
  String _selectedWeather = "Sunny";
  double _rainAmount = 0.0;
  String _stayingOrMoving = "Staying";
  Position? _currentPosition;
  late AnimationController _fadeController;
  late AnimationController _cloudController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Fade animation for text and cards
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Cloud particle animation
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    final Map<String, dynamic> formData = {
      "email": widget.email,
      "selection": "Provide Information",
      "weather": _selectedWeather,
      "rainAmount": _rainAmount,
      "movement": _stayingOrMoving,
      "timestamp": DateTime.now().toIso8601String(),
      "location": _currentPosition != null
          ? {
              "latitude": _currentPosition!.latitude,
              "longitude": _currentPosition!.longitude,
            }
          : null,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/save-selection'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationPage(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save information'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    Colors.blue.shade100,
                    Colors.blue.shade400,
                  ],
                ),
              ),
            ),
          ),
          // Animated cloud particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                return CustomPaint(
                  painter: CloudParticlePainter(animationValue: _cloudController.value),
                );
              },
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1).animate(
                        CurvedAnimation(
                          parent: _fadeController,
                          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
                        ),
                      ),
                      child: const Text(
                        'Share Weather Data',
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
                        'Help others by providing local weather updates.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _fadeController,
                          curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                        ),
                      ),
                      child: _buildWeatherCard(),
                    ),
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _fadeController,
                          curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                        ),
                      ),
                      child: _buildRainSliderCard(),
                    ),
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _fadeController,
                          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                        ),
                      ),
                      child: _buildStayingOrMovingCard(),
                    ),
                    const SizedBox(height: 30),
                    AnimatedSubmitButton(onPressed: _submitForm),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
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
                Icon(Icons.wb_sunny, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text(
                  'Current Weather',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedWeather,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
              underline: const SizedBox(),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              items: ["Sunny", "Rainy", "Windy", "Cloudy"].map((weather) {
                return DropdownMenuItem<String>(
                  value: weather,
                  child: Row(
                    children: [
                      Icon(
                        weather == "Sunny"
                            ? Icons.wb_sunny
                            : weather == "Rainy"
                                ? Icons.water_drop
                                : weather == "Windy"
                                    ? Icons.air
                                    : Icons.cloud,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(weather),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWeather = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRainSliderCard() {
    return Card(
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
                Icon(Icons.water_drop, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Rain Intensity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.blue.withOpacity(0.3),
                thumbColor: Colors.white,
                overlayColor: Colors.blue.withOpacity(0.2),
                valueIndicatorColor: Colors.blue,
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
              ),
              child: Slider(
                value: _rainAmount,
                min: 0,
                max: 100,
                divisions: 20,
                label: "${_rainAmount.toInt()} %",
                onChanged: (value) {
                  setState(() {
                    _rainAmount = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStayingOrMovingCard() {
    return Card(
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
                Icon(Icons.directions_walk, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  'Your Movement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _stayingOrMoving == "Staying"
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RadioListTile<String>(
                      activeColor: Colors.blue,
                      title: const Text('Staying'),
                      value: "Staying",
                      groupValue: _stayingOrMoving,
                      onChanged: (value) {
                        setState(() {
                          _stayingOrMoving = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _stayingOrMoving == "Moving"
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RadioListTile<String>(
                      activeColor: Colors.blue,
                      title: const Text('Moving'),
                      value: "Moving",
                      groupValue: _stayingOrMoving,
                      onChanged: (value) {
                        setState(() {
                          _stayingOrMoving = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedSubmitButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedSubmitButton({required this.onPressed, super.key});

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
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CloudParticlePainter extends CustomPainter {
  final double animationValue;

  CloudParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      final progress = (animationValue + i * 0.125) % 1;
      final x = size.width * (0.2 + random.nextDouble() * 0.6);
      final y = size.height * (1 - progress);
      final sizeFactor = random.nextDouble() * 20 + 10;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: sizeFactor, height: sizeFactor * 0.6),
        paint..color = Colors.white.withOpacity(0.5 * (1 - progress)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CloudParticlePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_app/pages/results.dart';
import 'dart:math' as math;

class GetInfoPage extends StatefulWidget {
  final String email;

  const GetInfoPage({Key? key, required this.email}) : super(key: key);

  @override
  _GetInfoPageState createState() => _GetInfoPageState();
}

class _GetInfoPageState extends State<GetInfoPage> with TickerProviderStateMixin {
  String? selectedOption;
  latlong2.LatLng? selectedLocation;
  MapController mapController = MapController();
  Position? _currentPosition;
  late AnimationController _fadeController;
  late AnimationController _sparkleController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Fade animation for text and elements
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Sparkle animation for star-like effects
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sparkleController.dispose();
    mapController.dispose();
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
        if (selectedOption == 'Current Location') {
          selectedLocation = latlong2.LatLng(position.latitude, position.longitude);
        }
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

  Future<Map<String, dynamic>?> _fetchWeatherData(double latitude, double longitude) async {
    try {
      final database = FirebaseDatabase.instance;
      final usersRef = database.ref('users');
      final usersSnapshot = await usersRef.once();

      if (!usersSnapshot.snapshot.exists) {
        return null;
      }

      const double radius = 0.01; // ~1km radius for matching
      List<double> rainAmounts = [];
      List<String> weatherStatuses = [];

      for (var user in usersSnapshot.snapshot.children) {
        final infoRef = database.ref('users/${user.key}/information');
        final infoSnapshot = await infoRef.once();

        if (!infoSnapshot.snapshot.exists) {
          continue;
        }

        final information = infoSnapshot.snapshot.value as List<dynamic>?;
        if (information == null) {
          continue;
        }

        for (var data in information.asMap().entries) {
          if (data.value == null) continue;
          final location = data.value['location'];
          final docLatitude = location?['latitude']?.toDouble();
          final docLongitude = location?['longitude']?.toDouble();

          if (docLatitude != null && docLongitude != null) {
            final distance = Geolocator.distanceBetween(
              latitude,
              longitude,
              docLatitude,
              docLongitude,
            );

            if (distance <= radius * 111000) {
              final rainAmount = data.value['rainAmount'];
              final weather = data.value['weather'];
              if (rainAmount != null && weather != null) {
                rainAmounts.add(rainAmount.toDouble());
                weatherStatuses.add(weather.toString());
              }
            }
          }
        }
      }

      if (rainAmounts.isEmpty || weatherStatuses.isEmpty) {
        return null;
      }

      final avgRainAmount = rainAmounts.reduce((a, b) => a + b) / rainAmounts.length;

      final weatherCounts = <String, int>{};
      for (var weather in weatherStatuses) {
        weatherCounts[weather] = (weatherCounts[weather] ?? 0) + 1;
      }
      String mostFrequentWeather = weatherCounts.entries.reduce((a, b) {
        if (a.value > b.value) return a;
        if (b.value > a.value) return b;
        return a.key.compareTo(b.key) < 0 ? a : b;
      }).key;

      return {
        'weather': mostFrequentWeather,
        'rainAmount': avgRainAmount.round(),
      };
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching weather data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> handleSubmit() async {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedOption == 'Different Location' && selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedOption == 'Current Location' && _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final latitude = selectedOption == 'Current Location'
        ? _currentPosition!.latitude
        : selectedLocation!.latitude;
    final longitude = selectedOption == 'Current Location'
        ? _currentPosition!.longitude
        : selectedLocation!.longitude;

    final weatherData = await _fetchWeatherData(latitude, longitude);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          email: widget.email,
          weather: weatherData?['weather'],
          rainAmount: weatherData?['rainAmount'],
          location: latlong2.LatLng(latitude, longitude),
        ),
      ),
    );
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
                    Colors.purple.shade900,
                    Colors.blue.shade700,
                  ],
                ),
              ),
            ),
          ),
          // Animated star sparkles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: SparklePainter(animationValue: _sparkleController.value),
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
                          'Check Weather',
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
                          'Select a location to view weather data.',
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
                        child: _buildRadioOption(
                          title: 'Your Current Location',
                          value: 'Current Location',
                          icon: Icons.gps_fixed,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                        child: _buildRadioOption(
                          title: 'Different Location',
                          value: 'Different Location',
                          icon: Icons.map,
                        ),
                      ),
                      if (selectedOption == 'Different Location') ...[
                        const SizedBox(height: 20),
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1).animate(
                            CurvedAnimation(
                              parent: _fadeController,
                              curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tap to select a location:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 300,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: FlutterMap(
                                    mapController: mapController,
                                    options: MapOptions(
                                      initialCenter: const latlong2.LatLng(37.7749, -122.4194),
                                      initialZoom: 10,
                                      onTap: (tapPosition, point) {
                                        setState(() {
                                          selectedLocation = point;
                                        });
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        subdomains: const ['a', 'b', 'c'],
                                      ),
                                      if (selectedLocation != null)
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: selectedLocation!,
                                              width: 80,
                                              height: 80,
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 500),
                                                child: const Icon(
                                                  Icons.location_pin,
                                                  color: Colors.red,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (selectedLocation != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  'Selected: ${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      AnimatedSubmitButton(onPressed: handleSubmit),
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

  Widget _buildRadioOption({required String title, required String value, required IconData icon}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selectedOption == value ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: RadioListTile<String>(
        activeColor: Colors.orange,
        title: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        value: value,
        groupValue: selectedOption,
        onChanged: (value) {
          setState(() {
            selectedOption = value;
            if (value == 'Current Location' && _currentPosition != null) {
              selectedLocation = latlong2.LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
            } else {
              selectedLocation = null;
            }
          });
        },
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
                'Get Weather',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SparklePainter extends CustomPainter {
  final double animationValue;

  SparklePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final random = math.Random();
    for (int i = 0; i < 10; i++) {
      final progress = (animationValue + i * 0.1) % 1;
      if (progress < 0.5) {
        final x = size.width * random.nextDouble();
        final y = size.height * random.nextDouble();
        final sizeFactor = random.nextDouble() * 4 + 2;

        canvas.drawCircle(
          Offset(x, y),
          sizeFactor * progress,
          paint..color = Colors.white.withOpacity(progress),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
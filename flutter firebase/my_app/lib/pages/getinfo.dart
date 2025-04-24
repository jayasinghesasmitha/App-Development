import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_app/pages/results.dart';

class GetInfoPage extends StatefulWidget {
  final String email;

  const GetInfoPage({Key? key, required this.email}) : super(key: key);

  @override
  _GetInfoPageState createState() => _GetInfoPageState();
}

class _GetInfoPageState extends State<GetInfoPage> {
  String? selectedOption;
  latlong2.LatLng? selectedLocation;
  MapController mapController = MapController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

      // Iterate through all users
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

      // Calculate average rain amount
      final avgRainAmount = rainAmounts.reduce((a, b) => a + b) / rainAmounts.length;

      // Find the most frequent weather status
      final weatherCounts = <String, int>{};
      for (var weather in weatherStatuses) {
        weatherCounts[weather] = (weatherCounts[weather] ?? 0) + 1;
      }
      String mostFrequentWeather = weatherCounts.entries.reduce((a, b) {
        if (a.value > b.value) return a;
        if (b.value > a.value) return b;
        // If counts are equal, choose alphabetically first
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
      appBar: AppBar(
        title: const Text('Get Weather Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What area do you want to know the weather report?',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Your Current Location'),
                    value: 'Current Location',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                        if (_currentPosition != null) {
                          selectedLocation =
                              latlong2.LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Different Location'),
                    value: 'Different Location',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                        selectedLocation = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (selectedOption == 'Different Location') ...[
              const SizedBox(height: 20),
              const Text(
                'Please select the location:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Expanded(
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
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLocation!,
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
              if (selectedLocation != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Selected Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}',
                  style: const TextStyle(fontSize: 16),
                ),
              ]
            ],
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: handleSubmit,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
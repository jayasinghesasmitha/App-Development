import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ResultPage extends StatelessWidget {
  final String selectedOption;
  final LatLng? selectedLocation;

  const ResultPage({
    Key? key,
    required this.selectedOption,
    this.selectedLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Result')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selected Option: $selectedOption',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          if (selectedLocation != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Latitude: ${selectedLocation!.latitude}, Longitude: ${selectedLocation!.longitude}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            // In ResultPage, update the FlutterMap widget:

            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: selectedLocation!,
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
          ],
        ],
      ),
    );
  }
}

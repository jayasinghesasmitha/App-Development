import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ResultPage extends StatelessWidget {
  final String selectedOption;
  final LatLng? selectedLocation;

  ResultPage({required this.selectedOption, this.selectedLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Information Result'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You selected: $selectedOption',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              if (selectedOption == 'Different Location' && selectedLocation != null) ...[
                SizedBox(height: 20),
                Text(
                  'Location Coordinates:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Latitude: ${selectedLocation!.latitude}\nLongitude: ${selectedLocation!.longitude}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the previous page
                },
                child: Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
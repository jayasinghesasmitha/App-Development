import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/pages/result.dart';

class _GetInfoPageState extends State<GetInfoPage> {
  String? selectedOption; // To store the selected poll option
  LatLng? selectedLocation; // To store the selected location from the map
  GoogleMapController? mapController; // Map controller

  void handleSubmit() {
    if (selectedOption == 'Different Location' && selectedLocation == null) {
      // Show an error if "Different Location" is selected but no location is chosen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a location on the map.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to the ResultPage with the selected details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          selectedOption: selectedOption!,
          selectedLocation: selectedLocation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Weather Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What area do you want to know the weather report?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // Poll options
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Your Current Location'),
                    value: 'Current Location',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                        selectedLocation = null; // Clear selected location
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Different Location'),
                    value: 'Different Location',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (selectedOption == 'Different Location') ...[
              SizedBox(height: 20),
              Text(
                'Please select the location:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              // Google Maps widget
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.7749, -122.4194), // Default location
                    zoom: 10,
                  ),
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  onTap: (LatLng location) {
                    setState(() {
                      selectedLocation = location;
                    });
                  },
                  markers: selectedLocation != null
                      ? {
                          Marker(
                            markerId: MarkerId('selectedLocation'),
                            position: selectedLocation!,
                          )
                        }
                      : {},
                ),
              ),
              if (selectedLocation != null) ...[
                SizedBox(height: 10),
                Text(
                  'Selected Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}',
                  style: TextStyle(fontSize: 16),
                ),
              ]
            ],
            SizedBox(height: 20),
            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: handleSubmit,
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GetInfoPage extends StatefulWidget {
  @override
  _GetInfoPageState createState() => _GetInfoPageState();
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:my_app/pages/options.dart';

class GetInfoPage extends StatefulWidget {
  @override
  _GetInfoPageState createState() => _GetInfoPageState();
}

class _GetInfoPageState extends State<GetInfoPage> {
  String? selectedOption;
  latlong2.LatLng? selectedLocation;
  MapController mapController = MapController();
  bool showResult = false;

  void handleSubmit() {
    if (selectedOption == 'Different Location' && selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      showResult = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OptionsPage(email: '',)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showResult ? 'Weather Result' : 'Get Weather Information'),
        leading: showResult 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => showResult = false),
              )
            : null,
      ),
      body: showResult ? buildResultView() : buildInputView(),
    );
  }

  Widget buildInputView() {
    return Padding(
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
                      selectedLocation = null;
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
    );
  }

  Widget buildResultView() {
    return Column(
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
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: selectedLocation!,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
    );
  }
}

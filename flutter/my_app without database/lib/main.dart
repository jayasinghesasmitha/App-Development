import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App HomePage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background design
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),
          // Left Text Content
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'People love us for our technology. And the nice people who are always around to answer questions.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Image Content
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                height: 400,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.orangeAccent.withOpacity(0.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Portfolio value\n\$26,239.63',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Idea about weather give you good work',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
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

// Login Page
class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Text(
                'Please sign in to continue.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'user123@email.com',
                  labelText: 'EMAIL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  labelText: 'PASSWORD',
                  hintText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixText: 'FORGOT',
                  suffixStyle: TextStyle(color: Colors.orange),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OptionsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateAccountPage()),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Create Account Page
class CreateAccountPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Text(
                'Please fill in the details to create a new account.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Enter your username',
                  labelText: 'USERNAME',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'user123@email.com',
                  labelText: 'EMAIL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  labelText: 'PASSWORD',
                  hintText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle account creation logic here
                  print('Account created');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CREATE ACCOUNT',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Options Page
class OptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose an Option',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProvideInfoPage()),
                );
              },
              child: Text('Provide Information'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetInfoPage()),
                );
              },
              child: Text('Get Information'),
            ),
          ],
        ),
      ),
    );
  }
}

// Provide Information Page
class ProvideInfoPage extends StatefulWidget {
  @override
  _ProvideInfoPageState createState() => _ProvideInfoPageState();
}

class _ProvideInfoPageState extends State<ProvideInfoPage> {
  String _selectedWeather = "Sunny"; // Default weather type
  double _rainAmount = 0.0; // Rain amount slider value
  String _stayingOrMoving = "Staying"; // Default staying/moving choice

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provide Information'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather Section
              Card(
                elevation: 4,
                shadowColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What kind of weather is it right now?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedWeather,
                          isExpanded: true,
                          underline: SizedBox(),
                          items: [
                            "Sunny",
                            "Rainy",
                            "Windy",
                            "Cloudy",
                          ].map((weather) {
                            return DropdownMenuItem<String>(
                              value: weather,
                              child: Text(
                                weather,
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedWeather = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Rain Slider Section
              Card(
                elevation: 4,
                shadowColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How much rain is there?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Light'),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.blue,
                                inactiveTrackColor: Colors.blue.shade100,
                                thumbColor: Colors.lightBlue,
                                overlayColor: Colors.lightBlue.withOpacity(0.3),
                                valueIndicatorColor: Colors.lightBlue,
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
                          ),
                          Text('Heavy'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Staying or Moving Section
              Card(
                elevation: 4,
                shadowColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you staying or moving within the next 15 minutes?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              activeColor: Colors.green,
                              title: Text('Staying'),
                              value: "Staying",
                              groupValue: _stayingOrMoving,
                              onChanged: (value) {
                                setState(() {
                                  _stayingOrMoving = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              activeColor: Colors.green,
                              title: Text('Moving'),
                              value: "Moving",
                              groupValue: _stayingOrMoving,
                              onChanged: (value) {
                                setState(() {
                                  _stayingOrMoving = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle form submission logic here
                    print('Weather: $_selectedWeather');
                    print('Rain: ${_rainAmount.toInt()} %');
                    print('Staying or Moving: $_stayingOrMoving');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Background color
                    padding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Get Information Page
class GetInfoPage extends StatefulWidget {
  @override
  _GetInfoPageState createState() => _GetInfoPageState();
}

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
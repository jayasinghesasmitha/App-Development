/*import 'package:flutter/material.dart';
import 'package:my_app/pages/confirmation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: ProvideInfoPage(),
    );
  }
}

class ProvideInfoPage extends StatefulWidget {
  @override
  _ProvideInfoPageState createState() => _ProvideInfoPageState();
}

class _ProvideInfoPageState extends State<ProvideInfoPage> {
  String _selectedWeather = "Sunny"; // Default weather type
  double _rainAmount = 0.0; // Rain amount slider value
  String _stayingOrMoving = "Staying";

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
              _buildWeatherCard(),
              SizedBox(height: 20),
              // Rain Slider Section
              _buildRainSliderCard(),
              SizedBox(height: 20),
              // Staying or Moving Section
              _buildStayingOrMovingCard(),
              SizedBox(height: 30),
              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the ConfirmationPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmationPage(email: '',),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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

  Widget _buildWeatherCard() {
    return Card(
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
            DropdownButton<String>(
              value: _selectedWeather,
              isExpanded: true,
              underline: SizedBox(),
              items: ["Sunny", "Rainy", "Windy", "Cloudy"].map((weather) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildRainSliderCard() {
    return Card(
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
            Slider(
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
          ],
        ),
      ),
    );
  }

  Widget _buildStayingOrMovingCard() {
    return Card(
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
    );
  }
}*/



import 'package:flutter/material.dart';
import 'package:my_app/pages/confirmation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: ProvideInfoPage(),
    );
  }
}

class ProvideInfoPage extends StatefulWidget {
  @override
  _ProvideInfoPageState createState() => _ProvideInfoPageState();
}

class _ProvideInfoPageState extends State<ProvideInfoPage> {
  String _selectedWeather = "Sunny"; // Default weather type
  double _rainAmount = 0.0; // Rain amount slider value
  String _stayingOrMoving = "Staying";

  // Method to send data to the backend
  Future<void> _submitForm() async {
    final String email = "aaa"; // You can replace this with dynamic email from your login system
    final String selection = "Provide Information"; // This can be dynamic based on user interaction

    // Prepare the data to be sent
    final Map<String, dynamic> formData = {
      "email": email,
      "selection": selection,
      "weather": _selectedWeather,
      "rainAmount": _rainAmount,
      "movement": _stayingOrMoving,
    };

    // Log data to verify
    print('Submitting data: $formData');

    // Send the request to the backend
    final response = await http.post(
      Uri.parse('http://localhost:3000/save-selection'), // Update with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode(formData),
    );

    if (response.statusCode == 200) {
      // Navigate to the ConfirmationPage if successful
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationPage(email: email),
        ),
      );
    } else {
      // Handle errors (e.g., display a message)
      print('Failed to save selection: ${response.body}');
    }
  }

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
              _buildWeatherCard(),
              SizedBox(height: 20),
              // Rain Slider Section
              _buildRainSliderCard(),
              SizedBox(height: 20),
              // Staying or Moving Section
              _buildStayingOrMovingCard(),
              SizedBox(height: 30),
              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm, // Call the method to submit the form
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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

  Widget _buildWeatherCard() {
    return Card(
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
            DropdownButton<String>(
              value: _selectedWeather,
              isExpanded: true,
              underline: SizedBox(),
              items: ["Sunny", "Rainy", "Windy", "Cloudy"].map((weather) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildRainSliderCard() {
    return Card(
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
            Slider(
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
          ],
        ),
      ),
    );
  }

  Widget _buildStayingOrMovingCard() {
    return Card(
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
    );
  }
}



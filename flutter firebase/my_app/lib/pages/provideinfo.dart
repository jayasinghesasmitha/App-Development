import 'package:flutter/material.dart';
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
                        builder: (context) => ConfirmationPage(),
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
}


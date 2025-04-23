import 'package:flutter/material.dart';
import 'package:my_app/pages/confirmation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProvideInfoPage extends StatefulWidget {
  final String email;

  const ProvideInfoPage({Key? key, required this.email}) : super(key: key);

  @override
  _ProvideInfoPageState createState() => _ProvideInfoPageState();
}

class _ProvideInfoPageState extends State<ProvideInfoPage> {
  String _selectedWeather = "Sunny";
  double _rainAmount = 0.0;
  String _stayingOrMoving = "Staying";

  Future<void> _submitForm() async {
    final Map<String, dynamic> formData = {
      "email": widget.email,
      "selection": "Provide Information",
      "weather": _selectedWeather,
      "rainAmount": _rainAmount,
      "movement": _stayingOrMoving,
      "timestamp": DateTime.now().toIso8601String(),
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
          SnackBar(
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
              _buildWeatherCard(),
              SizedBox(height: 20),
              _buildRainSliderCard(),
              SizedBox(height: 20),
              _buildStayingOrMovingCard(),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
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
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiPredictPage extends StatefulWidget {
  const AiPredictPage({super.key});

  @override
  _AiPredictPageState createState() => _AiPredictPageState();
}

class _AiPredictPageState extends State<AiPredictPage> {
  String? _predictedWeather;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPrediction();
  }

  Future<void> _fetchPrediction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Fetch expired data from the server
      final dataResponse = await http.get(
        Uri.parse('http://10.0.2.2:3000/get-expired-data'),
        headers: {'Content-Type': 'application/json'},
      );

      if (dataResponse.statusCode != 200) {
        throw Exception('Failed to fetch data: ${dataResponse.body}');
      }

      final responseBody = json.decode(dataResponse.body);
      final expiredData = responseBody['data'] as List<dynamic>;

      if (expiredData.isEmpty) {
        setState(() {
          _predictedWeather = 'No data available for prediction';
        });
        return;
      }

      // Step 2: Prepare features for prediction
      // Take the most recent 10 entries (or fewer if less data is available)
      final recentData = expiredData.take(10).toList();
      
      // Calculate averages for numerical features
      final avgRainAmount = recentData.map((e) => e['rainAmount'] as num).reduce((a, b) => a + b) / recentData.length;
      final avgLatitude = recentData.map((e) => (e['location'] != null ? e['location']['latitude'] : 0) as num).reduce((a, b) => a + b) / recentData.length;
      final avgLongitude = recentData.map((e) => (e['location'] != null ? e['location']['longitude'] : 0) as num).reduce((a, b) => a + b) / recentData.length;
      
      // Get the latest timestamp and extract hour and day of week
      final latestTimestamp = recentData.map((e) => DateTime.parse(e['timestamp'] as String).millisecondsSinceEpoch).reduce((a, b) => a > b ? a : b);
      final hour = DateTime.fromMillisecondsSinceEpoch(latestTimestamp).hour;
      final dayOfWeek = DateTime.fromMillisecondsSinceEpoch(latestTimestamp).weekday;
      
      // Use the latest movement value (convert to number: Staying=0, Moving=1)
      final movement = recentData.last['movement'] == 'Staying' ? 0 : 1;

      // Step 3: Call the Flask server to get the prediction
      final predictResponse = await http.post(
        Uri.parse('http://10.0.2.2:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'rainAmount': avgRainAmount,
          'movement': movement,
          'hour': hour,
          'dayOfWeek': dayOfWeek,
          'latitude': avgLatitude,
          'longitude': avgLongitude,
        }),
      );

      if (predictResponse.statusCode == 200) {
        final prediction = json.decode(predictResponse.body)['prediction'];
        setState(() {
          _predictedWeather = prediction;
        });
      } else {
        throw Exception('Failed to get prediction: ${predictResponse.body}');
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Weather Predictor'),
        backgroundColor: Colors.purple.shade700,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade700, Colors.indigo.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.indigo.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AI Weather Prediction',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator(
                    color: Colors.purple,
                  )
                else if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  )
                else if (_predictedWeather != null)
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                _predictedWeather == 'Sunny'
                                    ? Icons.wb_sunny
                                    : _predictedWeather == 'Rainy'
                                        ? Icons.water_drop
                                        : _predictedWeather == 'Windy'
                                            ? Icons.air
                                            : Icons.cloud,
                                color: Colors.purple,
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Predicted Weather: $_predictedWeather',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'This prediction is based on historical weather data.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchPrediction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Refresh Prediction',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/pages/getinfo.dart';
import 'package:my_app/pages/provideinfo.dart';

class OptionsPage extends StatelessWidget {
  final String email;
  const OptionsPage({super.key, required this.email});

  String get apiUrl => 'http://localhost:3000/save-selection';

  Future<void> saveSelection(String selection) async {
    final url = Uri.parse(apiUrl);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'selection': selection}),
      );

      if (response.statusCode == 200) {
        print('Selection saved successfully.');
      } else {
        print('Failed to save selection: ${response.body}');
      }
    } catch (error) {
      print('Error saving selection: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose an Option',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProvideInfoPage(email: email),
                  ),
                );
              },
              child: const Text('Provide Information'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await saveSelection('Get Information');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GetInfoPage(email: email),
                  ),
                );
              },
              child: const Text('Get Information'),
            ),
          ],
        ),
      ),
    );
  }
}
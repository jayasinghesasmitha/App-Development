import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/firebase_options.dart';
import 'pages/createaccount.dart';
import 'pages/getinfo.dart';
import 'pages/homepage.dart';
import 'pages/login.dart';
import 'pages/options.dart';
import 'pages/provideinfo.dart';
import 'pages/result.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyAt2nLKOH4YxY70aTZ1qwxUV2hdwNLWJMo',
      appId: '1:426540662257:web:ca195e65993ed6b4215850',
      messagingSenderId: '426540662257',
      projectId: 'weather-app-8dff8',
      databaseURL: "https://weather-app-8dff8-default-rtdb.asia-southeast1.firebasedatabase.app", 
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Home Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(), 
        '/createaccount': (context) => CreateAccountPage(),
        '/getinfo': (context) => GetInfoPage(),
        '/login': (context) => LoginPage(),
        '/options': (context) => OptionsPage(),
        '/provideinfo': (context) => ProvideInfoPage(),
        '/result': (context) => ResultPage(selectedOption: '',),
      },
    );
  }
}

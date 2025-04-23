import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/createaccount.dart';
import 'pages/getinfo.dart';
import 'pages/homepage.dart';
import 'pages/login.dart';
import 'pages/options.dart';
import 'pages/provideinfo.dart';
import 'pages/confirmation.dart';

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle named routes with arguments
        switch (settings.name) {
          case '/options':
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => OptionsPage(email: args),
            );
          case '/provideinfo':
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ProvideInfoPage(email: args),
            );
          case '/confirmation':
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ConfirmationPage(email: args),
            );
        }

        // Default routes
        final routes = {
          '/': (context) => HomePage(),
          '/createaccount': (context) => CreateAccountPage(),
          '/getinfo': (context) => GetInfoPage(),
          '/login': (context) => LoginPage(),
        };

        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder);
        }

        // Handle unknown routes
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page not found')),
        ));
      },
    );
  }
}
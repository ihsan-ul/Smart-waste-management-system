import 'package:flutter/material.dart';
import 'package:smart_waste_management/db.dart';
import 'package:smart_waste_management/login_screen.dart';
import 'package:smart_waste_management/registration_screen.dart';
import 'home_screen.dart';
import 'image_classification_screen.dart';
import 'ai_assistant_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  runApp(SmartWasteManagementApp());
}

class SmartWasteManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(userId: 0),
        '/image-classification': (context) => ImageClassificationScreen(userId: 0),
        '/gemini-assistant': (context) => GeminiAssistantScreen(),
      },
    );
  }
}

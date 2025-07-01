import 'package:flutter/material.dart';
import 'package:smart_waste_management/image_classification_screen.dart';
import 'package:smart_waste_management/ai_assistant_screen.dart';
import 'package:smart_waste_management/login_screen.dart';
import 'package:smart_waste_management/waste_stats_screen.dart';

class HomeScreen extends StatelessWidget {
  final int userId;

  HomeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Waste Management"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade700, Colors.green.shade100],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildButton(
                            context,
                            "Image Classification",
                            Icons.image_search,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ImageClassificationScreen(userId: userId),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildButton(
                            context,
                            "Waste Management Assistant",
                            Icons.chat_bubble_outline,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GeminiAssistantScreen()),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildButton(
                            context,
                            "Waste Statistics",
                            Icons.bar_chart,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      WasteStatsScreen(userId: userId)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

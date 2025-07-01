import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class GeminiAssistantScreen extends StatefulWidget {
  @override
  _GeminiAssistantScreenState createState() => _GeminiAssistantScreenState();
}

class _GeminiAssistantScreenState extends State<GeminiAssistantScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _geminiResponse = "";
  bool _isGeminiLoading = false;
  String _userLocation = "your location";
  final String geminiApiKey = 'AIzaSyC_OTX3ADk_mpKiNYxSmx-g09ds1hz_QoE';

  @override
  void initState() {
    super.initState();
    _getLocationInfo(); 
  }

  Future<void> _getLocationInfo() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude, position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;

      String city = place.locality ?? "your city";
      String state = place.administrativeArea ?? "your state";
      String country = place.country ?? "your country";

      setState(() {
        _userLocation = "$city, $state, $country";
      });
    } else {
      setState(() {
        _userLocation = "your location";
      });
    }
  } catch (e) {
    print("Error fetching location: $e");
    setState(() {
      _userLocation = "your location";
    });
  }
}

  Future<void> _askGemini(String query) async {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The question cannot be empty. Please ask something.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeminiLoading = true;
      _geminiResponse = "";
    });

    try {

      String systemPrompt = """
      You are an AI expert specialized in waste management, recycling, sustainability, and garbage disposal. 
      Only answer questions that are directly related to waste management.
      If relevant to the user's question, their current location is $_userLocation.
      Even if the question is about other places, answer it without declining.
      If the user asks something unrelated, politely say:
      "I can only provide answers related to waste management."

      
      """;
      final content = [Content.text("$systemPrompt\nUser query: $query")];

      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: geminiApiKey);
      final response = await model.generateContent(content);

      setState(() {
        _geminiResponse = response.text ?? "Error: No response from Gemini.";
      });
    } catch (e) {
      setState(() {
        _geminiResponse = "Error communicating with Gemini: $e";
      });
    } finally {
      setState(() {
        _isGeminiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Waste Management Assistant"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _queryController,
                                  decoration: InputDecoration(
                                    hintText: "Ask a question about waste...",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    prefixIcon: Icon(Icons.search, color: Colors.green.shade600),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  ),
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _askGemini(_queryController.text);
                                  },
                                  icon: Icon(Icons.send),
                                  label: Text("Ask"),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_isGeminiLoading)
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            strokeWidth: 3,
                          )
                        else if (_geminiResponse.isNotEmpty)
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: MarkdownBody(
                                data: _geminiResponse,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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

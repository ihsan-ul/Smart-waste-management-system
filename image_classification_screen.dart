import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:smart_waste_management/db.dart';
import 'package:smart_waste_management/waste_stats_screen.dart';
import 'smart_waste_management.dart';

class ImageClassificationScreen extends StatefulWidget {
  final int userId;

  ImageClassificationScreen({required this.userId});

  @override
  _ImageClassificationScreenState createState() => _ImageClassificationScreenState();
}

class _ImageClassificationScreenState extends State<ImageClassificationScreen> {
  File? _image;
  String _label = "Upload or capture an image of waste";
  String _geminiResponse = "";
  late SmartWasteManagement _classifier;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _classifier = SmartWasteManagement(
      onClassification: (result) {
        setState(() {
          _label = result;
        });
        _updateWasteCount(result);
      },
      onGeminiResponse: (response) {
        setState(() {
          _geminiResponse = response;
          _isLoading = false;
        });
      },
    );
    _classifier.loadModel();
  }

  Future<void> _updateWasteCount(String wasteType) async {
    String dbWasteType;
    switch (wasteType) {
      case 'Recyclable':
        dbWasteType = 'recyclable';
        break;
      case 'Organic Waste':
        dbWasteType = 'organic';
        break;
      case 'General Waste':
        dbWasteType = 'general';
        break;
      default:
        return;
    }
    await DatabaseHelper.instance.updateWasteCount(widget.userId, dbWasteType);
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _label = "Processing...";
        _geminiResponse = "Thinking...";
        _isLoading = true;
      });
      await _classifier.classifyImage(_image!);
    }
  }

  Future<void> captureImageWithCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _label = "Processing...";
        _geminiResponse = "Thinking...";
        _isLoading = true;
      });
      await _classifier.classifyImage(_image!);
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Waste Classification"),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(_image!, height: 250, fit: BoxFit.cover),
                                )
                              : Icon(Icons.image, size: 100, color: Colors.green.shade700),
                          const SizedBox(height: 20),
                          Text(
                            _label,
                            style: TextStyle(fontSize: 20, color: Colors.green.shade900, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.photo_library, color: Colors.white),
                        label: Text("Upload Image", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: pickImageFromGallery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        label: Text("Capture Image", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: captureImageWithCamera,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.eco, color: Colors.white),
                        label: Text("Show Waste Stats", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WasteStatsScreen(userId: widget.userId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.teal.shade700)
                      : _geminiResponse.isNotEmpty
                          ? Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: MarkdownBody(
                                  data: _geminiResponse,
                                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                                    h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                                    p: TextStyle(fontSize: 18, color: Colors.teal.shade800),
                                    strong: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

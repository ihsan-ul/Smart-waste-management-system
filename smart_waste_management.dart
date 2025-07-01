import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SmartWasteManagement {
  late Interpreter interpreter;
  final Function(String) onClassification;
  final Function(String) onGeminiResponse;
  final String geminiApiKey = 'AIzaSyC_OTX3ADk_mpKiNYxSmx-g09ds1hz_QoE';

  SmartWasteManagement({required this.onClassification, required this.onGeminiResponse});

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/waste_classifier_Vgg16_besttflite.tflite');
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Float32List preprocessImage(File imageFile) {
    Uint8List imageBytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception("Could not decode image");
    }

    img.Image resized = img.copyResize(image, width: 150, height: 150);

    List<double> imagePixels = [];
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        imagePixels.add(pixel.r / 255.0);
        imagePixels.add(pixel.g / 255.0);
        imagePixels.add(pixel.b / 255.0);
      }
    }

    return Float32List.fromList(imagePixels);
  }

  Future<String> _getLocationInfo() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;

      String city = place.locality ?? "your city";
      String state = place.administrativeArea ?? "your state";
      String country = place.country ?? "your country";

      return "$city, $state, $country";
    } else {
      return "your location";
    }
  } catch (e) {
    print("Error fetching location: $e");
    return "your location";
  }
}

  Future<String> classifyImage(File image) async {
    try {
      var input = preprocessImage(image);
      var reshapedInput = input.reshape([1, 150, 150, 3]);
      var output = List.filled(1, 0.0).reshape([1, 1]);
      interpreter.run(reshapedInput, output);
      double prediction = output[0][0];


String result;
String geminiQuery;

if (prediction > 0.7) {
      result = "Recyclable";
      String country = await _getLocationInfo();
      geminiQuery = "What are the recycling guidelines in $country?";
    } else if (prediction < 0.3) {
      result = "Organic Waste";
      geminiQuery = "What to do with organic waste?";
    } else {
      result = "General Waste";
      geminiQuery = "What to do with general waste?";
    }


onClassification(result);
await _askGemini(geminiQuery);

return result;

    } catch (e) {
      print("Error classifying image: $e");
      return "Error in classification";
    }
  }

  Future<void> _askGemini(String query) async {
    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: geminiApiKey);
      final content = [Content.text(query)];
      
      final response = await model.generateContent(content);
      
      String answer = response.text ?? "No response from Gemini.";

      onGeminiResponse(answer);
    } catch (e) {
      onGeminiResponse("Error while getting response from Gemini: $e");
    }
  }
}

# Smart Waste Management App
Improper trash disposal is a major global issue, causing environmental damage, economic pressure, and health dangers. Many people struggle to properly sort waste due to a lack of available guidance and information. This project addresses the issue by creating a machine learning-powered waste classification system that divides waste into three categories: recyclable, organic, and general.

The system's goal is to enable users make more informed disposal decisions by providing accurate, real-time classification. To improve engagement and usability, the app also incorporates geolocation-based recycling rules and an integrated conversational AI assistant that provides individualized guidance depending on the user's location and questions.

The classification model was trained using a publicly available Kaggle dataset that included a variety of trash item photos. To increase resilience, data augmentation techniques like rescaling, rotation, zooming, and flipping were used with Keras' ImageDataGenerator. A transfer learning strategy was used with the VGG16 architecture as the foundation model. The Bayesian Optimization feature of Keras Tuner was used to fine-tune hyperparameters such as thick layers, dropout rates, and learning rate. The resulting model had a validation accuracy of 93.99% and was optimized for mobile use by converting to TensorFlow Lite.

The Flutter-based smartphone app offers customers local recycling regulations and a conversational AI assistant powered by Google's Gemini API. The assistant provides users with targeted, context-aware solutions to help them manage waste more successfully.
This project combines machine learning, location-based customization, and conversational AI to deliver a practical tool that encourages environmentally responsible behavior and supports global sustainability goals.

## Features
- Image classification using a pre-trained TensorFlow Lite model (VGG16).
- AI assistant screen for user queries.
- User authentication (registration and login).
- Waste statistics display.

## Dependencies and Provenance
Dataset for training the model from kaggle:
https://www.kaggle.com/code/beyzanks/waste-classification-with-cnn/input

This project uses the following major libraries and tools:
- Flutter SDK: Mobile UI framework.
- TensorFlow Lite: For on-device machine learning.
- Dart packages(declared in `pubspec.yaml`), including:
  - `flutter`
  - `image_picker` (for selecting images)
  - `path_provider`, `provider`, and others

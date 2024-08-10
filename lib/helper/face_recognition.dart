import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class FaceRecognition {
  final FaceDetector _faceDetector;

  FaceRecognition()
      : _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );

  // Convert a list of face embeddings to JSON string
  String convertEmbeddingsToJson(List<double> embeddings) {
    return jsonEncode(embeddings);
  }

  // Convert a JSON string to a list of face embeddings
  List<double> convertJsonToEmbeddings(String jsonString) {
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => item as double).toList();
  }

  // Pick an image from the specified source
  Future<XFile?> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: source);
  }

  // Extract face embeddings from an image
  Future<List<double>> extractFaceEmbeddings(File imageFile) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image image = img.decodeImage(imageBytes)!;
    final double imageWidth = image.width.toDouble();
    final double imageHeight = image.height.toDouble();

    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> faces = await _faceDetector.processImage(inputImage);

    print('Detected ${faces.length} faces in the image.');

    if (faces.isNotEmpty) {
      final face = faces.first;

      final List<double> embeddings = [];

      final landmarksToExtract = [
        FaceLandmarkType.leftEye,
        FaceLandmarkType.rightEye,
        FaceLandmarkType.noseBase,
        FaceLandmarkType.leftEar,
        FaceLandmarkType.rightEar,
      ];

      for (var landmarkType in landmarksToExtract) {
        final landmark = face.landmarks[landmarkType];
        if (landmark != null) {
          // Normalize coordinates
          double normalizedX = landmark.position.x / imageWidth;
          double normalizedY = landmark.position.y / imageHeight;
          embeddings.add(normalizedX);
          embeddings.add(normalizedY);
          print('$landmarkType detected at (${landmark.position.x}, ${landmark.position.y})');
        } else {
          print('Landmark $landmarkType not detected.');
        }
      }

      if (embeddings.length < 10) {
        throw 'Not enough landmarks detected to generate embeddings. Found ${embeddings.length} landmarks.';
      }

      // Ensure embeddings have consistent length
      while (embeddings.length < 10) {
        embeddings.add(0.0);
      }

      print('Extracted embeddings: $embeddings');
      return embeddings;
    } else {
      throw 'No faces detected in the image.';
    }
  }

  // Verify if the captured face matches the stored face embedding
  Future<bool> verifyFace(File imageFile, List<double> storedFaceEmbedding) async {
    try {
      final List<double> capturedFaceEmbedding = await extractFaceEmbeddings(imageFile);
      print('Captured Face Embeddings: $capturedFaceEmbedding');
      print('Stored Face Embeddings: $storedFaceEmbedding');
      bool result = _compareEmbeddings(storedFaceEmbedding, capturedFaceEmbedding);
      print('Face verification result: $result');
      return result;
    } catch (e) {
      print('Face verification failed: $e');
      return false;
    }
  }

  // Compare two face embeddings
  bool _compareEmbeddings(List<double> embedding1, List<double> embedding2, {double threshold = 0.279}) {
    if (embedding1.length != embedding2.length) {
      print('Embedding lengths do not match. Length1: ${embedding1.length}, Length2: ${embedding2.length}');
      return false;
    }

    double distance = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      distance += (embedding1[i] - embedding2[i]) * (embedding1[i] - embedding2[i]);
    }
    distance = sqrt(distance);

    print('Distance between embeddings: $distance');

    // Adjusted threshold for comparison
    return distance < threshold;
  }

  // Close the face detector
  Future<void> close() async {
    await _faceDetector.close();
  }
}

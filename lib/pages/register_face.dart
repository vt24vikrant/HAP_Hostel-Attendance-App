import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hbap/pages/register_fingerprint.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../helper/face_recognition.dart';

class RegisterFace extends StatefulWidget {
  final String userId;

  const RegisterFace({Key? key, required this.userId}) : super(key: key);

  @override
  _RegisterFaceState createState() => _RegisterFaceState();
}

class _RegisterFaceState extends State<RegisterFace> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _faceDetected = false;
  bool _isLoading = false;

  // Create an instance of FaceRecognition
  final FaceRecognition faceRecognition = FaceRecognition();

  @override
  void dispose() {
    faceRecognition.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Face'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile == null
                ? Text('No image selected.')
                : Image.file(File(_imageFile!.path)),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Text(
              _faceDetected ? 'Face detected successfully!' : 'No face detected.',
              style: TextStyle(
                color: _faceDetected ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveFaceData,
              child: Text('Save Face Data'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _faceDetected = false;
        });

        print('Picked Image Path: ${pickedFile.path}');
        await _detectFace();
      } else {
        print('No image selected.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No image selected.')));
      }
    } catch (e) {
      print('Failed to pick image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _detectFace() async {
    if (_imageFile == null) return;

    final File imageFile = File(_imageFile!.path);

    try {
      // Extract face embeddings
      final List<double> embeddings = await faceRecognition.extractFaceEmbeddings(imageFile);

      // Convert embeddings to JSON
      final String faceDataJson = faceRecognition.convertEmbeddingsToJson(embeddings);
      print('Face Embedding JSON: $faceDataJson');

      // Update the Firestore document with the face embedding data
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'faceEmbedding': faceDataJson, // Save as a JSON string
      });

      setState(() {
        _faceDetected = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Face detected and saved successfully.')));
    } catch (e) {
      print('Face detection failed: $e');
      setState(() {
        _faceDetected = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Face detection failed: $e')));
    }
  }

  Future<void> _saveFaceData() async {
    if (_faceDetected && _imageFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Face data saved successfully.')),
      );

      // Navigate to RegisterFingerprint after saving face data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterFingerprint(userId: widget.userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No face detected. Please try again.')),
      );
    }
  }
}

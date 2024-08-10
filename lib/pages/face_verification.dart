import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/face_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FaceVerificationPage extends StatefulWidget {
  final String userId;

  const FaceVerificationPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FaceVerificationPageState createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  final FaceRecognition faceRecognition = FaceRecognition();
  XFile? _capturedImage;
  bool _isFaceMatched = false;
  bool _isLoading = false;
  List<double>? _storedFaceEmbedding;

  @override
  void initState() {
    super.initState();
    _fetchStoredFaceEmbedding();
  }

  Future<void> _fetchStoredFaceEmbedding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        String faceDataJson = userDoc['faceEmbedding'] ?? '';
        _storedFaceEmbedding = faceRecognition.convertJsonToEmbeddings(faceDataJson);

        setState(() {
          _storedFaceEmbedding = _storedFaceEmbedding;
        });
      } else {
        throw 'User not found in the database';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching face embedding: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile? capturedImage = await faceRecognition.pickImage(ImageSource.camera);
    if (capturedImage != null) {
      setState(() {
        _capturedImage = capturedImage;
        _isFaceMatched = false;
      });

      try {
        File imageFile = File(capturedImage.path);

        if (_storedFaceEmbedding != null) {
          // Verify the captured face
          bool isFaceMatched = await faceRecognition.verifyFace(imageFile, _storedFaceEmbedding!);

          setState(() {
            _isFaceMatched = isFaceMatched;
          });

          if (_isFaceMatched) {
            Navigator.pop(context, true); // Return true if face is verified
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Face not matched.')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No stored face embedding found.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error verifying face: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Verification'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _capturedImage == null
                ? Text('No image captured.')
                : Image.file(File(_capturedImage!.path)),
            SizedBox(height: 20),
            _isFaceMatched
                ? Text('Face matched successfully!', style: TextStyle(color: Colors.green))
                : Text('Face not matched.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _captureImage,
              child: Text('Capture Face for Verification'),
            ),
          ],
        ),
      ),
    );
  }
}


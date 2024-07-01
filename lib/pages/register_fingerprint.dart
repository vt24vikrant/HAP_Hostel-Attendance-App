import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hbap/pages/login_page.dart';
import '../components/my_button.dart';
import '../helper/helper_functions.dart';

class RegisterFingerprint extends StatefulWidget {
  final String userId;

  const RegisterFingerprint({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _RegisterFingerprintState createState() => _RegisterFingerprintState();
}

class _RegisterFingerprintState extends State<RegisterFingerprint> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _authorized = 'Not Authorized';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      displayMessageToUser("Device does not support biometric authentication", context);
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });

      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to register',
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
          biometricOnly: true,
        ),
      );

      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      });

      if (authenticated) {
        // Save fingerprint status in Firestore
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'fingerprintRegistered': true,
        });

        // Navigate to the LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(onTap: () {}),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - $e';
      });
      displayMessageToUser("Error during fingerprint registration", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 37, 157, 243),
                  Color.fromARGB(255, 7, 217, 217),
                ],
              ),
            ),
          ),
          // Centered content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and app name
                  Icon(
                    Icons.fingerprint,
                    size: 60,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "REGISTER FINGERPRINT",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  // Fingerprint status text
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      _authorized,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Register button
                  MyButton(
                    text: _isAuthenticating ? "Authenticating..." : "Register Fingerprint",
                    onTap: _isAuthenticating ? null : _authenticate,
                  ),
                ],
              ),
            ),
          ),
          // Decorative shapes
          Positioned(
            top: 20,
            left: 50,
            child: Container(
              width: 150,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 240,
            child: Container(
              width: 40,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 180,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

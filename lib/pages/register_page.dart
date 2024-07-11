import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hbap/components/my_button.dart';
import 'package:hbap/components/my_textfield.dart';
import 'package:hbap/pages/login_page.dart';
import 'package:hbap/pages/register_fingerprint.dart';
import '../helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPwController = TextEditingController();
  TextEditingController roomNumberController = TextEditingController();
  String selectedRole = 'Student';

  late String deviceId;

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
  }

  Future<void> _initDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // Use 'id' for the Android device ID
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor!; // Unique ID for iOS devices
    } else {
      deviceId = ''; // Default or handle unsupported platforms
    }
  }

  Future<void> registerUser() async {
    // Show a circular progress bar
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Check if the passwords match
    if (passwordController.text != confirmPwController.text) {
      Navigator.pop(context);
      displayMessageToUser("Passwords don't match!", context);
      return; // Exit the function if passwords don't match
    }

    try {
      // Check if the device ID is already registered without authentication
      QuerySnapshot existingDevice = await FirebaseFirestore.instance
          .collection('users')
          .where('deviceId', isEqualTo: deviceId)
          .get();

      if (existingDevice.docs.isNotEmpty) {
        Navigator.pop(context);
        displayMessageToUser("Device is already registered!", context);
        return; // Exit the function if the device is already registered
      }

      // Create the user
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Save the user information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'username': usernameController.text,
        'email': emailController.text,
        'role': selectedRole,
        'deviceId': deviceId, // Save the device ID
        'fingerprintRegistered': false, // Initialize fingerprint registration status
        'roomNumber': roomNumberController.text, // Save the room number
      });

      Navigator.pop(context); // Close the progress bar

      // Navigate to RegisterFingerprint if the role is Student
      if (selectedRole == 'Student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterFingerprint(userId: credential.user!.uid),
          ),
        );
      } else {
        // Navigate to the LoginPage for Supervisors
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(onTap: () {}),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the progress bar
      displayMessageToUser(e.code, context);
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      Navigator.pop(context); // Close the progress bar in case of any other exceptions
      print(e);
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
                    Icons.person,
                    size: 60,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "R E G I S T E R",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  // Username text field
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: MyTextField(
                      labelText: "Username",
                      hintText: "Username",
                      obscureText: false,
                      controller: usernameController,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Email text field
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: MyTextField(
                      labelText: "Email",
                      hintText: "Email",
                      obscureText: false,
                      controller: emailController,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Password text field
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: MyTextField(
                      labelText: "Password",
                      hintText: "Password",
                      obscureText: true,
                      controller: passwordController,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Confirm Password text field
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: MyTextField(
                      labelText: "Confirm Password",
                      hintText: "Confirm Password",
                      obscureText: true,
                      controller: confirmPwController,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Room Number text field
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: MyTextField(
                      labelText: "Room Number",
                      hintText: "Room Number",
                      obscureText: false,
                      controller: roomNumberController,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Role selection
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DropdownButton<String>(
                      value: selectedRole,
                      items: <String>['Student', 'Supervisor']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRole = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Register button
                  MyButton(text: "Register", onTap: registerUser),
                  const SizedBox(height: 20),
                  // Login redirection
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            " Login now",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

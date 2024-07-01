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

  void registerUser() async {
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

    // Try creating the user
    try {
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
                          "Already Have an Account? ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login Here!",
                            style: TextStyle(
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

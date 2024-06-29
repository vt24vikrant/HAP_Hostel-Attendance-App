import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hbap/components/my_button.dart';
import 'package:hbap/components/my_textfield.dart';
import 'package:hbap/helper/helper_functions.dart';
import 'package:hbap/pages/register_page.dart';
import 'package:hbap/pages/supervisor_home_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Retrieve the user document from Firestore based on the user ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      String role = userDoc['role'];

      if (context.mounted) {
        Navigator.pop(context);

        // Navigate to the appropriate home page based on role
        if (role == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentHomePage()),
          );
        } else if (role == 'Supervisor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SupervisorHomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.message ?? 'An error occurred', context);
    } catch (e) {
      Navigator.pop(context);
      displayMessageToUser('An error occurred. Please try again.', context);
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
                    "L O G I N",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
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
                  // Login button
                  MyButton(text: "Login", onTap: login),
                  const SizedBox(height: 20),
                  // Register redirection
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't Have an Account? ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage(onTap: () {})), // Ensure this path is correct
                            );
                          },
                          child: const Text(
                            "Register Here!",
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
            top: 100,
            left: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: 40,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 80,
            child: Container(
              width: 90,
              height: 90,
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

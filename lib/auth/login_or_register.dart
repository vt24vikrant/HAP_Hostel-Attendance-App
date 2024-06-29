import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hbap/pages/login_page.dart';
import 'package:hbap/pages/register_page.dart';
import 'package:hbap/pages/supervisor_home_page.dart';

import '../pages/home_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({Key? key}) : super(key: key);

  @override
  _LoginOrRegisterState createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  bool showLoginPage=true;


  void togglePages()
  {
    setState(() {
      showLoginPage=!showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage)
      {
        return LoginPage(onTap: togglePages);
      }else{
      return RegisterPage(onTap: togglePages);
    }
  }
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  //
  // Future<void> _login() async {
  //   try {
  //     final String email = _emailController.text;
  //     final String password = _passwordController.text;
  //
  //     // Authenticate with Firebase Auth
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //
  //     // Check user role from Firestore
  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(email)
  //         .get();
  //
  //     if (!userDoc.exists) {
  //       throw FirebaseAuthException(
  //         code: 'user-not-found',
  //         message: 'User not found in Firestore',
  //       );
  //     }
  //
  //     final String role = userDoc.get('role');
  //
  //     // Navigate to the respective home page based on the role
  //     if (role == 'student') {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const StudentHomePage()),
  //       );
  //     } else if (role == 'supervisor') {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const SupervisorHomePage()),
  //       );
  //     } else {
  //       throw FirebaseAuthException(
  //         code: 'unknown-role',
  //         message: 'User role is not defined',
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}')),
  //     );
  //   }
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _login,
//               child: const Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

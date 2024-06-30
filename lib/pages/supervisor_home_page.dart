import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hbap/auth/login_or_register.dart';
import 'package:hbap/pages/regStudent.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import '../components/my_drawer.dart';

class SupervisorHomePage extends StatefulWidget {
  const SupervisorHomePage({super.key});

  @override
  _SupervisorHomePageState createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage> with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
      );
    }
  }

  Future<void> authenticate() async {
    bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to proceed',
      options: const AuthenticationOptions(
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );

    if (didAuthenticate) {
      // Add logic if needed for successful authentication
    }
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('yMMMd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Supervisor Home"),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterStudentPage()),  // Navigate to the register student page
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).secondaryHeaderColor, Theme.of(context).primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "DATE: $todayDate",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // AnimatedPositioned widgets for the background animations
          AnimatedPositioned(
            duration: const Duration(seconds: 5),
            top: 100 + (10 * _controller.value),
            left: 20 + (20 * _controller.value),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 5),
            top: 600 + (20 * _controller.value),
            left: 150 + (15 * _controller.value),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 5),
            top: 100 + (20 * _controller.value),
            left: 250 + (15 * _controller.value),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 5),
            top: 400 + (30 * _controller.value),
            left: 150 + (10 * _controller.value),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 5),
            bottom: 600 + (10 * _controller.value),
            right: 250 + (20 * _controller.value),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 5),
            bottom: 400 + (25 * _controller.value),
            left: 500 + (30 * _controller.value),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

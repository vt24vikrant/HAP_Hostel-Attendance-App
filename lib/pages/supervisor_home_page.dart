import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_or_register.dart';

class SupervisorHomePage extends StatelessWidget {
  const SupervisorHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginOrRegister()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${user?.email}'),
      ),
    );
  }
}

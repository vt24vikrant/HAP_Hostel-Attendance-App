import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hbap/auth/login_or_register.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/my_drawer.dart';
import '../helper/markAttendance.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> with SingleTickerProviderStateMixin {
  bool _attendanceMarked = false;
  final LocalAuthentication auth = LocalAuthentication();
  late AnimationController _controller;
  String? _attendanceStatus;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _fetchAttendanceStatus();
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

  Future<void> _fetchAttendanceStatus() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String todayDate = DateFormat('y-MM-dd').format(DateTime.now());

      DocumentSnapshot attendanceSnapshot = await FirebaseFirestore.instance.collection('attendance').doc(userId).get();

      if (attendanceSnapshot.exists) {
        Map<String, dynamic> attendanceData = attendanceSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _attendanceStatus = attendanceData[todayDate] ?? 'Absent';
          _attendanceMarked = _attendanceStatus == 'Present';
        });
      } else {
        setState(() {
          _attendanceStatus = 'Absent';
          _attendanceMarked = false;
        });
      }
    } catch (e) {
      setState(() {
        _attendanceStatus = 'Error fetching attendance';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('yMMMd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Home"),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      drawer: MyDrawer(role: 'Student'),
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _attendanceMarked ? null : () async {
                      await markAttendance(context, auth);
                      _fetchAttendanceStatus();
                    },
                    icon: const Icon(Icons.fingerprint_rounded, size: 28),
                    label: const Text('Mark Attendance', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _attendanceStatus ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 18,
                      color: _attendanceMarked ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hbap/auth/login_or_register.dart';
import 'package:hbap/pages/regStudent.dart';
import '../components/my_drawer.dart';
import 'attendance_monitor.dart';


class SupervisorHomePage extends StatefulWidget {
  const SupervisorHomePage({super.key});

  @override
  _SupervisorHomePageState createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage> with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  late AnimationController _controller;

  final _formKey = GlobalKey<FormState>();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final String _ssid = 'AndroidWifi';
  final String _bssid = '00:13:10:85:fe:01';
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

  Future<void> setAttendanceAndWifiData() async {
    if (_formKey.currentState!.validate() && _startTime != null && _endTime != null) {
      try {
        await FirebaseFirestore.instance.collection('settings').doc('attendance').set({
          'startTime': DateFormat('HH:mm').format(DateTime(0, 1, 1, _startTime!.hour, _startTime!.minute)),
          'endTime': DateFormat('HH:mm').format(DateTime(0, 1, 1, _endTime!.hour, _endTime!.minute)),
          'ssid': _ssid,
          'bssid': _bssid,
          'geofenceCenter': GeoPoint(26.25, 78.1697),
          'geofenceRadius': "60.0",
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance time slot set successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set data: $e')),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime ?? TimeOfDay.now() : _endTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != (isStartTime ? _startTime : _endTime)) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _showWifiDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WiFi Details'),
          content: Text('SSID: $_ssid\nBSSID: $_bssid'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          IconButton(
            icon: const Icon(Icons.monitor),  // New icon button for attendance monitor
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AttendanceMonitorPage()),  // Navigate to the Attendance Monitor page
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(role: 'Supervisor'),
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
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _selectTime(context, true),
                              child: Text(_startTime == null ? 'Select Start Time' : 'Start Time: ${_startTime!.format(context)}'),
                            ),
                            ElevatedButton(
                              onPressed: () => _selectTime(context, false),
                              child: Text(_endTime == null ? 'Select End Time' : 'End Time: ${_endTime!.format(context)}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: setAttendanceAndWifiData,
                          child: const Text('Set Attendance Time'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _showWifiDetails,
                          child: const Text('Show WiFi Details'),
                        ),
                      ],
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

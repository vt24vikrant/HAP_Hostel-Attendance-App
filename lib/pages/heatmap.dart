import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

class AttendanceHeatmap extends StatefulWidget {
  @override
  _AttendanceHeatmapState createState() => _AttendanceHeatmapState();
}

class _AttendanceHeatmapState extends State<AttendanceHeatmap> {
  Map<DateTime, int> attendanceData = {};

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle unauthenticated user
      return;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: user.uid)
        .get();

    Map<DateTime, int> data = {};
    for (var doc in snapshot.docs) {
      Map<String, dynamic> attendanceMap = doc.data() as Map<String, dynamic>;
      attendanceMap.forEach((key, value) {
        if (key != 'userId' && key != 'deviceId' && key != 'lastUpdated') {
          DateTime date = DateFormat('yyyy-MM-dd').parse(key);
          int status = _getStatus(value);
          data[date] = status;
        }
      });
    }

    setState(() {
      attendanceData = data;
    });
  }

  int _getStatus(String status) {
    switch (status) {
      case 'Present':
        return 1;
      case 'Absent':
        return 2;
      case 'On Leave':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Attendance'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: HeatMap(
              datasets: attendanceData,
              colorMode: ColorMode.color,
              showColorTip: false,
              scrollable: true,
              colorsets: {
                1: Colors.green,   // Present
                2: Colors.red,     // Absent
                3: Colors.yellow,  // On Leave
              },
              onClick: (date) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(DateFormat.yMMMd().format(date))),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

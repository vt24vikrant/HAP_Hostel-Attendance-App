import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendanceMonitorPage extends StatefulWidget {
  @override
  _AttendanceMonitorPageState createState() => _AttendanceMonitorPageState();
}

class _AttendanceMonitorPageState extends State<AttendanceMonitorPage> {
  Map<String, Map<String, dynamic>> attendanceData = {};
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    checkSupervisorRole();
  }

  Future<void> checkSupervisorRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle unauthenticated user
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access denied: Unauthenticated.')),
      );
      return;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists && userDoc['role'] == 'Supervisor') {
      fetchAttendanceData();
    } else {
      // Show an error message or navigate to a different page
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access denied: Supervisors only.')),
      );
    }
  }

  Future<void> fetchAttendanceData() async {
    QuerySnapshot attendanceSnapshot =
    await FirebaseFirestore.instance.collection('attendance').get();

    Map<String, Map<String, dynamic>> data = {};
    for (var doc in attendanceSnapshot.docs) {
      String userId = doc.id;
      Map<String, dynamic> attendanceMap = doc.data() as Map<String, dynamic>;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String username = userDoc['username'];
        String roomNumber = userDoc['roomNumber'];

        Map<DateTime, int> roomData = {};
        attendanceMap.forEach((key, value) {
          if (key != 'deviceId' && key != 'lastUpdated') {
            DateTime date = DateFormat('yyyy-MM-dd').parse(key);
            int status = _getStatus(value);
            roomData[date] = status;
          }
        });

        data[roomNumber] = {
          'username': username,
          'attendance': roomData,
        };
      }
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

  void _changeDate(bool isPrevious) {
    setState(() {
      selectedDate = isPrevious
          ? selectedDate.subtract(Duration(days: 1))
          : selectedDate.add(Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter data based on selectedDate
    Map<String, Map<String, dynamic>> filteredData = {};
    attendanceData.forEach((roomNumber, userData) {
      final attendanceMap = userData['attendance'] as Map<DateTime, int>;
      // Add default 'Absent' if no attendance data for the selected date
      int status = attendanceMap.containsKey(selectedDate)
          ? attendanceMap[selectedDate]!
          : 4; // Default to Absent
      filteredData[roomNumber] = {
        'username': userData['username'],
        'attendance': {selectedDate: status},
      };
    });

    // Sort by room number
    var sortedFilteredData = Map.fromEntries(
      filteredData.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Monitor'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: () => _changeDate(true),
                ),
                Text(
                  DateFormat.yMMMd().format(selectedDate),
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: () => _changeDate(false),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: sortedFilteredData.keys.length,
              itemBuilder: (context, index) {
                String roomNumber = sortedFilteredData.keys.elementAt(index);
                Map<String, dynamic> userData = sortedFilteredData[roomNumber]!;
                String username = userData['username'];
                int status = userData['attendance'][selectedDate]!;

                Color statusColor;
                String statusText;
                switch (status) {
                  case 1:
                    statusColor = Colors.green;
                    statusText = 'Present';
                    break;
                  case 2:
                    statusColor = Colors.red;
                    statusText = 'Absent';
                    break;
                  case 3:
                    statusColor = Colors.yellow;
                    statusText = 'On Leave';
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusText = 'Unknown';
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room $roomNumber',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Username: $username'),
                        Spacer(),
                        Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

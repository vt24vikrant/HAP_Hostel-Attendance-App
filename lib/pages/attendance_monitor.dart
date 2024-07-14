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
      print('Fetched Attendance Data: $attendanceData'); // Debug print
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
      print('Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'); // Debug print
    });
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    // Filter data based on selectedDate
    Map<String, Map<String, dynamic>> filteredData = {};
    attendanceData.forEach((roomNumber, userData) {
      final attendanceMap = userData['attendance'] as Map<DateTime, int>;
      print('Room $roomNumber Attendance Map: $attendanceMap'); // Debug print for each room
      int status = 2; // Default to Absent if no data for the selected date
      attendanceMap.forEach((date, value) {
        if (_isSameDate(date, selectedDate)) {
          status = value;
        }
      });
      filteredData[roomNumber] = {
        'username': userData['username'],
        'status': status,
      };
    });

    // Sort by room number
    var sortedFilteredData = Map.fromEntries(
      filteredData.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    print('Filtered Data: $sortedFilteredData'); // Debug print

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
                crossAxisCount: 2, // Number of columns in the grid
                childAspectRatio: 1, // Aspect ratio of the cards to make them square
                mainAxisSpacing: 10, // Space between rows
                crossAxisSpacing: 10, // Space between columns
              ),
              itemCount: sortedFilteredData.keys.length,
              itemBuilder: (context, index) {
                String roomNumber = sortedFilteredData.keys.elementAt(index);
                Map<String, dynamic> userData = sortedFilteredData[roomNumber]!;
                String username = userData['username'];
                int status = userData['status'];

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                  color: Colors.white,
                  elevation: 4.0, // Shadow effect
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Room $roomNumber',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text('Username: $username'),
                        SizedBox(height: 8.0),
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

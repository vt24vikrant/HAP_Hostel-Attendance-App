import 'package:flutter/material.dart';
import '../pages/heatmap.dart';

class MyDrawer extends StatelessWidget {
  final String role; // Add a parameter for the user's role

  const MyDrawer({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          DrawerHeader(
            child: Icon(
              Icons.apartment_outlined,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 35,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.home),
              title: Text(
                "H O M E",
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              ),
              onTap: () {
              },
            ),
          ),
          SizedBox(height: 50.0),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(
                "P R O F I L E",
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              ),
              onTap: () {
              },
            ),
          ),
          SizedBox(height: 50.0),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.map),
              title: Text(
                "H E A T M A P",
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              ),
              onTap: () {
                if (role == 'Student') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AttendanceHeatmap()),
                  );
                } else {
                  // Handle the case where the user is not a student
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

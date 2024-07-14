import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:geolocator/geolocator.dart';

Future<void> markAttendance(BuildContext context, LocalAuthentication auth) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Checking...'),
            CircularProgressIndicator(),
          ],
        ),
      );
    },
  );

  try {
    // Request location permissions
    var locationStatus = await Permission.location.request();
    if (!locationStatus.isGranted) {
      throw 'Location permission is required to fetch location information';
    }

    // Check connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.wifi) {
      throw 'Not connected to a WiFi network';
    }

    // Fetch settings from Firestore
    DocumentSnapshot settingsSnapshot = await FirebaseFirestore.instance.collection('settings').doc('attendance').get();
    if (!settingsSnapshot.exists) {
      throw 'Attendance settings not found in the database';
    }

    Map<String, dynamic> settings = settingsSnapshot.data() as Map<String, dynamic>;
    String ssid = settings['ssid'];
    String bssid = settings['bssid'];

    // Parse startTime and endTime
    TimeOfDay startTime = TimeOfDay(
      hour: int.parse(settings['startTime'].split(":")[0]),
      minute: int.parse(settings['startTime'].split(":")[1]),
    );
    TimeOfDay endTime = TimeOfDay(
      hour: int.parse(settings['endTime'].split(":")[0]),
      minute: int.parse(settings['endTime'].split(":")[1]),
    );

    TimeOfDay now = TimeOfDay.now();
    if (!(now.hour > startTime.hour || (now.hour == startTime.hour && now.minute >= startTime.minute)) ||
        !(now.hour < endTime.hour || (now.hour == endTime.hour && now.minute <= endTime.minute))) {
      throw 'Current time is not within the attendance time slot';
    }

    bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to mark attendance',
      options: const AuthenticationOptions(
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );

    if (!didAuthenticate) {
      throw 'Fingerprint authentication failed';
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String currentDeviceId = androidInfo.id;

    WifiInfo wifiInfo = WifiInfo();
    String currentSsid = await wifiInfo.getWifiName() ?? '';
    String currentBssid = await wifiInfo.getWifiBSSID() ?? '';

    print('Current DeviceId: $currentDeviceId');
    print('Current SSID: $currentSsid');
    print('Current BSSID: $currentBssid');

    if (currentSsid != ssid || currentBssid != bssid) {
      throw 'Connected to incorrect WiFi network';
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw 'User not found in the database';
    }

    String registeredDeviceId = userDoc['deviceId'];
    print('Registered DeviceId: $registeredDeviceId');
    if (registeredDeviceId != currentDeviceId) {
      throw 'Device ID does not match the registered device';
    }

    // Geofencing
    GeoPoint geofenceCenter = settings['geofenceCenter'];
    double geofenceCenterLat = geofenceCenter.latitude.toDouble();
    double geofenceCenterLng = geofenceCenter.longitude.toDouble();
    double geofenceRadius = double.parse(settings['geofenceRadius']);  // Convert string to double

    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      geofenceCenterLat,
      geofenceCenterLng,
    );

    print('Distance: $distance');
    if (distance > geofenceRadius) {
      throw 'Outside the geofence area';
    }

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await FirebaseFirestore.instance.collection('attendance').doc(userId).set({
      todayDate: 'Present',
      'deviceId': currentDeviceId,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    Navigator.pop(context); // Close the checking dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Attendance marked successfully!')),
              Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        );
      },
    );

  } catch (e) {
    Navigator.pop(context); // Close the checking dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Error: $e')),
              Icon(Icons.error, color: Colors.red),
            ],
          ),
        );
      },
    );
  }
}

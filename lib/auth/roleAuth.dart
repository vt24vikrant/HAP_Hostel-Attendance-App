import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hbap/pages/supervisor_home_page.dart';
import '../pages/home_page.dart';
import 'login_or_register.dart';

class RoleHandler {
  static Future<Widget> getHomePage(User user) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      if (userData['role'] == 'student') {
        return const StudentHomePage();
      } else if (userData['role'] == 'supervisor') {
        return const SupervisorHomePage();
      }
    }
    return const LoginOrRegister();
  }
}

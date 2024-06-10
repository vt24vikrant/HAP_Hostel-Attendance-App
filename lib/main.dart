import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hbap/auth/auth.dart';
import 'package:hbap/auth/login_or_register.dart';
import 'package:hbap/pages/home_page.dart';
import 'package:hbap/theme/dark_mode.dart';
import 'package:hbap/theme/light_mode.dart';

import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginOrRegister(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hap/pages/login_page.dart';
import 'package:hap/theme/dark_mode.dart';
import 'package:hap/theme/light_mode.dart';
import 'pages/onboarding_screem.dart';
import 'package:hap/firebase_options.dart';


void main() async {
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
      home: LoginPage(),  
      theme: lightMode,
      darkTheme: darkMode,
      );
  }
}



import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:web_dashboard_app_tut/screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDr6cPvB8g24U2MxjU2l_OaOChBBNNe8yo",
          authDomain: "presensi-bb625.firebaseapp.com",
          projectId: "presensi-bb625",
          storageBucket: "presensi-bb625.appspot.com",
          messagingSenderId: "1006596669060",
          appId: "1:1006596669060:web:eb75faa1df0ca1aff40cd1",
          measurementId: "G-ZVEKEY9299"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
      // Login(),
    );
  }
}

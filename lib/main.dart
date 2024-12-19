import 'package:cache_employee_management/screens/administrator/administrator_home_screen.dart';
import 'package:cache_employee_management/screens/karyawan/karyawan_home_screen.dart';
import 'package:cache_employee_management/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              return LoginScreen();
            }
          }
        },
      ),
    );
  }

  Future<Widget?> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username == null || password == null) {
      return null;
    }

    if (username == 'Admin') {
      return AdministratorHome();
    } else {
      return KaryawanHome();
    }
  }
}

import 'package:cache_employee_management/screens/administrator/administrator_home_screen.dart';
import 'package:cache_employee_management/screens/karyawan/karyawan_home_screen.dart';
import 'package:cache_employee_management/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('es', 'US')
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        LocalJsonLocalization.delegate
      ],
      localeResolutionCallback: (locales, supportedLocales) {
        if (supportedLocales.contains(locales)) {
          return locales;
        }
        return const Locale('en', 'US');
      },
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Error: ${snapshot.error}")),
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
    
    print("Username: $username, Password: $password");

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

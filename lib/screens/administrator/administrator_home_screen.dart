import 'package:cache_employee_management/screens/administrator/feedback_administrator_screen.dart';
import 'package:cache_employee_management/screens/administrator/history_administrator_screen.dart';
import 'package:cache_employee_management/screens/administrator/manajemen_karyawan_screen.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cache_employee_management/screens/login_screen.dart';

class AdministratorHome extends StatefulWidget {
  @override
  State<AdministratorHome> createState() => _AdministratorHomeState();
}

class _AdministratorHomeState extends State<AdministratorHome> {
  // Logout function
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Logout confirmation
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('logout_confirm_title'.i18n()),
          content: Text('logout_confirm_message'.i18n()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.i18n()),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.of(context).pop();
              },
              child: Text('logout'.i18n()),
            ),
          ],
        );
      },
    );
  }

  // Change language function
  Future<void> _changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    setState(() {
      // Force rebuild to apply the language change
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'app_title'.i18n(),
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BFAE), Color(0xFF1DE9B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 167, 231, 167),
              Color.fromARGB(255, 107, 243, 209),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.teal[600]!, width: 1),
                  ),
                  shadowColor: const Color.fromARGB(255, 57, 61, 61)
                      .withOpacity(0.5),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                            Text(
                              'Admin',
                              style: TextStyle(
                                color: const Color.fromARGB(202, 96, 125, 139),
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildGridItem(Icons.today_rounded, 'rekap_absensi'.i18n(), () {}),
                  _buildGridItem(Icons.manage_accounts, 'manajemen_karyawan'.i18n(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManajemenKaryawan()),
                    );
                  }),
                  _buildGridItem(Icons.mail, 'izin'.i18n(), () {}),
                  _buildGridItem(Icons.feedback, 'inbox_feedback'.i18n(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FeedbackAdministrator()),
                    );
                  }),
                  _buildGridItem(Icons.history, 'history_absensi'.i18n(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryAdministrator()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
          side: BorderSide(color: Colors.teal[600]!, width: 1.2),
        ),
        shadowColor: const Color.fromARGB(255, 57, 61, 61).withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 65, color: Colors.teal[600]),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                    fontSize: 16, fontFamily: 'RobotoMono', color: Colors.teal),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

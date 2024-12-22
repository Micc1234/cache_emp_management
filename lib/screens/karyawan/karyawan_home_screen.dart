import 'dart:async';
import 'package:cache_employee_management/screens/karyawan/feedback_karyawan_screen.dart';
import 'package:cache_employee_management/screens/karyawan/history_karyawan_screen.dart';
import 'package:cache_employee_management/screens/karyawan/qr_scan_screen.dart';
import 'package:cache_employee_management/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KaryawanHome extends StatefulWidget {
  @override
  State<KaryawanHome> createState() => _KaryawanHomeState();
}

class _KaryawanHomeState extends State<KaryawanHome> {
  String _username = '';
  String _nama = '';
  bool _isLoading = true;

  String _currentTime = '';
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadUserData();
    _loadBannerAd();
  }

  void _startClock() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime =
            DateFormat('dd/MM/yyyy, HH:mm:ss').format(DateTime.now());
      });
    });
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      setState(() {
        _username = username;
      });

      try {
        QuerySnapshot snapshot = await _firestore
            .collection('karyawan')
            .where('username', isEqualTo: username)
            .get();

        var userDoc = snapshot.docs.first;

        setState(() {
          _nama = userDoc['nama'];
          _isLoading = false;
        });
      } catch (e) {
        print('Error fetching data: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Replace with your Ad Unit ID
      size: AdSize.fullBanner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.of(context).pop();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _checkIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          action: 'Check In',
          onSuccess: () async {
            try {
              await _firestore.collection('absensi').add({
                'username': _username,
                'nama': _nama,
                'jenis': 'Check In',
                'waktu': _currentTime,
              });
              _showDialog('Check In');
            } catch (e) {
              print('Error on Check In: $e');
            }
          },
        ),
      ),
    );
  }

  void _checkOut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          action: 'Check Out',
          onSuccess: () async {
            try {
              await _firestore.collection('absensi').add({
                'username': _username,
                'nama': _nama,
                'jenis': 'Check Out',
                'waktu': _currentTime,
              });
              _showDialog('Check Out');
            } catch (e) {
              print('Error on Check Out: $e');
            }
          },
        ),
      ),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$message berhasil'),
          content: Text('$message untuk $_nama berhasil.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Cache Employee Management',
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
    body: Column(
      children: [
        Expanded(
          child: Container(
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
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
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
                                        _nama,
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          fontFamily: 'RobotoMono',
                                        ),
                                      ),
                                      Text(
                                        _username,
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                              202, 96, 125, 139),
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
                      Text(
                        _currentTime,
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'RobotoMono',
                            color: const Color.fromARGB(255, 2, 86, 78),
                            fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildGridItem(Icons.login, 'Check In', _checkIn),
                            _buildGridItem(Icons.logout, 'Check Out', _checkOut),
                            _buildGridItem(Icons.airplane_ticket,
                                'Pengajuan Cuti/Izin', () {}),
                            _buildGridItem(Icons.feedback, 'Feedback', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeedbackKaryawan(
                                    username: _username,
                                    nama: _nama,
                                  ),
                                ),
                              );
                            }),
                            _buildGridItem(Icons.history, 'History', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryKaryawan(
                                    username: _username,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_isBannerAdLoaded && _bannerAd != null)
          Container(
            color: Colors.white,
            height: _bannerAd!.size.height.toDouble(),
            width: MediaQuery.of(context).size.width,
            child: AdWidget(ad: _bannerAd!),
          ),
      ],
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

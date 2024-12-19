import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryKaryawan extends StatelessWidget {
  final String username;

  HistoryKaryawan({required this.username});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History Absensi',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: StreamBuilder(
        stream: _firestore
            .collection('absensi')
            .where('username', isEqualTo: username)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Tidak ada riwayat absensi'));
          }

          final absensiList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: absensiList.length,
            itemBuilder: (context, index) {
              var doc = absensiList[index];
              return ListTile(
                leading: Icon(
                  doc['jenis'] == 'Check In' ? Icons.login : Icons.logout,
                  color: Colors.teal,
                ),
                title: Text(doc['jenis']),
                subtitle: Text(doc['waktu']),
              );
            },
          );
        },
      ),
    );
  }
}

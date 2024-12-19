import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbackKaryawan extends StatefulWidget {
  final String username;
  final String nama;

  FeedbackKaryawan({required this.username, required this.nama});

  @override
  State<FeedbackKaryawan> createState() => _FeedbackKaryawanState();
}

class _FeedbackKaryawanState extends State<FeedbackKaryawan> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _judulController = TextEditingController();
  TextEditingController _keluhanController = TextEditingController();

  void _sendFeedback() async {
    String judul = _judulController.text.trim();
    String keluhan = _keluhanController.text.trim();

    // Validasi panjang karakter
    if (judul.isEmpty || keluhan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Judul dan Keluhan tidak boleh kosong!')),
      );
      return;
    }

    try {
      String waktu = DateFormat('dd/MM/yyyy, HH:mm:ss').format(DateTime.now());

      await _firestore.collection('feedback').add({
        'username': widget.username,
        'nama': widget.nama,
        'judul': judul,
        'keluhan': keluhan,
        'waktu': waktu,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback berhasil dikirim!')),
      );

      _judulController.clear();
      _keluhanController.clear();
    } catch (e) {
      print('Error sending feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan, coba lagi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore
                    .collection('feedback')
                    .where('username', isEqualTo: widget.username)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('Tidak ada feedback yang ditemukan.'));
                  }

                  final feedbackList = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: feedbackList.length,
                    itemBuilder: (context, index) {
                      var feedback = feedbackList[index];
                      String judul = feedback['judul'];
                      String keluhan = feedback['keluhan'];
                      String waktu = feedback['waktu'];

                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            judul,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            keluhan,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          trailing: Text(waktu),
                          onTap: () {
                            _showFeedbackDetailDialog(judul, keluhan);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFeedbackFormDialog();
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Feedback',
      ),
    );
  }

  // Menampilkan dialog detail feedback saat card ditekan
  void _showFeedbackDetailDialog(String judul, String keluhan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(judul),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Keluhan:'),
              Text(keluhan),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan form untuk mengirim feedback baru
  void _showFeedbackFormDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Buat Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _judulController,
                decoration: InputDecoration(labelText: 'Judul'),
                maxLength: 30,
              ),
              TextField(
                controller: _keluhanController,
                decoration: InputDecoration(labelText: 'Keluhan'),
                maxLines: 5,
                maxLength: 150,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _sendFeedback();
                Navigator.of(context).pop();
              },
              child: Text('Kirim'),
            ),
          ],
        );
      },
    );
  }
}

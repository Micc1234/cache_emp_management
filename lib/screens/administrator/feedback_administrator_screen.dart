import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackAdministrator extends StatefulWidget {
  @override
  State<FeedbackAdministrator> createState() => _FeedbackAdministratorState();
}

class _FeedbackAdministratorState extends State<FeedbackAdministrator> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback Karyawan',
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
              'Feedback Dari Karyawan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('feedback').snapshots(),
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
                      String feedbackId = feedback.id;
                      String nama = feedback['nama'];
                      String judul = feedback['judul'];
                      String keluhan = feedback['keluhan'];
                      String waktu = feedback['waktu'];

                      String avatarInitial = nama.isNotEmpty ? nama[0] : '';

                      //delete from firestore
                      return Dismissible(
                        key: Key(feedbackId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          try {
                            await _firestore
                                .collection('feedback')
                                .doc(feedbackId)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Feedback dihapus!')),
                            );
                          } catch (e) {
                            print("Error deleting feedback: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Terjadi kesalahan!')),
                            );
                          }
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                avatarInitial,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              nama,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              '$judul\n${keluhan.length > 20 ? keluhan.substring(0, 20) + '...' : keluhan}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            trailing: Text(waktu),
                            onTap: () {
                              _showFeedbackDetailDialog(
                                  nama, judul, keluhan, waktu);
                            },
                          ),
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
    );
  }

  // Menampilkan dialog detail feedback ketika card ditekan
  void _showFeedbackDetailDialog(
      String nama, String judul, String keluhan, String waktu) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(judul),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nama Karyawan: $nama'),
              SizedBox(height: 10),
              Text('Keluhan:'),
              Text(keluhan),
              SizedBox(height: 10),
              Text('Waktu:'),
              Text(waktu),
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
}

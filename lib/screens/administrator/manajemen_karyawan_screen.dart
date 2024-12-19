import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManajemenKaryawan extends StatefulWidget {
  const ManajemenKaryawan({super.key});

  @override
  State<ManajemenKaryawan> createState() => _ManajemenKaryawanState();
}

class _ManajemenKaryawanState extends State<ManajemenKaryawan> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  // Add Karyawan
  Future<void> addKaryawan() async {
    TextEditingController usernameController = TextEditingController();
    TextEditingController namaController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Tambah Karyawan'),
              content: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                      ),
                      TextField(
                        controller: namaController,
                        decoration: InputDecoration(labelText: 'Nama'),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                      ),
                    ],
                  ),
                  if (isLoading)
                    Positioned(
                      top: 50,
                      left: 50,
                      right: 50,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    String username = usernameController.text;
                    String nama = namaController.text;
                    String password = passwordController.text;

                    if (username.isEmpty || nama.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Semua field harus diisi!'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2)),
                      );
                      return;
                    }

                    try {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        isLoading = true;
                      });

                      // Validasi username
                      QuerySnapshot snapshot = await _firestore
                          .collection('karyawan')
                          .where('username', isEqualTo: username)
                          .get();

                      if (snapshot.docs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Username sudah digunakan'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2)),
                        );
                      } else {
                        await _firestore.collection('karyawan').add({
                          'username': username,
                          'nama': nama,
                          'password': password,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Data Karyawan berhasil ditambahkan!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2)),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Terjadi kesalahan: $e'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2)),
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Edit Karyawan
  Future<void> editKaryawan(String id) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('karyawan').doc(id).get();
    TextEditingController usernameController =
        TextEditingController(text: snapshot['username']);
    TextEditingController namaController =
        TextEditingController(text: snapshot['nama']);
    TextEditingController passwordController =
        TextEditingController(text: snapshot['password']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Karyawan'),
              content: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                      ),
                      TextField(
                        controller: namaController,
                        decoration: InputDecoration(labelText: 'Nama'),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                      ),
                    ],
                  ),
                  if (isLoading)
                    Positioned(
                      top: 50,
                      left: 50,
                      right: 50,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    String username = usernameController.text;
                    String nama = namaController.text;
                    String password = passwordController.text;

                    if (username.isEmpty || nama.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Semua field harus diisi!'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2)),
                      );
                      return;
                    }

                    try {
                      setState(() {
                        isLoading = true;
                      });

                      await _firestore.collection('karyawan').doc(id).update({
                        'username': username,
                        'nama': nama,
                        'password': password,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Data Karyawan berhasil diperbarui!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2)),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Terjadi kesalahan: $e'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2)),
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Hapus Karyawan
  Future<void> deleteKaryawan(String id) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Hapus Karyawan'),
              content: Stack(
                children: [
                  Text('Apakah Anda yakin ingin menghapus karyawan ini?'),
                  if (isLoading)
                    Positioned(
                      top: 50,
                      left: 50,
                      right: 50,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        isLoading = true;
                      });

                      await _firestore.collection('karyawan').doc(id).delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Karyawan berhasil dihapus!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2)),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Terjadi kesalahan: $e'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2)),
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text('Hapus'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show detail Karyawan
  void showDetail(String username, String nama, String password) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detail Karyawan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Username: $username'),
              Text('Nama: $nama'),
              Text('Password: $password'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manajemen Karyawan',
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
      floatingActionButton: FloatingActionButton(
        onPressed: addKaryawan,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('karyawan').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            var data = snapshot.data!.docs;

            // Filter karyawan (mengecualikan admin)
            var karyawan =
                data.where((doc) => doc['username'] != 'Admin').toList();

            if (karyawan.isEmpty) {
              return Center(child: Text('Tidak ada data karyawan'));
            }

            return ListView.builder(
              itemCount: karyawan.length,
              itemBuilder: (context, index) {
                var doc = karyawan[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      doc['nama'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  title: Text(doc['nama']),
                  subtitle: Text(doc['username']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          editKaryawan(doc.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteKaryawan(doc.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    showDetail(doc['username'], doc['nama'], doc['password']);
                  },
                );
              },
            );
          }

          return Center(child: Text('Gagal memuat data'));
        },
      ),
    );
  }
}

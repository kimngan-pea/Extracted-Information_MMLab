import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:extracted_information/Models/user.dart'; // Ensure you import your user model

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> selectedExtracts = [];
  bool isAllChecked = false;
  String? uid; // Change to String? to allow null values

  @override
  void initState() {
    super.initState();
    takeFile();
  }

  @override
  Widget build(BuildContext context) {
    // Access the uid from the provider in the build method
    final user = Provider.of<Users?>(context); // Use listen: true if you want to update on user changes
    uid = user?.uid; // Safely assign uid

    return Scaffold(
      backgroundColor: const Color(0xFFB3D3CD),
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text("History"),
      ),
      body: uid == null ? _buildLoadingOrError() : _buildHistoryStream(uid!),
    );
  }

  Widget _buildLoadingOrError() {
    return const Center(child: Text('User not logged in or loading...'));
  }

  Widget _buildHistoryStream(String uid) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('history')
          .doc(uid)
          .collection('extract')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No history found'),
          );
        }

        var document = snapshot.data!.docs;
        return Center(
          child: Column(
            children: [
              Row(children: [
                // Check All button
                ElevatedButton.icon(
                  icon: Icon(isAllChecked
                      ? Icons.check_box
                      : Icons.check_box_outline_blank),
                  onPressed: () {
                    setState(() {
                      isAllChecked = !isAllChecked;
                      selectedExtracts = isAllChecked
                          ? document.map((doc) => doc.id).toList()
                          : [];
                    });
                  },
                  label: const Text('Check All'),
                ),
                // Delete checked items
                ElevatedButton(
                  onPressed: () async {
                    for (var extractId in selectedExtracts) {
                      await FirebaseFirestore.instance
                          .collection('history')
                          .doc(uid)
                          .collection('extract')
                          .doc(extractId)
                          .delete();
                    }
                    setState(() {
                      selectedExtracts.clear();
                    });
                  },
                  child: const Text('Delete Checked Items',
                      style: TextStyle(color: Colors.red)),
                ),
              ]),
              // Display
              Expanded(
                child: ListView.builder(
                  itemCount: document.length,
                  itemBuilder: (context, index) {
                    var extract = document[index];
                    return ListTile(
                      leading: Image.network(extract['OCR picture']),
                      title: Text('Result: ${extract['OCR json']}'),
                      subtitle: Text('Time: ${extract['time']}'),
                      trailing: Checkbox(
                        value: selectedExtracts.contains(extract.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedExtracts.add(extract.id);
                            } else {
                              selectedExtracts.remove(extract.id);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> takeFile() async {
    if (uid == null) {
      print('Error: User ID (uid) is null or empty');
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageFile = File('${directory.path}/processed_image.jpeg');
      final jsonFile = File('${directory.path}/results.json');
      if (imageFile.existsSync() && jsonFile.existsSync()) {
        await saveTryExtract(imageFile, jsonFile);
      } else {
        print('Files not found');
      }
    } catch (e) {
      print("Error uploading files: $e");
    }
  }

  Future<void> saveTryExtract(File imageFile, File jsonFile) async {
    if (uid == null || uid!.isEmpty) {
      print('Error: User ID (uid) is null or empty');
      return;
    }
    String image = await uploadImage(imageFile);
    String result = await uploadJsonFile(jsonFile);
    String uploadTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await FirebaseFirestore.instance
        .collection('history')
        .doc(uid)
        .collection('extract')
        .add({
      'time': uploadTime,
      'OCR picture': image,
      'OCR json': result,
    });
  }

  Future<String> uploadImage(File imageFile) async {
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('/Image/$uid/${DateTime.now().toString()}.jpg');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    var taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> uploadJsonFile(File jsonFile) async {
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('/JsonFile/$uid/${DateTime.now().toString()}.json');
    UploadTask uploadTask = storageRef.putFile(jsonFile);
    var taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }
}

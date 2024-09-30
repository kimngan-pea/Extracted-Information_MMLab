import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class KeyPage extends StatelessWidget {
  const KeyPage({super.key});

  Future<Map<String, String>> _loadKeys() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/input_keys.txt');

    if (await file.exists()) {
      final contents = await file.readAsString();
      final lines = contents.split('\n');
      final keys = <String, String>{};

      for (var line in lines) {
        final parts = line.split(':');
        if (parts.length == 2) {
          keys[parts[0].trim()] = parts[1].trim();
        }
      }
      return keys;
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3D3CD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3D3CD),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Veryfi Keys',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<Map<String, String>>(
                future: _loadKeys(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No keys found.'));
                  } else {
                    final keys = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEC5D6),
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: keys.entries.map((entry) {
                            return ListTile(
                              title: SelectableText(
                                '${entry.key}:',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: SelectableText(
                                entry.value,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

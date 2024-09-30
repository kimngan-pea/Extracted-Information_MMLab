// Display form text and json file extracted
import "dart:convert";
import "dart:io";
import "package:extracted_information/Screen/Home/home.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:open_file/open_file.dart";
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";

class ExtractedJsonfile extends StatelessWidget {
  final File combinedData;

  const ExtractedJsonfile({
    super.key,
    required this.combinedData,
  });

  Future<Map<String, dynamic>> _readReplyFile() async {
    final contents = await combinedData.readAsString();
    return json.decode(contents);
  }

  String _prettyPrintJson(Map<String, dynamic> jsonObject) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final result = encoder.convert(jsonObject);
    return result;
  }

  Future<File> _saveJson(String formattedJson) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/results.json');
    print('Saving Json result to file: ${file.path}');
    return file.writeAsString(json.encode(formattedJson));
  }

  Future<void> _copyJsonToClipboard(BuildContext context, jsonString) async {
    await Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON copied to clipboard')),
    );
  } 

  Future<void> _saveFile(BuildContext context, String jsonString) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        final directoryPath = result;
        final filePath = '$directoryPath/downloaded_json.json';
        final file = File(filePath);

        await file.writeAsString(jsonString);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved to: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File save cancelled')),
        );
      }
    } else {
      print('Storage permission denied');
    }
  }

  Future<void> _openFile() async {
    final file = await pickFile();
    if (file != null) {
      print('File Path: ${file.path}');
      OpenFile.open(file.path);
    }
  }

  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return null;
    return File(result.files.first.path!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Json'),
        backgroundColor: Colors.green[300], 
        leading: IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (text) => Home()));
            },
          ),
      ),
      backgroundColor: const Color(0xFFB3D3CD),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _readReplyFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final jsonObject = snapshot.data ?? {};
            final formattedJson = _prettyPrintJson(jsonObject);
            _saveJson(formattedJson);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formattedJson,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          await _saveFile(context, formattedJson);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[200]),
                        label: const Text(
                          'Download',
                          style: TextStyle(color: Colors.white),),
                     ),
                     const SizedBox(width: 20), 
                     TextButton.icon(
                      icon: const Icon(Icons.open_in_new_rounded),
                      onPressed: _openFile,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[200]),
                      label: const Text(
                        'Open file',
                        style: TextStyle(color: Colors.white),),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await _copyJsonToClipboard(context, formattedJson);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[50]),
                    label: const Text(
                      'Copy JSON to Clipboard',),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ExtractedData extends StatelessWidget {
  final File combinedData;

  const ExtractedData({
    super.key,
    required this.combinedData,
  });

  Future<Map<String, dynamic>> _readReplyFile() async {
    print('Reading reply file: ${combinedData.path}');
    final contents = await combinedData.readAsString();
    return json.decode(contents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Extracted Data'),
          backgroundColor: Colors.green[300]),
      backgroundColor: const Color(0xFFB3D3CD),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _readReplyFile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Expanded(
                    child: ListView(
                      children: snapshot.data?.entries.map((entry) {
                            return ListTile(
                              title: Text(
                                '${entry.key}:',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${entry.value}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                  );
                }
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[200]),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ExtractedJsonfile(combinedData: combinedData)));
            },
            child:
                const Text('Take file', style: TextStyle(color: Colors.white)),
          ),
          Expanded(child: ListView())
        ],
      ),
    );
  }
}

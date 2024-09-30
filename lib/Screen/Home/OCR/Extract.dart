// Upload image and extract text to API
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:extracted_information/Screen/Home/OCR/Convert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

class ExtractText extends StatefulWidget {
  final File processedFile;

  const ExtractText(this.processedFile, {super.key});

  @override
  State<ExtractText> createState() => __ExtractTextState();
}

class __ExtractTextState extends State<ExtractText> {
  final TextEditingController _panApiKeyController = TextEditingController();
  bool _isPanApiKeyMissing = false;


  Future<File> _saveResponseToFile(Map<String, dynamic> response) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/response.json');
    print('Saving response to file: ${file.path}');
    return file.writeAsString(json.encode(response));
  }

  Future<Map<String, dynamic>> _readResponseFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/response.json');
    final contents = await file.readAsString();
    return json.decode(contents);
  }

  Future<File> _uploadImageV(
      File imageFile,
      String service,
      String clientId,
      String clientSecret,
      String username,
      String apiKey,
      String panApiKey) async {
    final dio = Dio();

    final url =
        'https://fastapi-r12h.onrender.com/text-extraction?service=$service&client_id=$clientId&client_secret=$clientSecret&username=$username&api_key=$apiKey&PAN_api_key=$panApiKey';
    print('Uploading image to: $url');

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path,
          contentType: MediaType('image', 'jpeg')),
    });

    try {
      final response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('Response data: $responseData');

        if (responseData is Map<String, dynamic>) {
          return await _saveResponseToFile(responseData);
        } else {
          throw Exception('Unexpected response format: $responseData');
        }
      } else {
        throw Exception(
            'Image upload failed with status code: ${response.statusCode}, body: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<File> _uploadImageG(
      File imageFile,
      String service,
      String panApiKey) async {
    final dio = Dio();

    final url = 'https://fastapi-r12h.onrender.com/text-extraction?service=$service&PAN_api_key=$panApiKey';
    print('Uploading image to: $url');

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path, contentType: MediaType('image', 'jpeg')),
    });
 
    try {
      final response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('Response data: $responseData');

        if (responseData is Map<String, dynamic>) {
          return await _saveResponseToFile(responseData);
        } else {
          throw Exception('Unexpected response format: $responseData');
        }
      } else {
        throw Exception(
            'Image upload failed with status code: ${response.statusCode}, body: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<String?> _showKeyRequired(BuildContext context) async {
    final TextEditingController newPanApiKey = TextEditingController();
    bool obscureText = true; // Variable to control text visibility
    bool isgenerating = false;

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Requiring Pan API Key'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newPanApiKey,
                        obscureText: obscureText,
                        decoration: const InputDecoration(
                          hintText: 'Generating key',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => obscureText = !obscureText);
                      },
                      child: Text(obscureText ? 'Show' : 'Hide'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color(0xFFF48FB1);
                        }
                        return const Color(0xFFFCE4EC);
                      },
                    ),
                  ),
                  onPressed: isgenerating ? null : () async {
                    setState(() => isgenerating = true);
                    final dio = Dio();
                    try {
                      final response = await dio.get('https://fastapi-r12h.onrender.com/generate-api-key');
                      final panApiKey = response.data['api_key'];
                      if (panApiKey != null) {
                        setState(() { 
                          newPanApiKey.text = panApiKey;
                          isgenerating = false;
                        }); // Set the API key in the TextField
                        print('Extracted Pan API key: $panApiKey');
                        Navigator.pop(context, panApiKey);
                      } else {
                        throw Exception('API key not found in the JSON response.');
                      }
                    } catch (e) {
                      print('Error fetching Pan API key: $e');
                      setState(() => isgenerating = false);
                    }
                  },
                  child: Text(isgenerating ? 'Generating...' : 'Generate'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _showServiceDialog(BuildContext context, File processedFile, String panApiKey) async {
    final selectedService = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Choose Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Veryfi'),
                onTap: () {
                  Navigator.pop(context, 'Veryfi');
                },
              ),
              ListTile(
                title: const Text('Google Vision'),
                onTap: () {
                  Navigator.pop(context, 'GG_vision');
                  _showGoogleVisionDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
    if (selectedService == 'Veryfi' && selectedService != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VeryfiPage(
            panApiKey: panApiKey,
            serviceName: selectedService,
          ),
        ),
      );
    } else {
      print('No service selected');
    }
  }

  Future<void> _showJsonFileDialog(BuildContext context) async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['json']);

    if (result != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      // Process jsonData as needed
      print('Selected JSON data: $jsonData');
    } else {
      print('No file selected');
    }
  }

  void _showGoogleVisionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Google Vision Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  await _showJsonFileDialog(context);
                  Navigator.pop(context);
                },
                child: const Text('Select JSON File'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFB3D3CD),
        appBar: AppBar(
          backgroundColor: Colors.green[300],
          title: const Text('Requirement & Display'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                //Requirement
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.key),
                      label: const Text('Pan API Key'),
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          backgroundColor: Colors.pink[50]),
                      onPressed: () async {
                        String? panApiKey = await _showKeyRequired(context);
                        if (panApiKey != null) {
                          setState(() => _panApiKeyController.text = panApiKey);
                        }
                      },
                    ),
                    const SizedBox(width: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[300]),
                      child: const Text(
                        'Select Services',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_panApiKeyController.text.isNotEmpty) {
                          setState(() => _isPanApiKeyMissing = false);
                          _showServiceDialog(context, widget.processedFile, _panApiKeyController.text);
                        } else {
                          setState(() => _isPanApiKeyMissing = true);
                          print('Pan API Key is required.');
                        }
                      },
                    ),
                  ],
                ),

                //Error message
                if (_isPanApiKeyMissing == true)
                  const Padding(
                      padding: EdgeInsets.only(top: 0.5),
                      child: Text(
                        'Pan API Key is required!',
                        style: TextStyle(color: Colors.red),
                      )),

                const SizedBox(height: 10),
                //Display
                SizedBox(
                  width: 300, 
                  height: 150, 
                  child: Image.file(widget.processedFile),
                ),
                const SizedBox(height: 10),
                FutureBuilder<Map<String, dynamic>>(
                  future: _readResponseFile(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Expanded(
                          child: ListView(
                            children: snapshot.data?.entries.map((entry) {
                                  return ListTile(
                                    title: Text('${entry.key}:'),
                                    subtitle: Text('${entry.value}'),
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

                //Configure Templates
                const SizedBox(height: 5.0),
                TextButton.icon(
                  icon: const Icon(Icons.start),
                  label: const Text('Configure Templates'),
                  style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      backgroundColor: Colors.pink[200]),
                  onPressed: () async {
                    //if (_selectedService == true) {
                      final directory = await getApplicationDocumentsDirectory();
                      final responseFile = File('${directory.path}/response.json');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConvertText(responseFile),
                          ));
                  },
                ),
              ],
            )));
  }
}

class VeryfiPage extends StatefulWidget {
  final String panApiKey;
  final String serviceName;

  const VeryfiPage(
      {super.key, required this.panApiKey, required this.serviceName});

  @override
  _VeryfiPageState createState() => _VeryfiPageState();
}

class _VeryfiPageState extends State<VeryfiPage> {
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _clientSecretController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveInputToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/input_keys.txt');

    // Combine all inputs into a single string
    final inputData = '''
    Client ID: ${_clientIdController.text}
    Client Secret: ${_clientSecretController.text}
    Username: ${_usernameController.text}
    API Key: ${_apiKeyController.text}
    Pan API Key: ${widget.panApiKey}
    ''';

    print('Saving input to file: ${file.path}');
    await file.writeAsString(inputData);
  }

  Future<void> _uploadImageWithInputs(File imageFile) async {
    final clientId = _clientIdController.text;
    final clientSecret = _clientSecretController.text;
    final username = _usernameController.text;
    final apiKey = _apiKeyController.text;

    final uploadInputKeys = __ExtractTextState();
    final responseFile = await uploadInputKeys._uploadImageV(
        imageFile,
        widget.serviceName,
        clientId,
        clientSecret,
        username,
        apiKey,
        widget.panApiKey);
    print('Image uploaded and response saved to file: $responseFile');

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExtractText(imageFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text('Veryfi Keys'),
        backgroundColor: Colors.green[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _clientIdController,
              decoration: const InputDecoration(
                labelText: 'Enter your client_id',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _clientSecretController,
              decoration: const InputDecoration(
                labelText: 'Enter your client_secret',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter your username',
                border: OutlineInputBorder(),
              ),            
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Enter your Api_key',
                border: OutlineInputBorder(),
              ),              
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveInputToFile();
                final directory = await getApplicationDocumentsDirectory();
                final imageFile = File('${directory.path}/processed_image.jpeg');
                await _uploadImageWithInputs(imageFile);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

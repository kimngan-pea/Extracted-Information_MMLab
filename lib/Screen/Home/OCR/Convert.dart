// Upload template request of user to API
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'Received.dart';

class ConvertText extends StatefulWidget {
  final File responseFile;

  const ConvertText(this.responseFile, {super.key});

  @override
  State<ConvertText> createState() => __ConvertTextState();
}

class __ConvertTextState extends State<ConvertText> {
  List<Map<String, dynamic>> data = [];
  final List<TextEditingController> fieldController = [];
  int? selectedIndex;
  final TextEditingController newNameController = TextEditingController();

  void _addNewField() {
    final controller = TextEditingController();
    setState(() {
      fieldController.add(controller);
    });
  }

  Widget _buildTextField(TextEditingController controller, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  print('Selected index: $selectedIndex');
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedIndex == index ? Colors.blue : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(4.0),
                    hintText: 'Enter field',
                  ),
                  onChanged: (text) {
                    print('Text field $index updated: $text');
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.pink[300],
            ),
            onPressed: () {
              _deleteField(controller);
            },
          ),
        ],
      ),
    );
  }

  void _modifyField() {
    if (fieldController.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Modify Field'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedIndex,
                  items: List.generate(
                    fieldController.length,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        fieldController[index].text.isNotEmpty
                            ? fieldController[index]
                                .text // Use field text if available
                            : 'Field ${index + 1}', // Fallback to generic label
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedIndex = value;
                      newNameController.text =
                          fieldController[selectedIndex!].text;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Field',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newNameController,
                  decoration: const InputDecoration(
                    labelText: 'New Field',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedIndex != null &&
                      selectedIndex! < fieldController.length) {
                    final TextEditingController controller =
                        fieldController[selectedIndex!];
                    setState(() {
                      controller.text = newNameController.text;
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Change'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle case where no fields exist
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('No Fields Available'),
            content: const Text('There are no fields to modify.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _deleteField(TextEditingController controller) {
    setState(() {
      int index = fieldController.indexOf(controller);
      fieldController.removeAt(index);
    });
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/template.json';
  }

  Future<File> _saveReplyToFile(Map<String, dynamic> response) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/reply.json');
    print('Saving reply to file: ${file.path}');
    return file.writeAsString(json.encode(response));
  }

  Future<File> _uploadTemplate() async {
    final responseString = await widget.responseFile.readAsString();
    print('Response data contents: $responseString');
    final responseData = jsonDecode(responseString);

    // Read and parse the modified template file
    final modifiedDirectory = await getApplicationDocumentsDirectory();
    final templateFile = File('${modifiedDirectory.path}/template.json');
    final templateString = await templateFile.readAsString();
    final template = jsonDecode(templateString);
    print('Template: $template');
    final templateData = template;
    print('Template data: $templateData');

    // Encode both response data and template data as base64
    final encodedRawText = Uri.encodeComponent(json.encode(responseData));
    final encodedTemplate = Uri.encodeComponent(json.encode(templateData));

    print('Encoded raw text: $encodedRawText');
    print('Encoded template: $encodedTemplate');

    // Prepare data for the second API call
    final secondApiUrl =
        'https://fastapi-r12h.onrender.com/convert?raw_text=$encodedRawText&template=$encodedTemplate';
    print('Sending encoded data to: $secondApiUrl');

    final dio = Dio();

    try {
      final secondResponse = await dio.post(secondApiUrl,
          options: Options(headers: {'Accept': 'applications/json'}));

      if (responseData is Map<String, dynamic>) {
        if (secondResponse.statusCode == 200) {
          // Clean and parse the JSON string
          String cleanedJsonString = secondResponse.data['reply']
              .replaceAll(RegExp(r'```json\n|```'), '');
          print('Cleaned JSON string: $cleanedJsonString');

          // Remove leading and trailing double quotes
          if (cleanedJsonString.startsWith('"') &&
              cleanedJsonString.endsWith('"')) {
            cleanedJsonString =
                cleanedJsonString.substring(1, cleanedJsonString.length - 1);
          }

          // Convert the cleaned JSON string to a Map
          final combinedData = jsonDecode(cleanedJsonString);
          print('Combined response data: $combinedData');

          // Save the combined data to a file
          return await _saveReplyToFile(combinedData);
        } else {
          throw Exception(
              'Second API call failed with status code: ${secondResponse.statusCode}, body: ${secondResponse.data}');
        }
      } else {
        throw Exception('Unexpected response format: $responseData');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error uploading template: $e');
    }
  }

  Future<void> _saveToJsonFile() async {
    List<String> inputValues =
        fieldController.map((controller) => controller.text).toList();
    Map<String, dynamic> jsonMap = {};
    for (String key in inputValues) {
      jsonMap[key] = "";
    }
    String jsonString = jsonEncode(jsonMap);
    print('json input: $jsonString');

    final path = await _getFilePath();
    final file = File(path);
    await file.writeAsString(jsonString);
    print('template json: ${file.path}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved to template.json')),
    );

    final combinedDataFile = await _uploadTemplate();

    Navigator.push(
      context, 
      MaterialPageRoute(
        builder:(context) => ExtractedData(combinedData: combinedDataFile,),
      ));
  }

  @override
  void dispose() {
    for (var controller in fieldController) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collect Template'),
        backgroundColor: Colors.green[300],
      ),
      body: Container(
        color: const Color(0xFFB3D3CD),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: fieldController.length,
                itemBuilder: (context, index) {
                  return _buildTextField(fieldController[index], index);
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addNewField,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[200]),
                  child: const Text(
                    'Add field',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _modifyField,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[200]),
                  child: const Text(
                    'Modify field',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _saveToJsonFile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[50]),
                child: const Text('Collect Information')
            ),
            Expanded(child: ListView())
          ],
        ),
      ),
    );
  }
}

// Collect image for extract
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:extracted_information/Screen/Home/OCR/Extract.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class CameraAppState extends StatefulWidget {
  const CameraAppState({super.key});

  @override
  State<CameraAppState> createState() =>  _CameraAppStateState();
}

class  _CameraAppStateState extends State<CameraAppState> {

  //late final CameraDescription camera;
  late List<CameraDescription> cameras; 
  late final CameraDescription camera;
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  Future<void> _setupCameraController() async {
   cameras = await availableCameras(); 

    if (cameras.isNotEmpty) {
      setState(() {
        camera = cameras.first;
        _cameraController = CameraController(
          camera, 
          ResolutionPreset.high,
        );
        _initializeControllerFuture = _cameraController.initialize();
      });
    }
  }

  Future<File> _processImage(File imageFile) async {
    // Read the image from the file
    final image = img.decodeImage(await imageFile.readAsBytes());

    if (image != null) {
      // Optionally, perform image processing (e.g., sharpening, adjusting brightness)
      final processedImage = img.adjustColor(image, gamma: 1.2);

      // Save the processed image back to a file
      final directory = await getApplicationDocumentsDirectory();
      final processedImagePath = '${directory.path}/processed_image.jpeg';
      final processedImageFile = File(processedImagePath)
        ..writeAsBytesSync(img.encodeJpg(processedImage));
      return processedImageFile;
    } else { 
      throw Exception('Failed to decode image');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.green[300],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );

      if (croppedFile != null) {
        print('Sucessful');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Service'),
        backgroundColor: Colors.green[300],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      backgroundColor: const Color(0xFFB3D3CD),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;

                final image = await _cameraController.takePicture();

                CroppedFile? croppedFile = await ImageCropper().cropImage(
                  sourcePath: image.path,
                  uiSettings: [
                    AndroidUiSettings(
                      toolbarTitle: 'Cropper',
                      toolbarColor: Colors.green[300],
                      toolbarWidgetColor: Colors.white,
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: false,
                      aspectRatioPresets: [
                        CropAspectRatioPreset.square,
                        CropAspectRatioPreset.ratio3x2,
                        CropAspectRatioPreset.original,
                        CropAspectRatioPreset.ratio4x3,
                        CropAspectRatioPreset.ratio16x9
                      ],
                    ),
                    IOSUiSettings(
                      title: 'Cropper',
                    ),
                    WebUiSettings(
                      context: context,
                    ),
                  ],
                );

                if (croppedFile != null) {
                  // Process the image to enhance quality before uploading
                  final processedFile = await _processImage(File(croppedFile.path));
                  print('Sucessful');
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ExtractText(processedFile)
                    ),
                  );
                }
              } catch (e) {
                print('Error occurred: $e');
              }
            },
            tooltip: 'Capture Image',
            child: const Icon(
              Icons.camera_alt,
              color: Color(0x798BA868),
            ),
          ),
          const SizedBox(width: 40),
          FloatingActionButton(
            onPressed: () async {
              await _pickImageFromGallery();
            },
            tooltip: 'Pick Image from Gallery',
            child: const Icon(
              Icons.photo_library,
              color: Color(0x798BA868),
            ),
          ),
        ],
      ),
    );
  }
}


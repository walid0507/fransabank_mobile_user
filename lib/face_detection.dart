import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'face_liveness.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'ml_service.dart';
import 'image_converter.dart';
import 'package:image/image.dart' as imglib;

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({
    super.key,
  }); // Correction : ajout d'un espace après "const"
  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? _image;
  File? _capturedImage;
  final MLService _mlService = MLService();

  Future<void> _navigateToLivenessDetection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FaceLivenessScreen()),
    );
    if (result != null && result is File) {
      setState(() {
        _capturedImage = result; // On récupère l'image validée
      });
    }
  }

  Future _pickimage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _image = File(image.path);
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _detectFaces() async {
    if (_image == null || _capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez sélectionner une image et capturer une photo.',
          ),
        ),
      );
      return;
    }

    final faceDetector = GoogleMlKit.vision.faceDetector();

    final inputImage = ImageConverter.convertFileToInputImage(_image!);
    final capturedInputImage = ImageConverter.convertFileToInputImage(
      _capturedImage!,
    );

    List<Face> faces = [];
    List<Face> capturedFaces = [];

    try {
      faces = await faceDetector.processImage(inputImage);
      capturedFaces = await faceDetector.processImage(capturedInputImage);

      if (faces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun visage détecté dans l\'image.')),
        );
        return;
      }

      if (capturedFaces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aucun visage détecté dans la photo capturée.'),
          ),
        );
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la détection des visages : $e');
      }
      return;
    }

    final face = faces.first;
    final capturedFace = capturedFaces.first;

    final uploadedImage = ImageConverter.convertFileToImage(_image!)!;
    //final capturedImage = ImageConverter.convertFileToImage(_capturedImage!)!;
    final capturedImage =
        ImageConverter.convertFileToInputImage(_capturedImage!)!;
    final uploadedCroppedFace = ImageConverter.cropFace(uploadedImage, face);
    final capturedCroppedFace = _mlService.cropFace(
      capturedImage,
      capturedFace,
    );
    await _mlService.initializeInterpreter();
    final uploadedVector = await _mlService.predict(inputImage, face);
    final capturedVector = await _mlService.predict(
      capturedInputImage,
      capturedFace,
    );

    final distance = _mlService.euclideanDistance(
      capturedVector.cast<double>(),
      uploadedVector.cast<double>(),
    );
    final threshold = 1;

    if (kDebugMode) {
      print(
        'Distance calculée avant condition : ${distance.toStringAsFixed(2)}',
      );
    }

    if (distance <= threshold) {
      if (kDebugMode) {
        print('Condition "distance <= threshold" exécutée.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Les visages correspondent ! Distance : ${distance.toStringAsFixed(2)}',
          ),
        ),
      );
    } else {
      if (kDebugMode) {
        print('Condition "distance > threshold" exécutée.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Les visages ne correspondent pas. Distance : ${distance.toStringAsFixed(2)}',
          ),
        ),
      );
    }

    // Afficher les images prétraitées
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Images Prétraitées'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Image Importée :'),
              imageFromImgLib(uploadedCroppedFace),
              SizedBox(height: 10),
              Text('Image Capturée :'),
              imageFromImgLib(capturedCroppedFace),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Detection')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey,
                child:
                    _image != null
                        ? Image.file(_image!)
                        : Center(child: Icon(Icons.add_a_photo, size: 60)),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.blueAccent,
                child: MaterialButton(
                  onPressed: () {
                    _navigateToLivenessDetection();
                  },
                  child: const Text(
                    'prendre une photo',
                    style: TextStyle(color: Colors.white, fontSize: 23),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.blueAccent,
                child: MaterialButton(
                  onPressed: () {
                    _pickimage(ImageSource.gallery);
                  },
                  child: const Text(
                    'importer la photo identité',
                    style: TextStyle(color: Colors.white, fontSize: 23),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _detectFaces,
                child: const Text('Detect Faces'),
              ),
              if (_capturedImage != null)
                Container(
                  width: double.infinity,
                  height: 250,
                  child: Image.file(_capturedImage!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Fonction pour convertir une image imglib en Image Widget
Image imageFromImgLib(imglib.Image img) {
  return Image.memory(Uint8List.fromList(imglib.encodeJpg(img)));
}

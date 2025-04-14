import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'face_liveness.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'ml_service.dart';
import 'image_converter.dart';
import 'package:image/image.dart' as imglib;
import 'curved_header.dart';

class FaceDetectionScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  const FaceDetectionScreen({super.key, required this.imageBytes});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> 
    with SingleTickerProviderStateMixin {
  File? _image;
  File? _capturedImage;
  final MLService _mlService = MLService();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final Color primaryBlue = const Color(0xFF024DA2);

  @override
  void initState() {
    super.initState();
    _image = _createTempFile(widget.imageBytes!);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  File _createTempFile(Uint8List bytes) {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/uploaded_image.jpg');
    tempFile.writeAsBytesSync(bytes);
    return tempFile;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: isEnabled ? onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: width ?? 200,
          height: height ?? 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: [primaryBlue.withOpacity(0.9), primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToLivenessDetection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FaceLivenessScreen()),
    );
    if (result != null && result is File) {
      setState(() {
        _capturedImage = result;
      });
    }
  }

  // Future _pickImage(ImageSource source) async {
  //   try {
  //     final image = await ImagePicker().pickImage(source: source);
  //     if (image == null) return;
  //     setState(() {
  //       _image = File(image.path);
  //     });
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  // }

  Future<void> _detectFaces() async {
    if (_capturedImage == null) { // On ne vérifie plus _image
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez capturer une photo.'),
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
          const SnackBar(content: Text('Aucun visage détecté dans l\'image.')),
        );
        return;
      }

      if (capturedFaces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
          title: const Text('Images Prétraitées'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Image Importée :'),
              imageFromImgLib(uploadedCroppedFace),
              const SizedBox(height: 10),
              const Text('Image Capturée :'),
              imageFromImgLib(capturedCroppedFace),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CurvedHeader(
            height: 0.25,
            title: 'Reconnaissance faciale',
            
            onBackPressed: () => Navigator.pop(context),
            child: Container(),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _imagePreviewSection(),
                        const SizedBox(height: 20),
                        _capturedImagePreviewSection(),
                        const SizedBox(height: 30),
                        _buildModernButton(
                          text: 'Démarrer la vérification',
                          onPressed: _detectFaces,
                          icon: Icons.face_retouching_natural,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _imagePreviewSection() {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryBlue.withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(_image!, fit: BoxFit.cover),
          ),
        ),
        // Supprimer le bouton d'import ici
      ],
    );
  }
  
  Widget _capturedImagePreviewSection() {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryBlue.withOpacity(0.3)),
          ),
          child: _capturedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_capturedImage!, fit: BoxFit.cover),
                )
              : Center(
                  child: IconButton(
                    icon: Icon(Icons.camera_alt,
                        color: primaryBlue.withOpacity(0.5), size: 50),
                    onPressed: _navigateToLivenessDetection,
                  ),
                ),
        ),
        const SizedBox(height: 15),
        _buildModernButton(
          text: 'Prendre une photo',
          onPressed: _navigateToLivenessDetection,
          icon: Icons.camera_alt,
          width: double.infinity,
        ),
      ],
    );
  }
}

// Fonction pour convertir une image imglib en Image Widget
Image imageFromImgLib(imglib.Image img) {
  return Image.memory(Uint8List.fromList(imglib.encodeJpg(img)));
}
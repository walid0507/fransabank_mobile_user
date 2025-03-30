import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class MRZScanner extends StatefulWidget {
  const MRZScanner({super.key});

  @override
  State<MRZScanner> createState() => _MRZScannerState();
}

class _MRZScannerState extends State<MRZScanner> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  late final Future<void> _future;
  CameraController? _cameraController;
  final textRecognizer = TextRecognizer();
  bool _isFlashOn = false;
  bool _isMRZValid = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (_isPermissionGranted)
                FutureBuilder<List<CameraDescription>>(
                  future: availableCameras(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _initCameraController(snapshot.data!);
                      return Transform.scale(
                        scale: 1.5,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio:
                                1 / _cameraController!.value.aspectRatio,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                      );
                    } else {
                      return const LinearProgressIndicator();
                    }
                  },
                ),
              if (_isPermissionGranted)
                Stack(
                  children: [
                    _buildBlurredBackground(context),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: _buildRectangleWithText(context),
                    ),
                    _buildBottomButtons(context),
                  ],
                )
              else
                const Center(
                  child: Text(
                    'Camera permission denied',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRectangleWithText(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.55,
            height: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isMRZValid ? Colors.green : Colors.white,
                width: 3,
              ),
            ),
          ),
          Positioned(
            left: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    30,
                    (index) => const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    30,
                    (index) => const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    30,
                    (index) => const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            child: RotatedBox(
              quarterTurns: 1,
              child: const Text(
                "Aligner votre carte d'identité ici",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: InvertedRectangleClipper(
            width: MediaQuery.of(context).size.width * 0.55,
            height: MediaQuery.of(context).size.width * 0.85,
            borderRadius: 40,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _toggleFlash,
            backgroundColor: _isFlashOn ? Colors.amber : Colors.white,
            child: Icon(
              _isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
              color: _isFlashOn ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFlash() async {
    if (_cameraController != null) {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    _cameraController?.dispose();
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) return;

    CameraDescription? camera;
    for (var current in cameras) {
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    // Démarrer l'analyse continue
    _startContinuousScan();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startContinuousScan() async {
    while (mounted) {
      if (!_isProcessing) {
        _isProcessing = true;
        try {
          final image = await _cameraController!.takePicture();
          final inputImage = InputImage.fromFilePath(image.path);
          final recognizedText = await textRecognizer.processImage(inputImage);

          // Utiliser la méthode preprocessMRZ existante
          List<String> mrzLines = preprocessMRZ(recognizedText.text);
          if (mrzLines.length == 3) {
            if (mounted) {
              Navigator.pop(context, mrzLines);
            }
            break;
          }
        } catch (e) {
          print('Error scanning image: $e');
        }
        _isProcessing = false;
        // Petite pause pour ne pas surcharger
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  List<String> preprocessMRZ(String text) {
    List<String> lines =
        text
            .split('\n')
            .map((line) => line.replaceAll(' ', ''))
            .map((line) => line.replaceAll('«', '<'))
            .map(
              (line) => line.replaceAllMapped(
                RegExp(r'(?<=<<<+)K+'),
                (match) => '<' * match.group(0)!.length,
              ),
            )
            .toList();

    String? line1, line2, line3;
    for (var line in lines) {
      if (line.startsWith("IDDZA") && line.length >= 24) {
        line1 = line;
      } else if ( line.length == 30 && RegExp(
        r'^(\d{6})(\d)([MF])(\d{6})(\d)DZA<+(\d?)$',
      ).hasMatch(line)) {
        line2 = line;
      } else if (line.contains("<<") &&
          line.length ==30 &&
          !line.startsWith("IDDZA")) {
        line3 = line;
      }
    }

    if (line1 != null && line2 != null && line3 != null) {
      line1 = line1.padRight(30, '<');
      line2 = line2.padRight(30, '<');
      line3 = line3.padRight(30, '<');
      return [line1, line2, line3];
    }
    print("MRZ invalid.Reprenez la photo");
    return [];
  }

  Map<String, String> extractMRZData(List<String> mrz) {
    if (mrz.length < 3) {
      print("⚠️ Erreur: MRZ incomplet (${mrz.length} lignes trouvées)");
      return {};
    }

    String line1 = mrz[0];
    String line2 = mrz[1];
    String line3 = mrz[2];

    Map<String, String> extractedData = {};
    extractedData["Type de document"] = line1.substring(0, 2);
    String nationality = line2.substring(15, 18);
    extractedData["Nationalité"] =
        (nationality == "DZA") ? "Algérienne" : nationality;
    extractedData["Numéro de document"] = line1.substring(5, 14);
    extractedData["Date de naissance"] = formatDate(line2.substring(0, 6));
    extractedData["Sexe"] = line2.substring(7, 8);
    extractedData["Date d'expiration"] = formatDate(line2.substring(8, 14));

    List<String> nameParts = line3.split("<<");
    extractedData["Nom"] = nameParts[0].replaceAll('<', ' ');
    extractedData["Prénom"] =
        nameParts.length > 1 ? nameParts[1].replaceAll('<', ' ') : '';

    return extractedData;
  }

  String formatDate(String dateYYMMDD) {
    int yearPrefix = int.parse(dateYYMMDD.substring(0, 2)) >= 40 ? 19 : 20;
    String year = "$yearPrefix${dateYYMMDD.substring(0, 2)}";
    String month = dateYYMMDD.substring(2, 4);
    String day = dateYYMMDD.substring(4, 6);

    return "$day/$month/$year";
  }
}

class InvertedRectangleClipper extends CustomClipper<Path> {
  final double width;
  final double height;
  final double borderRadius;

  InvertedRectangleClipper({
    required this.width,
    required this.height,
    this.borderRadius = 20,
  });

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: width, height: height);

    final roundedRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    return Path.combine(
      PathOperation.difference,
      path,
      Path()..addRRect(roundedRect),
    );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

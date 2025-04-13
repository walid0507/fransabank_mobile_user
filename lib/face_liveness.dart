import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/widgets.dart';

class FaceLivenessScreen extends StatefulWidget {
  const FaceLivenessScreen({super.key});

  @override
  State<FaceLivenessScreen> createState() => _FaceLivenessScreenState();
}

class _FaceLivenessScreenState extends State<FaceLivenessScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  Timer? _timer;
  Timer? _countdownTimer;
  XFile? _capturedImage;
  bool _faceDetected = false;
  bool _allChecksPassed = false;
  int _countdownSeconds = 3;

  // États de vérification séquentielle
  int _currentStep = 0;
  final List<bool> _steps = [false, false, false]; // droite, gauche, sourire

  double _progressValue = 0.0;
  final bool shouldMirror = Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }

    _startFaceDetection();
  }

  void _startFaceDetection() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (_cameraController == null || !_cameraController!.value.isInitialized)
        return;

      final XFile file = await _cameraController!.takePicture();
      final faces = await _detectFaces(File(file.path));

      if (faces.isNotEmpty) {
        final face = faces.first;

        setState(() {
          _faceDetected = true;

          // Vérification séquentielle des mouvements selon l'étape actuelle
          switch (_currentStep) {
            case 0: // Tête à droite
              if (shouldMirror
                  ? face.headEulerAngleY! < -15
                  : face.headEulerAngleY! > 15) {
                _steps[0] = true;
                _currentStep = 1;
              }
              break;
            case 1: // Tête à gauche
              if (shouldMirror
                  ? face.headEulerAngleY! > 15
                  : face.headEulerAngleY! < -15) {
                _steps[1] = true;
                _currentStep = 2;
              }
              break;
            case 2: // Sourire
              if (face.smilingProbability != null &&
                  face.smilingProbability! > 0.6) {
                _steps[2] = true;
                _currentStep = 3;
                _startCountdown();
              }
              break;
          }

          // Calcul de la progression
          _progressValue = _steps.where((step) => step).length / _steps.length;

          // Sauvegarde de l'image pour la fin du processus
          if (!_allChecksPassed && _steps.every((step) => step)) {
            _capturedImage = file;
          }
        });
      } else {
        setState(() {
          _faceDetected = false;
        });
      }
    });
  }

  void _startCountdown() {
    _timer?.cancel(); // Arrêter la détection faciale

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _allChecksPassed = true;
          _countdownTimer?.cancel();

          // Prendre la photo finale
          _takeFinalPicture();
        }
      });
    });
  }

  Future<void> _takeFinalPicture() async {
    try {
      final XFile finalImage = await _cameraController!.takePicture();

      // Attendre un peu pour montrer l'animation de succès
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pop(context, File(finalImage.path));
      });
    } catch (e) {
      // En cas d'erreur, utiliser l'image déjà capturée
      Navigator.pop(
        context,
        _capturedImage != null ? File(_capturedImage!.path) : null,
      );
    }
  }

  Future<List<Face>> _detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    return await _faceDetector!.processImage(inputImage);
  }

  String _getCurrentInstruction() {
    if (!_faceDetected) return "Placez votre visage dans le cercle";

    switch (_currentStep) {
      case 0:
        return "Tournez la tête à droite";
      case 1:
        return "Tournez la tête à gauche";
      case 2:
        return "Souriez";
      case 3:
        if (_countdownSeconds > 0) {
          return "Vérification réussie\nNe bougez pas,Photo dans $_countdownSeconds secondes";
        } else {
          return "Prise de photo...";
        }
      default:
        return "Vérification réussie";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleDiameter = size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Vérification d'identité",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fond noir
          Container(color: Colors.black),

          // Caméra au centre du cercle
          if (_cameraController != null &&
              _cameraController!.value.isInitialized)
            Center(
              child: ClipOval(
                child: SizedBox(
                  width: circleDiameter,
                  height: circleDiameter,
                  child: Transform(
                    alignment: Alignment.center,
                    transform:
                        shouldMirror
                            ? Matrix4.rotationY(math.pi)
                            : Matrix4.identity(),
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            ),

          // Cercle progressif autour du visage
          Center(
            child: SizedBox(
              width: circleDiameter + 4,
              height: circleDiameter + 4,
              child: CustomPaint(
                painter: ProgressiveCirclePainter(
                  progress: _progressValue,
                  faceDetected: _faceDetected,
                ),
              ),
            ),
          ),

          // Chronomètre au centre si le compte à rebours est en cours
          if (_countdownSeconds > 0 && _currentStep == 3)
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "$_countdownSeconds",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Instruction en bas
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                _getCurrentInstruction(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Icônes d'étapes de vérification
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusIcon(Icons.turn_right, _steps[0]),
                const SizedBox(width: 30),
                _buildStatusIcon(Icons.turn_left, _steps[1]),
                const SizedBox(width: 30),
                _buildStatusIcon(Icons.sentiment_satisfied_alt, _steps[2]),
              ],
            ),
          ),

          // Animation de succès
          // if (_allChecksPassed)
          //   Container(
          //     color: Colors.black.withOpacity(0.7),
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Icon(Icons.check_circle, color: Colors.green, size: 80),
          //           const SizedBox(height: 20),
          //           const Text(
          //             "Vérification réussie",
          //             style: TextStyle(color: Colors.white, fontSize: 24),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  // Icône pour chaque étape
  Widget _buildStatusIcon(IconData icon, bool completed) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? Colors.green : Colors.grey[800],
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

// Peintre personnalisé pour le cercle qui se remplit progressivement
class ProgressiveCirclePainter extends CustomPainter {
  final double progress;
  final bool faceDetected;

  ProgressiveCirclePainter({
    required this.progress,
    required this.faceDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Cercle complet (contour blanc ou gris)
    final fullCirclePaint =
        Paint()
          ..color =
              faceDetected
                  ? Colors.green.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius - 1, fullCirclePaint);

    // Cercle progressif (contour vert)
    if (progress > 0) {
      final progressPaint =
          Paint()
            ..color = Colors.green
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0
            ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1.5),
        -math.pi / 2, // Commencer en haut
        2 * math.pi * progress, // Angle basé sur la progression
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressiveCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.faceDetected != faceDetected;
  }
}

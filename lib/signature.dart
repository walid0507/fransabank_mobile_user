import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'comptes.dart';

class SignaturePainter extends CustomPainter {
  final SignatureController controller;

  SignaturePainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (var point in controller.points) {
      if (point != null) {
        canvas.drawPoints(ui.PointMode.points, [point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}

class SignatureController extends ChangeNotifier {
  List<Offset?> points = [];
  bool _isEmpty = true;

  bool get isEmpty => _isEmpty;

  void addPoint(Offset point) {
    points.add(point);
    _isEmpty = false;
    notifyListeners();
  }

  void clear() {
    points.clear();
    _isEmpty = true;
    notifyListeners();
  }

  Future<Uint8List?> toPngBytes() async {
    if (isEmpty) return null;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (var point in points) {
      if (point != null) {
        canvas.drawPoints(ui.PointMode.points, [point], paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(300, 300); // Fixed size for simplicity
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

class Signature extends StatefulWidget {
  const Signature({super.key});

  @override
  State<Signature> createState() => _SignatureState();
}

class _SignatureState extends State<Signature> {
  final SignatureController _controller = SignatureController();
  bool _isLoading = false;
  bool _hasSignature = false;
  String? _signaturePath;

  Future<void> _saveSignature() async {
    if (_controller.isEmpty) return;

    final Uint8List? data = await _controller.toPngBytes();
    if (data == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
    File(path).writeAsBytesSync(data);

    setState(() {
      _signaturePath = path;
      _hasSignature = true;
    });
    Navigator.pop(context); // Ferme la boîte de dialogue
  }

  Future<void> _showSignatureDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Signez ici',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          _controller.addPoint(details.localPosition);
                          setState(() {});
                        },
                        child: CustomPaint(
                          painter: SignaturePainter(_controller),
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () => _controller.clear(),
                    ),
                    ElevatedButton(
                      onPressed: _saveSignature,
                      child: Text('Valider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF024DA2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    setState(() => _isLoading = true);

    // Simuler un délai de chargement
    await Future.delayed(Duration(seconds: 2));

    // Simuler une réussite (à remplacer par votre logique d'API)
    bool success = true;

    if (success) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/images/demande.json',
                    height: 150,
                    repeat: false,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Votre demande a été envoyée à nos équipes',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ComptesPage(nomClient: '')), // TODO: Pass the actual client name
                      );
                    },
                    child: Text('Voir demande'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF024DA2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur est survenue. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Color primaryBlue = Color(0xFF024DA2);

    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: InvertedCurvedClipper(),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: primaryBlue,
                image: DecorationImage(
                  image: AssetImage('assets/images/stars.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    primaryBlue.withOpacity(0.9),
                    BlendMode.srcOver,
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50),
                Lottie.asset(
                  'assets/images/signature.json',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 30),
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_hasSignature && _signaturePath != null)
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_signaturePath!),
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ElevatedButton(
                        onPressed: _showSignatureDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _hasSignature ? 'Modifier la signature' : 'Signer',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_hasSignature)
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Soumettre',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class InvertedCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.90);
    path.quadraticBezierTo(
        size.width * 0.10, size.height * 0.95, size.width * 0.25, size.height * 0.95);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.95, size.width, size.height * 0.85);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

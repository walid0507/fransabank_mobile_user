import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:signature/signature.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'shared_data.dart';

class SignaturePage extends StatefulWidget {
  final Uint8List? imageBytes;
  const SignaturePage({Key? key,  required this.imageBytes}) : super(key: key);

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class InvertedCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.90);
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.95,
        size.width * 0.25, size.height * 0.95);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.95, size.width, size.height * 0.85);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

Future<File> pngBytesToJpgFile(Uint8List pngBytes) async {
  try {
    // Décoder l'image PNG
    final image = img.decodeImage(pngBytes);

    // Convertir en JPG avec une qualité de 85%
    final jpgBytes = img.encodeJpg(image!, quality: 85);

    // Créer un fichier temporaire
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(jpgBytes);

    return file;
  } catch (e) {
    print('Erreur de conversion: $e');
    throw Exception('Erreur de conversion de la signature');
  }
}

Future<File> convertBase64ToFile(String base64String, String fileName) async {
  // Supprimer le header "data:image/png;base64," s'il existe
  final splitted = base64String.split(',');
  final base64Data = splitted.length > 1 ? splitted[1] : splitted[0];

  final bytes = base64Decode(base64Data);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');

  await file.writeAsBytes(bytes);
  return file;
}

Future<File> convertUint8ListToFile(Uint8List bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file;
}

class _SignaturePageState extends State<SignaturePage> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );
  String? signatureImage;
  Uint8List? signatureBytes;
  bool showSignaturePad = false;
  bool isLoading = false;
  bool hasNfcSignature = false;

  @override
  void initState() {
    super.initState();
    // Vérifier si une signature existe déjà depuis SharedData
    if (SharedData.signatureData != null) {
      setState(() {
        // Vérifier le type de la signature
        if (SharedData.signatureData is String) {
          signatureImage = SharedData.signatureData as String;
        } else if (SharedData.signatureData is Uint8List) {
          signatureBytes = SharedData.signatureData as Uint8List;
          // Convertir les bytes en base64 pour l'affichage
          signatureImage =
              'data:image/png;base64,${base64Encode(signatureBytes!)}';
        }
        hasNfcSignature = true;
      });
    }
  }

  // Méthode pour obtenir un Widget d'image à partir des données de signature
  Widget getSignatureImageWidget() {
    if (signatureImage != null && signatureImage!.startsWith('data:')) {
      return Image.memory(
        Uri.parse(signatureImage!).data!.contentAsBytes(),
        height: 100,
      );
    } else if (signatureImage != null && signatureImage!.startsWith('/')) {
      return Image.file(
        File(signatureImage!),
        height: 100,
      );
    } else if (signatureBytes != null) {
      return Image.memory(
        signatureBytes!,
        height: 100,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    Color primaryBlue = const Color(0xFF024DA2);

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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Lottie Animation
                  Lottie.asset(
                    'assets/images/signature.json',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Signez ci-dessous',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 20),
                  // Terms text with handwriting font
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentDate,
                              style: GoogleFonts.dancingScript(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Alger, Algérie',
                              style: GoogleFonts.dancingScript(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'En signant ce document, vous acceptez tous les termes et conditions d\'utilisation. Vous serez soumis à une reconnaissance faciale.',
                          style: GoogleFonts.dancingScript(
                            fontSize: 18,
                            height: 2,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Fransabank',
                            style: GoogleFonts.dancingScript(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (signatureImage == null && signatureBytes == null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showSignaturePad = true;
                              });
                            },
                            child: Text(
                              'Signez ici',
                              style: GoogleFonts.dancingScript(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          )
                        else if (hasNfcSignature)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Signature récupérée depuis le scan NFC',
                                style: GoogleFonts.dancingScript(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      signatureImage = null;
                                      signatureBytes = null;
                                      hasNfcSignature = false;
                                      showSignaturePad = true;
                                    });
                                  },
                                  child: getSignatureImageWidget(),
                                ),
                              ),
                            ],
                          )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  signatureImage = null;
                                  signatureBytes = null;
                                  showSignaturePad = true;
                                });
                              },
                              child: getSignatureImageWidget(),
                            ),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (signatureImage != null || signatureBytes != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            File file;
                            // Vérifier quel type de données nous avons
                            if (hasNfcSignature) {
                              if (SharedData.signatureData is String) {
                                // Cas où signatureData est une chaîne base64
                                file = await convertBase64ToFile(
                                    SharedData.signatureData as String,
                                    'signature.png');
                              } else if (SharedData.signatureData
                                  is Uint8List) {
                                // Cas où signatureData est un Uint8List
                                file = await convertUint8ListToFile(
                                    SharedData.signatureData as Uint8List,
                                    'signature.png');
                              } else {
                                throw Exception(
                                    "Type de signature non pris en charge");
                              }
                            } else if (signatureImage != null) {
                              // Cas où nous avons une signature dessinée
                              file = await convertBase64ToFile(
                                  signatureImage!, 'signature.png');
                            } else {
                              throw Exception("Aucune signature disponible");
                            }

                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? demandeIdStr =
                                prefs.getString('demande_id');
                            int? demandeId = demandeIdStr != null
                                ? int.parse(demandeIdStr)
                                : null;

                            if (demandeId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Erreur: ID de demande non trouvé')),
                              );
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }

                            await ApiService.uploadSignature(file, demandeId);
                            SharedData.signatureData = null;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FaceDetectionScreen(
                                    imageBytes: widget.imageBytes),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Erreur lors de l'upload : $e")),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLoading ? Colors.grey : const Color(0xFF024DA2),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isLoading ? 'Envoi en cours...' : 'Continuer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      // Signature Pad Dialog
      bottomSheet: showSignaturePad
          ? Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text('Votre signature'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          showSignaturePad = false;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Signature(
                      controller: _controller,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            _controller.clear();
                          },
                          icon: const Icon(Icons.cleaning_services_rounded),
                          tooltip: 'Effacer',
                          iconSize: 32,
                          color: Colors.red,
                        ),
                        IconButton(
                          onPressed: () async {
                            if (_controller.isNotEmpty) {
                              final signature = await _controller.toPngBytes();
                              if (signature != null) {
                                setState(() {
                                  signatureBytes = signature;
                                  signatureImage =
                                      'data:image/png;base64,${base64Encode(signature)}';
                                  showSignaturePad = false;
                                  hasNfcSignature =
                                      false; // Marquer comme signature dessinée
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.check_circle),
                          tooltip: 'Valider',
                          iconSize: 32,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

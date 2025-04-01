import 'dart:typed_data';
import 'dart:async';
import 'package:dmrtd/dmrtd.dart';
import 'package:flutter/material.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';
import 'mrz.dart';
import 'nfcheader.dart';
import 'explicationmrz.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Scanner votre carte d'identité",
      theme: ThemeData(
        primaryColor: const Color(0xFF003366), // Bleu Fransabank
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF6699CC), // Bleu clair
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366), // Bleu foncé
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003366), // Bleu foncé
            foregroundColor: Colors.white, // Texte blanc
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            elevation: 5,
          ),
        ),
      ),
      home: const SecondPage(),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> with TickerProviderStateMixin {
  Uint8List? image, signature;
  String data = "";
  List<String>? mrzLines;
  Map<String, String>? mrzData;
  EfDG11? dg11;
  EfDG12? dg12;
  String? numeroIdentite;
  late AnimationController _controller;
  late AnimationController _buttonController;
  late Animation<double> _scaleAnimation;
  bool showExplanation = true;
  final _scanProgressController = StreamController<int>.broadcast();
  bool _isScanning = false;
  bool showResults = false;
  BuildContext? _dialogContext;

  String _getExplanationText() {
    if (mrzLines == null) {
      return "Commencez par scanner le MRZ de votre carte d'identité.";
    } else if (mrzData != null && !showResults) {
      return "✅ L'extraction est terminée avec succès ! Appuyez sur 'Voir les résultats' pour consulter les informations de votre carte.";
    } else {
      return "";  // On retourne une chaîne vide car on utilise _buildInstructionStep
    }
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5, right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF003366),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF003366),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {  
        _dialogContext = dialogContext;
        return WillPopScope(
          onWillPop: () async => false,  // Empêche le retour arrière
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Erreur de lecture'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                SizedBox(height: 16),
                Text(
                  '💡 Conseils :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Gardez la carte immobile'),
                Text('• Vérifiez la position du lecteur NFC'),
                Text('• Réessayez avec un mouvement plus lent'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _closeDialogs();
                  setState(() {
                    _isScanning = false;
                    showExplanation = true;
                  });
                },
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  _closeDialogs();
                  setState(() {
                    _isScanning = true;
                    showResults = false;
                    _updateProgress(0);
                  });
                  _showProgressDialog(context);
                  read();
                },
                child: Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF003366),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {  
        _dialogContext = dialogContext;
        return WillPopScope(
          onWillPop: () async => false,  // Empêche le retour arrière
          child: StreamBuilder<int>(
            stream: _scanProgressController.stream,
            initialData: 0,
            builder: (context, snapshot) {
              int progress = snapshot.data ?? 0;
              String statusText = 'Veuillez maintenir votre carte...';
              switch (progress) {
                case 1:
                  statusText = 'Lecture MRZ...';
                  break;
                case 2:
                  statusText = 'Connexion NFC...';
                  break;
                case 3:
                  statusText = 'Extraction photo...';
                  break;
                case 4:
                  statusText = 'Extraction signature...';
                  break;
                case 5:
                  statusText = 'Extraction données personnelles...';
                  break;
                case 6:
                  statusText = 'Extraction terminée!';
                  break;
              }
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                content: Container(
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Scan NFC en cours...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          6,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < progress
                                  ? Color(0xFF003366)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: progress == 6 ? Color(0xFF003366) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _closeDialogs() {
    if (_dialogContext != null && Navigator.canPop(_dialogContext!)) {
      Navigator.pop(_dialogContext!);
    }
    _dialogContext = null;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonController.dispose();
    _scanProgressController.close();
    _dialogContext = null;
    super.dispose();
  }

  void _updateProgress(int progress) {
    if (!_scanProgressController.isClosed) {
      _scanProgressController.add(progress);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
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
      onTapDown: isEnabled ? (_) => _buttonController.forward() : null,
      onTapUp: isEnabled ? (_) => _buttonController.reverse() : null,
      onTapCancel: isEnabled ? () => _buttonController.reverse() : null,
      onTap: isEnabled ? onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: width ?? 200,
          height: height ?? 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: [Color(0xFF003366), Color(0xFF001F3F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
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

  Map<String, String> _extractMRZData(List<String> mrz) {
    if (mrz.length < 3) return {};

    String line1 = mrz[0];
    String line2 = mrz[1];
    String line3 = mrz[2];

    Map<String, String> extractedData = {};
    extractedData["Type de document"] = line1.substring(0, 2);
    String nationality = line2.substring(15, 18);
    extractedData["Nationalité"] =
        (nationality == "DZA") ? "Algérienne" : nationality;
    extractedData["Numéro de document"] = line1.substring(5, 14);
    extractedData["Date de naissance"] = _formatDate(line2.substring(0, 6));
    extractedData["Sexe"] = line2.substring(7, 8);
    extractedData["Date d'expiration"] = _formatDate(line2.substring(8, 14));

    List<String> nameParts = line3.split("<<");
    extractedData["Nom"] = nameParts[0].replaceAll('<', ' ');
    extractedData["Prénom"] =
        nameParts.length > 1 ? nameParts[1].replaceAll('<', ' ') : '';

    return extractedData;
  }

  String _formatDate(String dateYYMMDD) {
    int yearPrefix = int.parse(dateYYMMDD.substring(0, 2)) >= 40 ? 19 : 20;
    String year = "$yearPrefix${dateYYMMDD.substring(0, 2)}";
    String month = dateYYMMDD.substring(2, 4);
    String day = dateYYMMDD.substring(4, 6);

    return "$day/$month/$year";
  }

  String bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  Future<void> read() async {
    if (mrzLines != null) {
      try {
        _updateProgress(1);
        print("Tentative de parsing MRZ avec les lignes :");
        mrzLines!.forEach((line) => print(line));

        final result = MRZParser.tryParse(mrzLines!);
        if (result == null) {
          print("Erreur : Le parsing MRZ a échoué");
          setState(() {
            data = "Erreur : Format MRZ invalide";
            Navigator.of(context).pop(); // Close progress dialog
          });
          return;
        }
        _updateProgress(2);
        print("Parsing MRZ réussi :");
        print("Document Number: ${result.documentNumber}");
        print("Birth Date: ${result.birthDate}");
        print("Expiry Date: ${result.expiryDate}");

        beginToScan(result);
      } catch (e) {
        print("Erreur lors du parsing MRZ : $e");
        setState(() {
          data = "Erreur lors du parsing MRZ : $e";
          Navigator.of(context).pop(); // Close progress dialog
        });
      }
    } else {
      setState(() {
        data = "Veuillez d'abord scanner le MRZ";
        Navigator.of(context).pop(); // Close progress dialog
      });
    }
  }

  void beginToScan(MRZResult result) async {
    final nfc = NfcProvider();
    try {
      print("Tentative de connexion NFC...");
      await nfc.connect(timeout: Duration(seconds: 30));
      print("Connexion NFC établie");
      _updateProgress(3);

      final passport = Passport(nfc);
      final bacKeySeed = DBAKey(
        result.documentNumber,
        result.birthDate,
        result.expiryDate,
      );

      try {
        await passport.startSession(bacKeySeed);
        print("Session BAC établie");
      } catch (e) {
        print("Échec du BAC : $e");
        if (mounted) {
          Navigator.of(context).pop(); // Ferme la boîte de dialogue de progression
          _showErrorDialog(
            "La connexion avec la carte a été perdue. Veuillez maintenir la carte immobile et réessayer."
          );
        }
        return;
      }

      print("Lecture des données...");
      try {
        final efcom = await passport.readEfCOM();
        print("EF.COM lu avec succès");
      } catch (e) {
        print("Erreur lors de la lecture de EF.COM : $e");
        if (mounted) {
          Navigator.of(context).pop(); // Ferme la boîte de dialogue de progression
          _showErrorDialog(
            "Erreur lors de la lecture des données. La carte a peut-être bougé, veuillez réessayer en la maintenant bien immobile."
          );
        }
        return;
      }

      try {
        final dg1 = await passport.readEfDG1();
        print("DG1 lu avec succès");
      } catch (e) {
        print("Erreur lors de la lecture de DG1 : $e");
        if (mounted) {
          Navigator.of(context).pop(); // Ferme la boîte de dialogue de progression
          _showErrorDialog(
            "La lecture a été interrompue. Assurez-vous que la carte reste bien en contact avec le lecteur NFC."
          );
        }
        return;
      }

      try {
        final dg2 = await passport.readEfDG2();
        print("DG2 lu avec succès");
        if (dg2 != null) {
          setState(() {
            image = resizeImage(dg2.imageData, width: 120, height: 120);
          });
        }
      } catch (e) {
        print("Erreur lors de la lecture de DG2 : $e");
        if (mounted) {
          Navigator.of(context).pop(); // Ferme la boîte de dialogue de progression
          _showErrorDialog(
            "Impossible de lire la photo. Veuillez réessayer en gardant la carte parfaitement immobile."
          );
        }
        return;
      }

      _updateProgress(4);
      try {
        final dg7 = await passport.readEfDG7();
        print("DG7 lu avec succès");
        setState(() {
          signature = resizeImage(
            extractJPEG(dg7.toBytes()),
            width: 120,
            height: 120,
          );
        });
      } catch (e) {
        print("Erreur lors de la lecture de DG7 : $e");
        if (mounted) {
          Navigator.of(context).pop(); // Ferme la boîte de dialogue de progression
          _showErrorDialog(
            "Erreur lors de la lecture de la signature. Veuillez réessayer en maintenant la carte stable."
          );
        }
        return;
      }

      _updateProgress(5);
      try {
        print("⏳ Tentative de lecture du Personal Number...");
        final personalNumber = await passport.readPersonalNumber();

        if (personalNumber != null && personalNumber.isNotEmpty) {
          print("✅ Numéro d'identité : $personalNumber");
          setState(() {
            this.numeroIdentite = personalNumber;
          });
        } else {
          print("❌ Le Personal Number est vide ou non disponible.");
        }
      } catch (e, stackTrace) {
        print("❌ Erreur lors de la lecture du Personal Number : $e");
        print("StackTrace : $stackTrace");
        if (mounted) {
          Navigator.of(context).pop(); // Ferme la boîte de dialogue de progression
          _showErrorDialog(
            "Erreur lors de la lecture du numéro personnel. Veuillez réessayer."
          );
        }
        return;
      }

      _updateProgress(6);
      setState(() {
        mrzData = _extractMRZData(mrzLines!);
        data = "Lecture terminée avec succès";
      });

      await Future.delayed(Duration(seconds: 1)); // Show completed state
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        setState(() {
          showExplanation = true;
          _isScanning = false;
          showResults = false;
        });
      }

    } catch (e) {
      print("Erreur lors de la lecture NFC : $e");
      if (mounted) {
        Navigator.of(context).pop(); // Ferme la boîte de dialogue de progression
        _showErrorDialog(
          "Une erreur est survenue lors de la lecture. Assurez-vous que votre carte est bien positionnée et réessayez."
        );
      }
    } finally {
      await nfc.disconnect();
    }
  }

  Uint8List extractJPEG(Uint8List data) {
    int start = data.indexOf(0xFF);
    while (start != -1 && start < data.length - 1) {
      if (data[start] == 0xFF && data[start + 1] == 0xD8) {
        break;
      }
      start = data.indexOf(0xFF, start + 1);
    }
    if (start == -1) {
      throw Exception("Impossible de trouver une image JPEG valide");
    }
    return data.sublist(start);
  }

  Uint8List resizeImage(
    Uint8List? imageData, {
    int width = 100,
    int height = 50,
  }) {
    if (imageData == null) return Uint8List(0);
    img.Image? image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception("Impossible de décoder l'image");
    }
    img.Image resized = img.copyResize(image, width: width, height: height);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isScanning) {
          return false; // Empêche le retour arrière pendant le scan
        }
        return true; // Permet le retour arrière dans les autres cas
      },
      child: CurvedHeader(
        title: "Scanner NFC",
        onBackPressed: () {
          if (!_isScanning) {
            Navigator.pop(context);
          }
        },
        backgroundColor: const Color(0xFF003366),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (!showResults) ...[
                // NFC Animation
                Container(
                  height: 200,
                  child: Lottie.asset(
                    'assets/images/nfc.json',
                    controller: _controller,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Explanation Bubble
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
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: mrzLines != null && mrzData == null ? Column(
                    children: [
                      Text(
                        "Instructions :",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInstructionStep("Localisez le lecteur NFC (près des caméras)"),
                      _buildInstructionStep("Alignez votre carte avec le lecteur"),
                      _buildInstructionStep("Appuyez sur 'Scanner NFC' et restez immobile"),
                    ],
                  ) : Text(
                    _getExplanationText(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF003366),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),
                
                // Buttons
                Column(
                  children: [
                    _buildModernButton(
                      text: "Scanner MRZ",
                      icon: Icons.camera_alt,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MRZGuidePage(),
                          ),
                        );
                        if (result != null && mounted) {
                          setState(() {
                            mrzLines = result as List<String>;
                            showResults = false;
                            showExplanation = true;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModernButton(
                      text: "Scanner NFC",
                      icon: Icons.nfc,
                      isEnabled: mrzLines != null,
                      onPressed: () async {
                        setState(() {
                          _isScanning = true;
                          showResults = false;
                          _updateProgress(0);
                        });
                        _showProgressDialog(context);
                        await read();
                      },
                    ),
                  ],
                ),

                if (mrzData != null) ...[
                  const SizedBox(height: 30),
                  _buildModernButton(
                    text: "Voir les résultats",
                    icon: Icons.visibility,
                    onPressed: () {
                      setState(() {
                        showResults = true;
                      });
                    },
                  ),
                ],
              ],

              if (showResults) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModernButton(
                      text: "Nouveau scan",
                      icon: Icons.refresh,
                      onPressed: () {
                        setState(() {
                          showResults = false;
                          showExplanation = true;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                if (mrzData != null)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Informations Personnelles",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow("Nom", mrzData!["Nom"] ?? ""),
                          _buildInfoRow("Prénom", mrzData!["Prénom"] ?? ""),
                          _buildInfoRow(
                            "Date de naissance",
                            mrzData!["Date de naissance"] ?? "",
                          ),
                          _buildInfoRow("Genre", mrzData!["Sexe"] ?? ""),
                          _buildInfoRow("Nationalité", mrzData!["Nationalité"] ?? ""),
                          _buildInfoRow(
                            "Numéro de document",
                            mrzData!["Numéro de document"] ?? "",
                          ),
                          _buildInfoRow(
                            "Date d'expiration",
                            mrzData!["Date d'expiration"] ?? "",
                          ),
                          if (numeroIdentite != null)
                            _buildInfoRow("NIN", numeroIdentite!),
                        ],
                      ),
                    ),
                  ),

                if (image != null || signature != null)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Photo et Signature",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (image != null)
                                Column(
                                  children: [
                                    Text(
                                      "Photo",
                                      style: TextStyle(color: Color(0xFF003366)),
                                    ),
                                    const SizedBox(height: 5),
                                    Image(image: MemoryImage(image!)),
                                  ],
                                ),
                              if (signature != null)
                                Column(
                                  children: [
                                    Text(
                                      "Signature",
                                      style: TextStyle(color: Color(0xFF003366)),
                                    ),
                                    const SizedBox(height: 5),
                                    Image(image: MemoryImage(signature!)),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                if (mrzLines != null)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Données MRZ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMRZLine("Ligne 1", mrzLines![0]),
                                Divider(height: 16, color: Color(0xFFE0E0E0)),
                                _buildMRZLine("Ligne 2", mrzLines![1]),
                                Divider(height: 16, color: Color(0xFFE0E0E0)),
                                _buildMRZLine("Ligne 3", mrzLines![2]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMRZLine(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 12, 
            color: Color(0xFF003366),
            fontWeight: FontWeight.w600,
            fontFamily: 'Courier',
            letterSpacing: 0.2, 
          ),
        ),
      ],
    );
  }
}

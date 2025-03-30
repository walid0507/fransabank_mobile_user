import 'dart:typed_data';
import 'package:dmrtd/dmrtd.dart';
import 'package:flutter/material.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:image/image.dart' as img;
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

class _SecondPageState extends State<SecondPage> {
  Uint8List? image, signature;
  String data = "";
  List<String>? mrzLines;
  Map<String, String>? mrzData;
  EfDG11? dg11;
  EfDG12? dg12;
  String? numeroIdentite;

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
        print("Tentative de parsing MRZ avec les lignes :");
        mrzLines!.forEach((line) => print(line));

        final result = MRZParser.tryParse(mrzLines!);
        if (result == null) {
          print("Erreur : Le parsing MRZ a échoué");
          setState(() {
            data = "Erreur : Format MRZ invalide";
          });
          return;
        }
        print("Parsing MRZ réussi :");
        print("Document Number: ${result.documentNumber}");
        print("Birth Date: ${result.birthDate}");
        print("Expiry Date: ${result.expiryDate}");

        beginToScan(result);
      } catch (e) {
        print("Erreur lors du parsing MRZ : $e");
        setState(() {
          data = "Erreur lors du parsing MRZ : $e";
        });
      }
    } else {
      setState(() {
        data = "Veuillez d'abord scanner le MRZ";
      });
    }
  }

  void beginToScan(MRZResult result) async {
    setState(() {
      data = "Chargement en cours...";
    });

    final nfc = NfcProvider();
    try {
      print("Tentative de connexion NFC...");
      await nfc.connect(timeout: Duration(seconds: 30));
      print("Connexion NFC établie");

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
        print("Échec du BAC, tentative de reconnexion...");
        await Future.delayed(Duration(seconds: 2));
        return beginToScan(result); // Relance une tentative
      }

      print("Lecture des données...");
      try {
        final efcom = await passport.readEfCOM();
        print("EF.COM lu avec succès");
      } catch (e) {
        print("Erreur lors de la lecture de EF.COM : $e");
      }

      try {
        final dg1 = await passport.readEfDG1();
        print("DG1 lu avec succès");
      } catch (e) {
        print("Erreur lors de la lecture de DG1 : $e");
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
      }

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
      }

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
      }

      // try {
      //   dg12 = await passport.readEfDG12();
      //   print("DG12 lu avec succès");
      // } catch (e) {
      //   print("Erreur lors de la lecture de DG12 : $e");
      //   setState(() {
      //     data =
      //         "Note : Les informations DG12 ne sont pas disponibles sur cette carte";
      //   });
      // }

      setState(() {
        mrzData = _extractMRZData(mrzLines!);
        data = "Lecture terminée avec succès";
      });
    } catch (e) {
      print("Erreur lors de la lecture NFC : $e");
      setState(() {
        data = "Erreur lors de la lecture : $e";
      });
    } finally {
      setState(() {
        data = "";
      });
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
    return CurvedHeader(
      title: "ID Card Scanner",
      onBackPressed: () => Navigator.pop(context),
      backgroundColor: const Color(0xFF003366),
      child: Column(
        children: [
          const SizedBox(height: 20),
          if (mrzData != null) ...[
            Card(
              margin: const EdgeInsets.all(8),
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
                    _buildInfoRow("NIN", numeroIdentite!),
                  ],
                ),
              ),
            ),
          ],
          if (image != null || signature != null)
            Card(
              margin: const EdgeInsets.all(8),
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
              margin: const EdgeInsets.all(8),
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
                    const SizedBox(height: 10),
                    Text("Ligne 1: ${mrzLines![0]}"),
                    Text("Ligne 2: ${mrzLines![1]}"),
                    Text("Ligne 3: ${mrzLines![2]}"),
                  ],
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: mrzLines != null ? read : null,
                icon: const Icon(Icons.nfc),
                label: const Text("Démarrer NFC"),
              ),
              const SizedBox(width: 10),
              // Modifiez le bouton "Démarrer OCR" dans SecondPage
              ElevatedButton.icon(
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
                    });
                    read(); // Lance automatiquement la lecture NFC si besoin
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Démarrer OCR"),
              ),
            ],
          ),
          if (data.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data,
                style: const TextStyle(fontSize: 18, color: Color(0xFF003366)),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
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
}

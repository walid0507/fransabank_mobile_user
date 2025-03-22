import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'header.dart';
import 'main.dart';
import 'package:projet1/configngrok.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'api_service.dart';

class InvertedCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Point de départ
    path.lineTo(0, size.height * 0.90);

    // Première courbe
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.95,
        size.width * 0.25, size.height * 0.95);

    // Deuxième courbe
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.95, size.width, size.height * 0.85);

    // Compléter le chemin
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class Documents extends StatefulWidget {
  const Documents({super.key});

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  // Ajouter les variables d'état pour suivre les uploads
  Map<String, bool> documentStates = {
    "Extrait de naissance": false,
    "Certificat de résidence": false,
    "Facture d'électricité": false,
    "Justificatif de revenus": false,
  };

  // Calculer le progrès total
  double get uploadProgress {
    int uploadedCount =
        documentStates.values.where((uploaded) => uploaded).length;
    return uploadedCount / documentStates.length;
  }

  // Mettre à jour l'état d'un document
  void _updateDocumentState(String documentTitle, bool uploaded) {
    setState(() {
      documentStates[documentTitle] = uploaded;
    });
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
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              children: [
                Text(
                  'Documents Requis',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                // Ajouter la barre de progression
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progression',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${(uploadProgress * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: uploadProgress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView(
                      children: [
                        _buildDocumentButton(
                          "Extrait de naissance",
                          "Télécharger votre extrait de naissance",
                          documentStates["Extrait de naissance"] ?? false,
                        ),
                        SizedBox(height: 15),
                        _buildDocumentButton(
                          "Certificat de résidence",
                          "Télécharger votre certificat de résidence",
                          documentStates["Certificat de résidence"] ?? false,
                        ),
                        SizedBox(height: 15),
                        _buildDocumentButton(
                          "Facture d'électricité",
                          "Télécharger une facture d'électricité récente",
                          documentStates["Facture d'électricité"] ?? false,
                        ),
                        SizedBox(height: 15),
                        _buildDocumentButton(
                          "Justificatif de revenus",
                          "Télécharger votre justificatif de revenus",
                          documentStates["Justificatif de revenus"] ?? false,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (uploadProgress == 1.0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Tous les documents ont été téléversés avec succès !')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Veuillez téléverser tous les documents requis.')),
                        );
                      }
                    },
                    child: Text('Continuer',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentButton(String title, String subtitle, bool isUploaded) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF024DA2),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: isUploaded
            ? Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              )
            : Icon(
                Icons.upload_file,
                color: Color(0xFF024DA2),
                size: 30,
              ),
        onTap: () async {
          // Remplacer la simulation par un vrai upload
          final file =
              await _pickFile(); // Méthode pour sélectionner un fichier
          if (file != null) {
            try {
              // Récupérer le token et l'ID de la demande
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString('access_token');
              String? demandeId = prefs.getString('demande_id');
              String? typeDocumentId = _getTypeDocumentId(
                  title); // Méthode pour mapper le titre au type_document_id

              if (token != null &&
                  demandeId != null &&
                  typeDocumentId != null) {
                await ApiService.uploadDocument(
                  int.parse(demandeId),
                  typeDocumentId,
                  file,
                  token,
                );
                _updateDocumentState(title, true);
              } else {
                throw Exception('Token ou ID de demande manquant');
              }
            } catch (e) {
              print('Erreur lors de l\'upload: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur lors de l\'upload: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<File?> _pickFile() async {
    // Utiliser un package comme file_picker pour sélectionner un fichier
    // Exemple avec file_picker :
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  String _getTypeDocumentId(String title) {
    // Mapper le titre du document à type_document_id
    switch (title) {
      case 'Extrait de naissance':
        return '1'; // Remplace par l'ID réel
      case 'Certificat de résidence':
        return '2'; // Remplace par l'ID réel
      case 'Facture d\'électricité':
        return '3'; // Remplace par l'ID réel
      case 'Justificatif de revenus':
        return '4'; // Remplace par l'ID réel
      default:
        throw Exception('Type de document non reconnu');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ajout de SharedPreferences
import 'dart:convert';
import 'package:projet1/configngrok.dart';
import 'denvoyé.dart';

class CreateAccountStep3 extends StatefulWidget {
  final Map<String, dynamic> formData;

  CreateAccountStep3({required this.formData});

  @override
  _CreateAccountStep3State createState() => _CreateAccountStep3State();
}

class _CreateAccountStep3State extends State<CreateAccountStep3> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? photo;
  File? signature;
  String? address;
  String? countryOfBirth;
  String? employerName;
  String? clientType;

  // Ajout des contrôleurs pour récupérer les valeurs des champs
  final _addressController = TextEditingController();
  final _countryOfBirthController = TextEditingController();
  final _employerNameController = TextEditingController();
  final _clientTypeController = TextEditingController();

  Future<void> _pickImage(bool isPhoto) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isPhoto) {
          photo = File(image.path);
        } else {
          signature = File(image.path);
        }
      });
    }
  }

  Future<String?> _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token'); // Vérification du token
      String? refreshToken = prefs.getString('refresh_token');

      print("Token récupéré depuis SharedPreferences : $token");

      if (token != null) {
        return token; // Retourne le token s'il existe
      }

      if (refreshToken == null) {
        print(
            "Aucun refresh token trouvé, impossible de récupérer un nouveau token.");
        return null;
      }

      // Essayer de rafraîchir le token
      token = await ApiService.refreshToken();
      if (token != null) {
        print("Token rafraîchi avec succès");
        return token;
      } else {
        print("Impossible de rafraîchir le token");
      }

      return null;
    } catch (e) {
      print("Erreur lors de la récupération du token: $e");
      return null;
    }
  }

  void _submitFinal() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? token = await _getToken();
        print("Token utilisé pour la requête : $token");

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Erreur : Token non trouvé. Veuillez vous reconnecter.'),
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  // Rediriger vers la page de connexion
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          );
          return;
        }

        // Afficher les données avant envoi pour debug
        print("FormData existant : ${widget.formData}");

        // Structurer les données selon le modèle Django
        final formDataToSend = {
          ...widget.formData,
          "address": _addressController.text,
          "Pays_naissance": _countryOfBirthController.text,
          "nom_employeur": _employerNameController.text,
          "type_client": _clientTypeController.text == 'Particulier'
              ? 1
              : _clientTypeController.text == 'Entreprise'
                  ? 2
                  : 3,
        };

        print("Données à envoyer : $formDataToSend");

        // Envoyer les données principales
        var response = await ApiService.authenticatedRequest(
            ApiService.baseUrl, 'POST',
            body: formDataToSend);

        print("Code de réponse : ${response.statusCode}");
        print("Corps de la réponse : ${response.body}");

        if (response.statusCode == 201 || response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          int demandeId = responseData["id"];

          // Upload de la photo
          if (photo != null) {
            await ApiService.uploadFile(
                "${ApiService.baseUrl}${demandeId}/upload_photo/",
                photo!,
                token);
          }

          // Upload de la signature
          if (signature != null) {
            await ApiService.uploadFile(
                "${ApiService.baseUrl}${demandeId}/upload_signature/",
                signature!,
                token);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Demande créée avec succès')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DenvoyeScreen(),
            ),
          );
        } else {
          throw Exception(
              'Erreur lors de la création de la demande: ${response.body}');
        }
      } catch (e) {
        print("Erreur détaillée : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la création de la demande: ${e.toString()}'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Étape 3 - Informations complémentaires')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Champ Adresse
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Champ Pays de naissance
                TextFormField(
                  controller: _countryOfBirthController,
                  decoration: InputDecoration(
                    labelText: 'Pays de naissance',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre pays de naissance';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Champ Photo
                Text('Photo', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                photo == null
                    ? ElevatedButton(
                        onPressed: () => _pickImage(true),
                        child: Text('Uploader une photo'),
                      )
                    : Image.file(photo!, height: 100),
                SizedBox(height: 20),

                // Champ Signature
                Text('Signature', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                signature == null
                    ? ElevatedButton(
                        onPressed: () => _pickImage(false),
                        child: Text('Uploader une signature'),
                      )
                    : Image.file(signature!, height: 100),
                SizedBox(height: 20),

                // Champ Nom de l'employeur
                TextFormField(
                  controller: _employerNameController,
                  decoration: InputDecoration(
                    labelText: "Nom de l'employeur",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom de votre employeur';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Champ Type de client
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Type de client',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Particulier', 'Entreprise', 'Autre']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _clientTypeController.text = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner un type de client';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Bouton de soumission
                Center(
                  child: ElevatedButton(
                    onPressed: _submitFinal,
                    child: Text('Soumettre'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

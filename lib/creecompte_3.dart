import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ajout de SharedPreferences

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Récupère le token
    print("Token récupéré depuis SharedPreferences : $token"); // Affiche le token récupéré
    return token;
  }

  void _submitFinal() async {
    if (_formKey.currentState!.validate()) {
      // Récupérer le token depuis SharedPreferences
      String? token = await _getToken();
      print("Token utilisé pour la requête : $token"); // Affiche le token utilisé

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : Token non trouvé. Veuillez vous reconnecter.')),
        );
        return; // Arrête l'exécution si le token est null
      }

      // Ajout des données des champs à formData
      widget.formData.addAll({
        "address": _addressController.text,
        "Pays_naissance": _countryOfBirthController.text,
        "employer_name": _employerNameController.text,
        "client_type": _clientTypeController.text,
      });

      try {
        // Envoyer les données à l'API
        var response = await ApiService.createDemande(widget.formData, token);
        int demandeId = response["id"];

        // Upload de la photo et de la signature si elles existent
        if (photo != null) {
          await ApiService.uploadFile(
              "${ApiService.baseUrl}demandecompte/$demandeId/upload_photo/",
              photo!,
              token);
        }
        if (signature != null) {
          await ApiService.uploadFile(
              "${ApiService.baseUrl}demandecompte/$demandeId/upload_signature/",
              signature!,
              token);
        }

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demande créée avec succès')),
        );
      } catch (e) {
        // Gérer les erreurs
        print("Erreur : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création de la demande')),
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
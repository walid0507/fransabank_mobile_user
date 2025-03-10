import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';

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

  void _submitFinal() async {
    if (_formKey.currentState!.validate()) {
      widget.formData.addAll({
        "address": address,
        "Pays_naissance": countryOfBirth,
      });

      try {
        var response = await ApiService.createDemande(widget.formData, "<TOKEN>");
        int demandeId = response["id"];

        if (photo != null) await ApiService.uploadFile("${ApiService.baseUrl}demandecompte/$demandeId/upload_photo/", photo!, "<TOKEN>");
        if (signature != null) await ApiService.uploadFile("${ApiService.baseUrl}demandecompte/$demandeId/upload_signature/", signature!, "<TOKEN>");
      } catch (e) {
        print("Erreur : $e");
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
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      address = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Pays de naissance',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      countryOfBirth = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre pays de naissance';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text('Photo', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                photo == null
                    ? ElevatedButton(
                        onPressed: () => _pickImage(true),
                        child: Text('Uploader une photo'),
                      )
                    : Image.file(photo!, height: 100),
                SizedBox(height: 20),
                Text('Signature', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                signature == null
                    ? ElevatedButton(
                        onPressed: () => _pickImage(false),
                        child: Text('Uploader une signature'),
                      )
                    : Image.file(signature!, height: 100),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Nom de l'employeur",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      employerName = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom de votre employeur';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Type de client',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Particulier', 'Entreprise', 'Autre'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      clientType = value;
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

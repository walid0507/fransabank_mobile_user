import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ajout de SharedPreferences
import 'dart:convert';
import 'package:projet1/configngrok.dart';
import 'denvoyé.dart';
import 'documents.dart';
import 'curved_header.dart';
import 'creecompte_2.dart'; // Ajout de l'import pour creecompte_2.dart

class CreateAccountStep3 extends StatefulWidget {
  final Map<String, dynamic> formData;

  CreateAccountStep3({required this.formData});

  @override
  _CreateAccountStep3State createState() => _CreateAccountStep3State();
}

class _CreateAccountStep3State extends State<CreateAccountStep3> {
  final _formKey = GlobalKey<FormState>();
  String? address;
  String? countryOfBirth;
  String? employerName;
  String? clientType;

  // Ajout des contrôleurs pour récupérer les valeurs des champs
  final _addressController = TextEditingController();
  final _countryOfBirthController = TextEditingController();
  final _employerNameController = TextEditingController();
  final _clientTypeController = TextEditingController();

  bool _areFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_checkFields);
    _countryOfBirthController.addListener(_checkFields);
    _employerNameController.addListener(_checkFields);
    _clientTypeController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _addressController.removeListener(_checkFields);
    _countryOfBirthController.removeListener(_checkFields);
    _employerNameController.removeListener(_checkFields);
    _clientTypeController.removeListener(_checkFields);
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      _areFieldsFilled = _addressController.text.isNotEmpty &&
          _countryOfBirthController.text.isNotEmpty &&
          _employerNameController.text.isNotEmpty &&
          _clientTypeController.text.isNotEmpty;
    });
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
        final Map<String, int> clientTypeMap = {
          'Étudiant': 1,
          'Commerçant': 2,
          'Professionnel': 3,
          'Personnel': 4,
          'Jeune/Enfant': 5,
        };

        final formDataToSend = {
          ...widget.formData,
          "address": _addressController.text,
          "Pays_naissance": _countryOfBirthController.text,
          "nom_employeur": _employerNameController.text,
          "type_client": clientTypeMap[_clientTypeController.text] ?? null,
        };

        print("Données à envoyer : $formDataToSend");

        // Modification ici : Ajouter une gestion d'erreur plus robuste
        try {
          var response = await ApiService.authenticatedRequest(
              ApiService.baseUrl, 'POST',
              body: formDataToSend);

          print("Code de réponse : ${response.statusCode}");
          print("Corps de la réponse : ${response.body}");

          if (response.statusCode == 201 || response.statusCode == 200) {
            var responseData = jsonDecode(response.body);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('demande_id', responseData['id'].toString());

            // Upload de la photo
            // if (photo != null) {
            //   await ApiService.uploadFile(
            //       "${ApiService.baseUrl}${demandeId}/upload_photo/",
            //       photo!,
            //       token);
            // }

            // // Upload de la signature
            // if (signature != null) {
            //   await ApiService.uploadFile(
            //       "${ApiService.baseUrl}${demandeId}/upload_signature/",
            //       signature!,
            //       token);
            // }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Demande créée avec succès')),
            );

            // Naviguer vers Documents même en cas d'échec d'upload des fichiers
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Documents(),
              ),
            );
          } else {
            throw Exception('Erreur serveur: ${response.statusCode}');
          }
        } catch (networkError) {
          print("Erreur réseau : $networkError");
          // Naviguer vers Documents même en cas d'erreur réseau
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Documents(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Problème de connexion, mais vous pouvez continuer'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        print("Erreur détaillée : $e");
        // Naviguer vers Documents même en cas d'erreur générale
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Documents(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Une erreur est survenue, mais vous pouvez continuer'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CurvedHeader(
            height: 0.9,
            title: 'Demande compte bancaire',
            onBackPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreateAccountStep2(
                  civility: widget.formData['civilité'] == 'Mr'
                      ? 'Monsieur'
                      : 'Madame',
                  formData: widget.formData,
                ),
              ),
            ),
            child: Container(),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 60),
                const Text(
                  'Informations professionnelles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField('Adresse', _addressController),
                              _buildTextField('Pays de naissance',
                                  _countryOfBirthController),
                              _buildTextField('Nom de l\'employeur',
                                  _employerNameController),
                              _buildDropdownField('Type de client', [
                                'Étudiant',
                                'Commerçant',
                                'Professionnel',
                                'Personnel',
                                'Jeune/Enfant'
                              ], (value) {
                                setState(() {
                                  _clientTypeController.text = value!;
                                });
                              }),
                              SizedBox(height: 20),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: _areFieldsFilled ? 1.0 : 0.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed:
                                        _areFieldsFilled ? _submitFinal : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Soumettre',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez remplir ce champ';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items.map((String value) {
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
            return 'Veuillez sélectionner un $label';
          }
          return null;
        },
      ),
    );
  }
}

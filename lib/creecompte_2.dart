import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'dart:convert';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  String? gender;

  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController dateNaissanceController = TextEditingController();
  TextEditingController lieuNaissanceController = TextEditingController();
  TextEditingController numIdentiteController = TextEditingController();

  Future<void> _scanNFC() async {
    try {
      NFCTag tag = await FlutterNfcKit.poll();

      // Exemple de commande APDU pour sélectionner une application (à adapter selon la carte)
      String response =
          await FlutterNfcKit.transceive("00A4040007A0000002471001");
      print("Réponse APDU: $response");

      // Exemple de lecture d'un fichier spécifique sur la carte (à adapter selon la structure)
      String dataResponse = await FlutterNfcKit.transceive("00B000000A");
      print("Données brutes: $dataResponse");

      // Décodage des données (à adapter en fonction du format réel)
      Map<String, String> parsedData = _parseCardData(dataResponse);

      setState(() {
        nomController.text = parsedData['nom'] ?? '';
        prenomController.text = parsedData['prenom'] ?? '';
        dateNaissanceController.text = parsedData['date_naissance'] ?? '';
        lieuNaissanceController.text = parsedData['lieu_naissance'] ?? '';
        numIdentiteController.text = parsedData['num_identite'] ?? '';
        gender = parsedData['sexe'] == 'M' ? 'Homme' : 'Femme';
      });
    } catch (e) {
      print('Erreur de lecture NFC : $e');
    }
  }

  Map<String, String> _parseCardData(String data) {
    // Simuler un parsing des données (à remplacer par un vrai décodeur selon le format de la carte)
    return {
      'nom': 'Doe',
      'prenom': 'John',
      'date_naissance': '01/01/1990',
      'lieu_naissance': 'Alger',
      'num_identite': '123456789',
      'sexe': 'M'
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/logofransabank.jpg',
          width: 250,
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 90),
                  _buildTextField('Nom', nomController),
                  _buildTextField('Prénom', prenomController),
                  _buildTextField('Date de naissance', dateNaissanceController),
                  _buildTextField('Lieu de naissance', lieuNaissanceController),
                  _buildDropdownField('Sexe', ['Homme', 'Femme'], (value) {
                    setState(() {
                      gender = value;
                    });
                  }),
                  _buildTextField(
                      "Numéro d'identité nationale", numIdentiteController),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _scanNFC,
                      child: Text('Scanner la carte NFC'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: gender,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null ? 'Veuillez sélectionner une option' : null,
      ),
    );
  }
}

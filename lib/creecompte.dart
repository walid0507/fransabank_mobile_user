import 'package:flutter/material.dart';
import 'header2.dart'; // Importation du header commun
import 'creecompte_2.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String? accountType;
  String? familyStatus;

  void _navigateToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAccount()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonHeader(
      title: 'Créer un compte',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 90),
                _buildTextField('Numéro de téléphone'),
                _buildTextField('Email'),
                _buildTextField('Adresse postale complète'),
                _buildDropdownField(
                    'Type de compte', ['Courant', 'Épargne', 'Jeune'],
                    (value) {
                  setState(() {
                    accountType = value;
                  });
                }),
                _buildTextField('Profession'),
                _buildTextField('Revenus'),
                _buildTextField('Salaire'),
                _buildDropdownField('Situation familiale',
                    ['Célibataire', 'Marié(e)', 'Divorcé(e)'], (value) {
                  setState(() {
                    familyStatus = value;
                  });
                }),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _navigateToCreateAccount();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Informations personnelles',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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
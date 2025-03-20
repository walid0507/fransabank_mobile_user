import 'package:flutter/material.dart';
import 'creecompte_3.dart';
import 'fatca_page.dart'; // Assurez-vous que cette importation est correcte
import 'package:projet1/configngrok.dart';

class CreateAccountStep2 extends StatefulWidget {
  final String? civility;
  final Map<String, dynamic> formData;

  CreateAccountStep2({required this.civility, required this.formData});

  @override
  _CreateAccountStep2State createState() => _CreateAccountStep2State();
}

class _CreateAccountStep2State extends State<CreateAccountStep2> {
  final _formKey = GlobalKey<FormState>();
  String? nationality1;
  String? nationality2;
  String? situationFamiliale;

  // Ajout des contrôleurs pour récupérer les valeurs des champs
  final _fatherFirstNameController = TextEditingController();
  final _motherLastNameController = TextEditingController();
  final _motherFirstNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _maidenNameController = TextEditingController();

  void _navigateToNextPage() {
    if (_formKey.currentState!.validate()) {
      widget.formData.addAll({
        "Prénom_pere": _fatherFirstNameController.text,
        "Nom_mere": _motherLastNameController.text,
        "Prénom_mere": _motherFirstNameController.text,
        "phone_number": _phoneNumberController.text,
        "Nationalité": nationality1,
        "Nationalité2": nationality2,
        "Nom_jeune_fille": _maidenNameController.text,
        "situation_familliale":
            situationFamiliale, // ✅ Ajout de la situation familiale
      });

      if (nationality1 == 'Américaine' || nationality2 == 'Américaine') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FatcaPage(formData: widget.formData)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CreateAccountStep3(formData: widget.formData)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Informations complémentaires')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.civility == 'Madame')
                  _buildTextField('Nom de jeune fille', _maidenNameController),
                _buildTextField('Prénom du père', _fatherFirstNameController),
                _buildTextField('Nom de la mère', _motherLastNameController),
                _buildTextField(
                    'Prénom de la mère', _motherFirstNameController),
                _buildTextField('Numéro de téléphone', _phoneNumberController),
                _buildDropdownField(
                    'Nationalité 1', ['Française', 'Américaine', 'Autre'],
                    (value) {
                  setState(() {
                    nationality1 = value;
                  });
                }),
                _buildDropdownField('Nationalité 2',
                    ['Aucune', 'Française', 'Américaine', 'Autre'], (value) {
                  setState(() {
                    nationality2 = value;
                  });
                }),
                _buildDropdownField('Situation familiale',
                    ['Célibataire', 'Marié(e)', 'Divorcé(e)'], (value) {setState(() {
    situationFamiliale = value; 
  });}),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _navigateToNextPage,
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
                      'Suivant',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

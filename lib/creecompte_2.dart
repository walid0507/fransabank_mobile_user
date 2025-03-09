import 'package:flutter/material.dart';
import 'creecompte_3.dart';
import 'fatca_page.dart';

class CreateAccountStep2 extends StatefulWidget {
  final String? civility;

  CreateAccountStep2({required this.civility});

  @override
  _CreateAccountStep2State createState() => _CreateAccountStep2State();
}

class _CreateAccountStep2State extends State<CreateAccountStep2> {
  final _formKey = GlobalKey<FormState>();
  String? nationality1;
  String? nationality2;

  void _navigateToNextPage() {
    if (nationality1 == 'Américaine' || nationality2 == 'Américaine') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FatcaPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateAccountStep3()),
      );
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
                  _buildTextField('Nom de jeune fille'),
                _buildTextField('Prénom du père'),
                _buildTextField('Nom de la mère'),
                _buildTextField('Prénom de la mère'),
                _buildTextField('Numéro de téléphone'),
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
                    ['Célibataire', 'Marié(e)', 'Divorcé(e)'], (value) {}),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _navigateToNextPage();
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

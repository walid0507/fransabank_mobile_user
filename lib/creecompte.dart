import 'package:flutter/material.dart';
import 'header2.dart'; // Importation du header commun
import 'creecompte_2.dart';
import 'package:intl/intl.dart';
import 'package:projet1/configngrok.dart';
class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String? civility;
  String? selectedDate;
  final Map<String, dynamic> formData = {}; // Stocke les infos à envoyer à l'API

  // Ajout des contrôleurs pour récupérer les valeurs des champs
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _idNumberController = TextEditingController();

  void _navigateToNextPage() {
    if (_formKey.currentState!.validate()) {
      Map<String, String> civiliteMap = {
  "Monsieur": "Mr",
  "Madame": "Mme"
};

formData["civilité"] = civiliteMap[civility] ?? "";

      formData["first_name"] = _firstNameController.text; // Récupérer la valeur du champ Prénom
      formData["last_name"] = _lastNameController.text; // Récupérer la valeur du champ Nom
      formData["date_of_birth"] = selectedDate;
      formData["lieu_denaissance"] = _birthPlaceController.text; // Récupérer la valeur du champ Lieu de naissance
      formData["numero_identite"] = _idNumberController.text; // Récupérer la valeur du champ Numéro ID

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccountStep2(
            civility: civility ?? "",
            formData: formData,
          ),
        ),
      );
    }
  }

  void _uploadCard() {
    // Logique pour uploader la carte
    print("Upload de la carte en cours...");
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonHeader(
      title: 'Créer un compte',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 90),
              _buildDropdownField('Civilité', ['Monsieur', 'Madame'], (value) {
                setState(() {
                  civility = value;
                });
              }),
              _buildTextField('Prénom', _firstNameController),
              _buildTextField('Nom', _lastNameController),
              _buildDateField('Date de naissance'),
              _buildTextField('Lieu de naissance', _birthPlaceController),
              _buildTextField('Numéro de la carte nationale', _idNumberController),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _uploadCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Uploader la carte',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _navigateToNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Suivant',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildDateField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                selectedDate ?? 'Sélectionnez une date',
                style: TextStyle(fontSize: 16),
              ),
              Icon(Icons.calendar_today, color: Colors.blue.shade700),
            ],
          ),
        ),
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
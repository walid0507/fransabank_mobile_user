import 'package:flutter/material.dart';
import 'header2.dart'; // Importation du header commun
import 'creecompte_2.dart';
import 'package:intl/intl.dart';
import 'package:projet1/configngrok.dart';
import 'curved_header.dart'; // Ajoutez cette importation en haut du fichier

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String? civility;
  String? selectedDate;
  final Map<String, dynamic> formData =
      {}; // Stocke les infos à envoyer à l'API

  // Ajout des contrôleurs pour récupérer les valeurs des champs
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _idNumberController = TextEditingController();

  bool _areFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_checkFields);
    _lastNameController.addListener(_checkFields);
    _birthPlaceController.addListener(_checkFields);
    _idNumberController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_checkFields);
    _lastNameController.removeListener(_checkFields);
    _birthPlaceController.removeListener(_checkFields);
    _idNumberController.removeListener(_checkFields);
    super.dispose();
  }

  void _checkFields() {
    if (!mounted) return; // Vérifier si le widget est toujours monté

    setState(() {
      _areFieldsFilled = civility != null &&
          _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          selectedDate != null &&
          _birthPlaceController.text.isNotEmpty &&
          _idNumberController.text.isNotEmpty;
    });
  }

  void _navigateToNextPage() {
    if (_formKey.currentState!.validate()) {
      Map<String, String> civiliteMap = {"Monsieur": "Mr", "Madame": "Mme"};

      formData["civilité"] = civiliteMap[civility] ?? "";

      formData["first_name"] =
          _firstNameController.text; // Récupérer la valeur du champ Prénom
      formData["last_name"] =
          _lastNameController.text; // Récupérer la valeur du champ Nom
      formData["date_of_birth"] = selectedDate;
      formData["lieu_denaissance"] = _birthPlaceController
          .text; // Récupérer la valeur du champ Lieu de naissance
      formData["numero_identite"] =
          _idNumberController.text; // Récupérer la valeur du champ Numéro ID

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
        _checkFields(); // Ajouter cette ligne
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CurvedHeader(
            height: 0.3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Demande compte bancaire',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height:
                              100), // Ajustez cette valeur selon vos besoins
                      Container(
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
                        child: Column(
                          children: [
                            _buildDropdownField(
                                'Civilité', ['Monsieur', 'Madame'], (value) {
                              setState(() {
                                civility = value;
                                _checkFields(); // Ajouter cette ligne
                              });
                            }),
                            _buildTextField('Prénom', _firstNameController),
                            _buildTextField('Nom', _lastNameController),
                            _buildDateField('Date de naissance'),
                            _buildTextField(
                                'Lieu de naissance', _birthPlaceController),
                            _buildTextField('Numéro de la carte nationale',
                                _idNumberController),
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
                                  onPressed: _areFieldsFilled
                                      ? _navigateToNextPage
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Suivant',
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        onChanged: (value) => _checkFields(), // Ajouter cette ligne
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade600),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
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
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey.shade600),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                selectedDate ?? 'Sélectionnez une date',
                style: TextStyle(fontSize: 16),
              ),
              Icon(Icons.calendar_today, color: Colors.blue.shade600, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade600),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
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

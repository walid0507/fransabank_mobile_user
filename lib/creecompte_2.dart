import 'package:flutter/material.dart';
import 'creecompte_3.dart';
import 'fatca_page.dart'; // Assurez-vous que cette importation est correcte
import 'package:projet1/configngrok.dart';
import 'curved_header.dart';
import 'creecompte.dart'; // Ajout de l'import pour creecompte.dart

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

  bool _areFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _fatherFirstNameController.addListener(_checkFields);
    _motherLastNameController.addListener(_checkFields);
    _motherFirstNameController.addListener(_checkFields);
    _phoneNumberController.addListener(_checkFields);

    if (widget.civility == 'Madame') {
      _maidenNameController.addListener(_checkFields);
    }
  }

  @override
  void dispose() {
    _fatherFirstNameController.removeListener(_checkFields);
    _motherLastNameController.removeListener(_checkFields);
    _motherFirstNameController.removeListener(_checkFields);
    _phoneNumberController.removeListener(_checkFields);
    if (widget.civility == 'Madame') {
      _maidenNameController.removeListener(_checkFields);
    }
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      _areFieldsFilled = _fatherFirstNameController.text.isNotEmpty &&
          _motherLastNameController.text.isNotEmpty &&
          _motherFirstNameController.text.isNotEmpty &&
          _phoneNumberController.text.isNotEmpty &&
          nationality1 != null &&
          nationality2 != null &&
          situationFamiliale != null &&
          (widget.civility != 'Madame' ||
              _maidenNameController.text.isNotEmpty);
    });
  }

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
      body: Stack(
        children: [
          CurvedHeader(
            height: 0.9,
            title: 'Demande compte bancaire',
            onBackPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreateAccountScreen(),
              ),
            ),
            child: Container(),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 60),
                const Text(
                  'Informations familiales',
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
                              if (widget.civility == 'Madame')
                                _buildTextField('Nom de jeune fille',
                                    _maidenNameController),
                              _buildTextField(
                                  'Prénom du père', _fatherFirstNameController),
                              _buildTextField(
                                  'Nom de la mère', _motherLastNameController),
                              _buildTextField('Prénom de la mère',
                                  _motherFirstNameController),
                              _buildTextField('Numéro de téléphone',
                                  _phoneNumberController),
                              _buildDropdownField('Nationalité 1', [
                                'Française',
                                'Américaine',
                                'Autre'
                              ], (value) {
                                setState(() {
                                  nationality1 = value;
                                  _checkFields();
                                });
                              }),
                              _buildDropdownField('Nationalité 2', [
                                'Aucune',
                                'Française',
                                'Américaine',
                                'Autre'
                              ], (value) {
                                setState(() {
                                  nationality2 = value;
                                  _checkFields();
                                });
                              }),
                              _buildDropdownField('Situation familiale', [
                                'Célibataire',
                                'Marié(e)',
                                'Divorcé(e)'
                              ], (value) {
                                setState(() {
                                  situationFamiliale = value;
                                 _checkFields();
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

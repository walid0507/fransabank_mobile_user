import 'package:flutter/material.dart';
import 'header2.dart'; // Importation du header commun
import 'creecompte_2.dart';
import 'package:intl/intl.dart';
import 'package:projet1/configngrok.dart';
import 'curved_header.dart';
import 'second_page.dart'; // Ajout de l'import pour SecondPage

class CreateAccountScreen extends StatefulWidget {
  final Map<String, String>? prefillData;
  final bool readOnly;

  const CreateAccountScreen({
    Key? key, 
    this.prefillData,
    this.readOnly = false,
  }) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  // Ajout du mixin pour l'animation
  final _formKey = GlobalKey<FormState>();
  String? civility;
  String? selectedDate;
  final Map<String, dynamic> formData = {};

  // Ajout des contrôleurs pour récupérer les valeurs des champs
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _idNumberController = TextEditingController();
  final _NINController = TextEditingController();
  final _expController = TextEditingController();

  bool _areFieldsFilled = false;

  // Ajout du contrôleur d'animation
  late AnimationController _nfcButtonController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_checkFields);
    _lastNameController.addListener(_checkFields);
   
    _idNumberController.addListener(_checkFields);

    if (widget.prefillData != null) {
      _firstNameController.text = widget.prefillData!['firstName'] ?? '';
      _lastNameController.text = widget.prefillData!['lastName'] ?? '';
      _idNumberController.text = widget.prefillData!['documentNumber'] ?? '';
      _NINController.text = widget.prefillData!['nin'] ?? '';
      _expController.text = widget.prefillData!['expiryDate'] ?? '';
      selectedDate = widget.prefillData!['dateOfBirth'];
      civility = widget.prefillData!['gender'];
    }

    // Initialisation de l'animation
    _nfcButtonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _nfcButtonController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_checkFields);
    _lastNameController.removeListener(_checkFields);
   
    _idNumberController.removeListener(_checkFields);
    _nfcButtonController.dispose(); // Libérer les ressources de l'animation
    super.dispose();
  }

  void _checkFields() {
    if (!mounted) return; // Vérifier si le widget est toujours monté

    setState(() {
      _areFieldsFilled = civility != null &&
          _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          selectedDate != null &&
         
          _idNumberController.text.isNotEmpty;
    });
  }

  void _navigateToNextPage() {
    if (_formKey.currentState!.validate()) {
      Map<String, String> civiliteMap = {"Monsieur": "Mr", "Madame": "Mme"};

      formData["civilité"] = civiliteMap[civility] ?? "";

      formData["first_name"] = _firstNameController.text;
      formData["last_name"] = _lastNameController.text;
      formData["date_of_birth"] = selectedDate;
      
     
      formData["numero_identite"] = _idNumberController.text;

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

  // Nouvelle méthode pour naviguer vers la page de scan NFC
  void _navigateToNfcScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecondPage(),
      ),
    );
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
        _checkFields();
      });
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
            onBackPressed: () => Navigator.pop(context),
            child: Container(),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 60),
                Text(
                  'Identité',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                              // NFC :)
                              AnimatedBuilder(
                                animation: _scaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(bottom: 20),
                                      child: ElevatedButton.icon(
                                        onPressed: _navigateToNfcScan,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade600,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 4,
                                        ),
                                        icon: Icon(Icons.nfc, size: 24),
                                        label: Text(
                                          'Scanner votre carte d\'identité',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Civilité
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Civilité *',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<String>(
                                          title: const Text('Monsieur'),
                                          value: 'Monsieur',
                                          groupValue: civility,
                                          onChanged: widget.readOnly ? null : (String? value) {
                                            setState(() {
                                              civility = value;
                                              _checkFields();
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<String>(
                                          title: const Text('Madame'),
                                          value: 'Madame',
                                          groupValue: civility,
                                          onChanged: widget.readOnly ? null : (String? value) {
                                            setState(() {
                                              civility = value;
                                              _checkFields();
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              _buildTextField('Prénom', _firstNameController),
                              _buildTextField('Nom', _lastNameController),
                              _buildDateField('Date de naissance'),
                            
                              _buildTextField('Numéro de la carte nationale',
                                  _idNumberController),
                              _buildTextField("Numéro d'identite nationale",
                                  _NINController),
                              _buildTextField("Date d'expiration du document",
                                  _expController),

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
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        readOnly: widget.readOnly,
        onChanged: (value) => _checkFields(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          enabled: !widget.readOnly,
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

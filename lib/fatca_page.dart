import 'package:flutter/material.dart';
import 'creecompte_3.dart'; // Importation de la page CreateAccountStep3
import 'package:projet1/configngrok.dart';
import 'curved_header.dart';

class FatcaPage extends StatefulWidget {
  final Map<String, dynamic> formData;

  FatcaPage({required this.formData});

  @override
  _FatcaPageState createState() => _FatcaPageState();
}

class _FatcaPageState extends State<FatcaPage> {
  final _formKey = GlobalKey<FormState>();
  String? nationality;
  String? residence;
  String? greenCard;
  String? tin;
  bool _areFieldsFilled = false;

  @override
  void initState() {
    super.initState();
  }

  void _checkFields() {
    setState(() {
      _areFieldsFilled = nationality != null &&
          residence != null &&
          greenCard != null &&
          tin != null &&
          tin!.isNotEmpty;
    });
  }

  void _submitFatca() {
    if (_formKey.currentState!.validate()) {
      widget.formData.addAll({
        "fatca_nationalitéAM": nationality == "Oui",
        "fatca_residenceAM": residence == "Oui",
        "fatca_greencardAM": greenCard == "Oui",
        "fatca_TIN": tin,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CreateAccountStep3(formData: widget.formData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CurvedHeader(
            height: 0.3,
            title: 'Demande compte bancaire',
            onBackPressed: () => Navigator.pop(context),
            child:
                Container(), // Le contenu principal est maintenant géré par le SafeArea en dessous
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
                      SizedBox(height: 100),
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
                            // Question 1 : Nationalité Américaine
                            Text(
                              'Possédez-vous la nationalité Américaine ?',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'Oui',
                                  groupValue: nationality,
                                  onChanged: (value) {
                                    setState(() {
                                      nationality = value;
                                      _checkFields();
                                    });
                                  },
                                ),
                                Text('Oui'),
                                SizedBox(width: 20),
                                Radio<String>(
                                  value: 'Non',
                                  groupValue: nationality,
                                  onChanged: (value) {
                                    setState(() {
                                      nationality = value;
                                      _checkFields();
                                    });
                                  },
                                ),
                                Text('Non'),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Question 2 : Résidence Américaine
                            Text(
                              'Possédez-vous la résidence Américaine ?',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'Oui',
                                  groupValue: residence,
                                  onChanged: (value) {
                                    setState(() {
                                      residence = value;
                                      _checkFields();
                                    });
                                  },
                                ),
                                Text('Oui'),
                                SizedBox(width: 20),
                                Radio<String>(
                                  value: 'Non',
                                  groupValue: residence,
                                  onChanged: (value) {
                                    setState(() {
                                      residence = value;
                                      _checkFields();
                                    });
                                  },
                                ),
                                Text('Non'),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Question 3 : Green Card
                            Text(
                              'Possédez-vous la Green Card ?',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'Oui',
                                  groupValue: greenCard,
                                  onChanged: (value) {
                                    setState(() {
                                      greenCard = value;
                                      _checkFields();
                                    });
                                  },
                                ),
                                Text('Oui'),
                                SizedBox(width: 20),
                                Radio<String>(
                                  value: 'Non',
                                  groupValue: greenCard,
                                  onChanged: (value) {
                                    setState(() {
                                      greenCard = value;
                                      _checkFields();
                                    });
                                  },
                                ),
                                Text('Non'),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Champ TIN (Taxpayer Identification Number)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText:
                                    'TIN (Taxpayer Identification Number)',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  tin = value;
                                  _checkFields();
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre TIN';
                                }
                                return null;
                              },
                            ),
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
                                      _areFieldsFilled ? _submitFatca : null,
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
}

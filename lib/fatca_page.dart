import 'package:flutter/material.dart';
import 'creecompte_3.dart'; // Importation de la page CreateAccountStep3

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
        MaterialPageRoute(builder: (context) => CreateAccountStep3(formData: widget.formData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire FATCA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question 1 : Nationalité Américaine
              Text(
                'Possédez-vous la nationalité Américaine ?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Oui',
                    groupValue: nationality,
                    onChanged: (value) {
                      setState(() {
                        nationality = value;
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Oui',
                    groupValue: residence,
                    onChanged: (value) {
                      setState(() {
                        residence = value;
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Oui',
                    groupValue: greenCard,
                    onChanged: (value) {
                      setState(() {
                        greenCard = value;
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
                  labelText: 'TIN (Taxpayer Identification Number)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    tin = value;
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

              // Bouton de soumission
              Center(
                child: ElevatedButton(
                  onPressed: _submitFatca,
                  child: Text('Soumettre'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

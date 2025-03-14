import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'header.dart'; // Importation du header commun

class DemCarte extends StatefulWidget {
  final String nomClient;

  const DemCarte({Key? key, required this.nomClient}) : super(key: key);

  @override
  _DemCarteState createState() => _DemCarteState();
}

class _DemCarteState extends State<DemCarte> {
  String? selectedCarteType;
  bool isLoading = false;
  bool fraisPayes = false;

  final List<String> typesDeCartes = [
    "Visa",
    "MasterCard",
    "Visa Platinum",
    "MasterCard World Elite",
    "American Express",
    "American Express Gold"
  ];

  Future<void> envoyerDemande() async {
    if (selectedCarteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez sélectionner un type de carte.")),
      );
      return;
    }

    if (!fraisPayes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez confirmer le paiement des frais.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      String? clientId = prefs.getString("client_id");

      if (token == null || clientId == null) {
        throw Exception("Token ou ID client manquant.");
      }

      final response =
          await ApiService.demanderCarte(clientId, selectedCarteType!, token);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Carte demandée avec succès ! 📩")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade300, Colors.blue.shade900],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeader(), // Affichage du header
                  const SizedBox(height: 20),

                  _buildDropdownField("Type de carte", typesDeCartes),
                  const SizedBox(height: 15),
                  _buildTextField("Plafond de paiement"),
                  const SizedBox(height: 15),
                  _buildTextField("Plafond de retrait"),
                  const SizedBox(height: 15),
                  _buildReadOnlyField("Frais de la carte: 50.00€"),
                  const SizedBox(height: 15),
                  _buildCheckbox("J'ai payé les frais de la carte"),
                  const SizedBox(height: 30),
                  _buildButton(context, "Valider la demande", envoyerDemande),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.blue.shade900,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCarteType = value;
        });
      },
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildCheckbox(String label) {
    return Row(
      children: [
        Checkbox(
          value: fraisPayes,
          onChanged: (bool? newValue) {
            setState(() {
              fraisPayes = newValue ?? false;
            });
          },
          checkColor: Colors.blue.shade900,
          fillColor: MaterialStateProperty.all(Colors.white),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: isLoading
            ? CircularProgressIndicator()
            : Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

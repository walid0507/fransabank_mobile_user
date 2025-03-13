import 'package:flutter/material.dart';
import 'header.dart'; // Importation du header commun

class DemCarte extends StatelessWidget {
  final String nomClient;

  const DemCarte({Key? key, required this.nomClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Ajout de SafeArea pour éviter l'overflow en haut
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade300, Colors.blue.shade900],
            ),
          ),
          child: SingleChildScrollView(
            // Ajout du scroll
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeader(), // Affichage du header
                  const SizedBox(height: 20), // Espacement

                  // Suppression du texte "Bonjour, nomClient" pour éviter l'overflow
                  _buildDropdownField("Type de carte", [
                    "Visa",
                    "MasterCard",
                    "Visa Platinum",
                    "MasterCard World Elite",
                    "American Express",
                    "American Express Gold"
                  ]),
                  const SizedBox(height: 15),
                  _buildTextField("Plafond de paiement"),
                  const SizedBox(height: 15),
                  _buildTextField("Plafond de retrait"),
                  const SizedBox(height: 15),
                  _buildReadOnlyField("Frais de la carte: 50.00€"),
                  const SizedBox(height: 15),
                  _buildCheckbox("J'ai payé les frais de la carte"),
                  const SizedBox(height: 30),
                  _buildButton(context, "Valider la demande", () {
                    // Action de validation
                  }),
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
      onChanged: (value) {},
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
          value: false,
          onChanged: (bool? newValue) {},
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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

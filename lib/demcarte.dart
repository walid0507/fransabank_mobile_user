import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'header.dart'; // Importation du header commun
import 'package:projet1/configngrok.dart';

class DemandeCarteScreen extends StatefulWidget {
  final String clientId;
  final String token;

  const DemandeCarteScreen({
    Key? key,
    required this.clientId,
    required this.token,
  }) : super(key: key);

  @override
  _DemandeCarteScreenState createState() => _DemandeCarteScreenState();
}

class _DemandeCarteScreenState extends State<DemandeCarteScreen> {
  String? selectedCarteType;
  bool isLoading = false;
  bool fraisPayes = false;
  late final String _clientId;
  late final String _token;

  final Map<String, Map<String, dynamic>> cartesInfo = {
    "VISA": {
      "nom": "Visa",
      "plafond_paiement": 5000.00,
      "plafond_retrait": 2000.00,
      "solde_minimum": 0,
      "frais": 50.00
    },
    "MASTERCARD": {
      "nom": "MasterCard",
      "plafond_paiement": 5000.00,
      "plafond_retrait": 2000.00,
      "solde_minimum": 50000.00,
      "frais": 50.00
    },
    "VISA_PLATINUM": {
      "nom": "Visa Platinum",
      "plafond_paiement": 10000.00,
      "plafond_retrait": 5000.00,
      "solde_minimum": 100000.00,
      "frais": 100.00
    },
    "MASTERCARD_ELITE": {
      "nom": "MasterCard World Elite",
      "plafond_paiement": 15000.00,
      "plafond_retrait": 7500.00,
      "solde_minimum": 150000.00,
      "frais": 150.00
    },
    "AMEX": {
      "nom": "American Express",
      "plafond_paiement": 20000.00,
      "plafond_retrait": 10000.00,
      "solde_minimum": 200000.00,
      "frais": 200.00
    },
    "AMEX_GOLD": {
      "nom": "American Express Gold",
      "plafond_paiement": 25000.00,
      "plafond_retrait": 12500.00,
      "solde_minimum": 250000.00,
      "frais": 250.00
    }
  };

  @override
  void initState() {
    super.initState();
    _clientId = widget.clientId;
    _token = widget.token;
  }

  final List<String> typesDeCartes = [
    "VISA",
    "MASTERCARD",
    "VISA_PLATINUM",
    "MASTERCARD_ELITE",
    "AMEX",
    "AMEX_GOLD"
  ];

  // Map pour afficher les noms plus lisibles dans l'interface
  final Map<String, String> typeCartesAffichage = {
    "VISA": "Visa",
    "MASTERCARD": "MasterCard",
    "VISA_PLATINUM": "Visa Platinum",
    "MASTERCARD_ELITE": "MasterCard World Elite",
    "AMEX": "American Express",
    "AMEX_GOLD": "American Express Gold"
  };

  Future<void> envoyerDemande() async {
    if (selectedCarteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner un type de carte"),
          backgroundColor: Colors.red,
        ),
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
      print("🚀 Début de l'envoi de la demande de carte");
      print("📱 Type de carte sélectionné: $selectedCarteType");
      print("🔑 Client ID: $_clientId");
      print("🔑 Token: $_token");

      final response = await ApiService.demanderCarte(
        _clientId,
        selectedCarteType!,
        _token,
      );

      print("✅ Réponse reçue: $response");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demande de carte envoyée avec succès !"),
          backgroundColor: Colors.green,
        ),
      );

      // Attendre un court instant pour que l'utilisateur voie le message de succès
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      print("❌ Erreur détaillée lors de l'envoi de la demande:");
      print("Type d'erreur: ${e.runtimeType}");
      print("Message d'erreur: $e");

      if (!mounted) return;

      String messageErreur =
          "Une erreur est survenue lors de l'envoi de la demande.";
      if (e.toString().contains("401")) {
        messageErreur = "Session expirée. Veuillez vous reconnecter.";
      } else if (e.toString().contains("404")) {
        messageErreur = "Client non trouvé.";
      } else if (e.toString().contains("400")) {
        messageErreur = "Données invalides. Veuillez réessayer.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messageErreur),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
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
            final info = cartesInfo[option]!;
            return DropdownMenuItem(
              value: option,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info["nom"],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    "Plafonds: ${info["plafond_paiement"]}€ / ${info["plafond_retrait"]}€",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "Solde minimum: ${info["solde_minimum"]}€",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCarteType = value;
              if (value != null) {
                _updateFraisCard(value);
              }
            });
          },
        ),
        if (selectedCarteType != null) ...[
          const SizedBox(height: 10),
          Text(
            "⚠️ Cette carte nécessite un solde minimum de ${cartesInfo[selectedCarteType]!["solde_minimum"]}€",
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ],
    );
  }

  void _updateFraisCard(String cardType) {
    setState(() {
      _fraisCarteText = "Frais de la carte: ${cartesInfo[cardType]!["frais"]}€";
    });
  }

  String _fraisCarteText = "Frais de la carte: 50.00€";

  Widget _buildReadOnlyField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _fraisCarteText,
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

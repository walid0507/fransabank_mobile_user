import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'header.dart'; // Importation du header commun
import 'package:projet1/configngrok.dart';
import 'package:projet1/header3.dart';
import 'package:projet1/pret.dart';

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
    "Carte Classic": {
      "nom": "Carte Classic",
      "plafond_paiement": "1000",
      "plafond_retrait": "500",
      "solde_minimum": "100",
      "frais": "50.00",
    },
    "Carte Gold": {
      "nom": "Carte Gold",
      "plafond_paiement": "3000",
      "plafond_retrait": "1500",
      "solde_minimum": "500",
      "frais": "100.00",
    },
    "Carte Platinum": {
      "nom": "Carte Platinum",
      "plafond_paiement": "5000",
      "plafond_retrait": "2500",
      "solde_minimum": "1000",
      "frais": "200.00",
    },
  };

  @override
  void initState() {
    super.initState();
    _clientId = widget.clientId;
    _token = widget.token;
  }

  final List<String> typesDeCartes = [
    "Carte Classic",
    "Carte Gold",
    "Carte Platinum",
  ];

  // Map pour afficher les noms plus lisibles dans l'interface
  final Map<String, String> typeCartesAffichage = {
    "Carte Classic": "Carte Classic",
    "Carte Gold": "Carte Gold",
    "Carte Platinum": "Carte Platinum",
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
        const SnackBar(
          content: Text("Veuillez confirmer le paiement des frais"),
          backgroundColor: Colors.red,
        ),
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
      body: Column(
        children: [
          Header3(
            title: 'DEMANDE DE CARTE',
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildDropdownField("Type de carte", typesDeCartes),
                  SizedBox(height: 12),
                  _buildTextField("Plafond de paiement"),
                  SizedBox(height: 12),
                  _buildTextField("Plafond de retrait"),
                  SizedBox(height: 12),
                  _buildReadOnlyField("Frais de la carte: 50.00€"),
                  SizedBox(height: 12),
                  _buildCheckbox("J'ai payé les frais de la carte"),
                  SizedBox(height: 20),
                  _buildButton(context, "Valider la demande", envoyerDemande),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.grey[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            selectedItemBuilder: (BuildContext context) {
              return options.map<Widget>((String item) {
                return Container(
                  alignment: Alignment.centerLeft,
                  constraints: BoxConstraints(minHeight: 48),
                  child: Text(
                    cartesInfo[item]!["nom"],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList();
            },
            items: options.map((option) {
              final info = cartesInfo[option]!;
              return DropdownMenuItem<String>(
                value: option,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              info["nom"],
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Plafonds: ${info["plafond_paiement"]}€ / ${info["plafond_retrait"]}€",
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
        ),
        if (selectedCarteType != null)
          Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Solde minimum requis: ${cartesInfo[selectedCarteType]!["solde_minimum"]}€",
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _fraisCarteText,
        style: TextStyle(color: Colors.grey[700]),
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
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.all(Colors.blue[900]),
        ),
        Text(label, style: TextStyle(color: Colors.grey[700])),
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

  @override
  void dispose() {
    super.dispose();
  }
}

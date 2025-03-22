import 'package:flutter/material.dart';
import 'package:projet1/header3.dart';
import 'package:projet1/configngrok.dart';

class OffresScreen extends StatefulWidget {
  const OffresScreen({Key? key}) : super(key: key);

  @override
  State<OffresScreen> createState() => _OffresScreenState();
}

class _OffresScreenState extends State<OffresScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header3(
            title: 'Offres',
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    _buildOfferCard(
                      "Compte Épargne",
                      "Taux d'intérêt avantageux.",
                      Icons.savings,
                    ),
                    _buildOfferCard(
                      "Crédit Immobilier",
                      "Financez votre logement.",
                      Icons.home,
                    ),
                    _buildOfferCard(
                      "Carte Premium",
                      "Services exclusifs.",
                      Icons.credit_card,
                    ),
                    _buildOfferCard(
                      "Assurance Vie",
                      "Protégez votre avenir.",
                      Icons.security,
                    ),
                    _buildOfferCard(
                      "Crédit Auto",
                      "Achetez votre véhicule.",
                      Icons.directions_car,
                    ),
                    _buildOfferCard(
                        "Compte Jeune", "Spécial 18-25 ans.", Icons.school),
                    _buildOfferCard(
                      "Compte Pro",
                      "Pour entrepreneurs.",
                      Icons.business,
                    ),
                    _buildOfferCard(
                      "Épargne Retraite",
                      "Préparez votre futur.",
                      Icons.account_balance_wallet,
                    ),
                    _buildOfferCard(
                      "Prêt Personnel",
                      "Financer vos projets.",
                      Icons.attach_money,
                    ),
                    _buildOfferCard(
                      "Pack Familial",
                      "Gérez les comptes famille.",
                      Icons.family_restroom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String title, String description, IconData icon) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade900, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

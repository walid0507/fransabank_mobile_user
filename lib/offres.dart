import 'package:flutter/material.dart';
import 'header2.dart'; // Importation du header commun
import 'package:projet1/configngrok.dart';
class OffresScreen extends StatelessWidget {
  const OffresScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonHeader(
      title: 'Nos Offres',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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

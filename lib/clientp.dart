import 'package:flutter/material.dart';
import 'creecompte.dart'; // Importation de la page de création de compte
import 'main.dart'; // Importation de la page de connexion
import 'cartes.dart'; // Importation de la page Cartes
import 'agences_gab.dart'; // Importation de la page Agences & GAB
import 'parametres.dart'; // Importation de la page Paramètres
import 'offres.dart'; // Importation de la page Offres

class ClientScreen extends StatelessWidget {
  final String nomClient;

  const ClientScreen({Key? key, required this.nomClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildFrontCard(),
            const SizedBox(height: 20),
            Text(
              "Bonjour $nomClient",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Bienvenue dans votre espace client",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _buildMenuItem(Icons.person, 'Comptes'),
                    _buildMenuItem(Icons.credit_card, 'Cartes'),
                    _buildMenuItem(Icons.local_offer, 'Offres'),
                    _buildMenuItem(Icons.location_on, 'Agences & GAB'),
                    _buildMenuItem(Icons.settings, 'Paramètres'),
                    _buildMenuItem(
                        Icons.add_business, 'Créer un compte bancaire'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: Colors.blue.shade900),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: 350,
      height: 200,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fransabank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.credit_card, color: Colors.white, size: 30),
            ],
          ),
          SizedBox(height: 20),
          Text(
            '6501 0702 1205 5051',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Exp: 12/20',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTransactionItem(
    IconData icon, String title, String amount, String status, String date) {
  return Card(
    margin: EdgeInsets.only(bottom: 10),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: ListTile(
      leading: Icon(icon, color: Colors.blue.shade900),
      title: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text(date, style: TextStyle(fontSize: 14)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              color: status == 'Failed' ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: status == 'Failed' ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    ),
  );
}

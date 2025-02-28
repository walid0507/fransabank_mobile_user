import 'package:flutter/material.dart';
import 'creecompte.dart'; // Importation de la page de création de compte
import 'main.dart'; // Importation de la page de connexion
import 'cartes.dart'; // Importation de la page Cartes
import 'agences_gab.dart'; // Importation de la page Agences & GAB
import 'parametres.dart'; // Importation de la page Paramètres
import 'offres.dart'; // Importation de la page Offres

class ProfileScreen extends StatelessWidget {
  final String nomClient;

  const ProfileScreen({Key? key, required this.nomClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/image003.jpeg',
          width: 250,
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
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
            const SizedBox(height: 200),
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
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _buildMenuItem(Icons.person, 'Comptes'),
                    _buildMenuItem(
                      Icons.credit_card,
                      'Cartes',
                      onPressed: () => _onCartesPressed(context),
                    ),
                    _buildMenuItem(
                      Icons.local_offer,
                      'Offres',
                      onPressed: () => _onOffresPressed(
                          context), // Ajout de l'action pour le bouton "Offres"
                    ),
                    _buildMenuItem(
                      Icons.location_on,
                      'Agences & GAB',
                      onPressed: () => _onAgencesPressed(context),
                    ),
                    _buildMenuItem(
                      Icons.settings,
                      'Paramètres',
                      onPressed: () => _onParametresPressed(
                          context), // Ajout de l'action pour le bouton "Paramètres"
                    ),
                    _buildMenuItem(
                      Icons.add_business,
                      'Créer un compte bancaire',
                      onPressed: () => _onCreateAccountPressed(context),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _onLogoutPressed(context),
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label,
      {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.blue.shade700),
          const SizedBox(height: 10),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // Fonction pour la création de compte
  void _onCreateAccountPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountScreen()),
    );
  }

  // Fonction pour la déconnexion
  void _onLogoutPressed(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Fonction pour naviguer vers la page Cartes
  void _onCartesPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartesPage(nomClient: nomClient),
      ),
    );
  }

  // Fonction pour naviguer vers la page Agences & GAB
  void _onAgencesPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgencesScreen()),
    );
  }

  // Fonction pour naviguer vers la page Offres
  void _onOffresPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OffresScreen()),
    );
  }

  // Fonction pour naviguer vers la page Paramètres
  void _onParametresPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ParametresScreen()),
    );
  }
}

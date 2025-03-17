import 'package:flutter/material.dart';
import 'package:projet1/demcarte.dart';
import 'package:projet1/motdepasse.dart';
import 'package:projet1/main.dart'; // Importation de la page de connexion
import 'package:projet1/agences_gab.dart'; // Importation de la page Agences & GAB
import 'package:projet1/parametres.dart'; // Importation de la page Paramètres
import 'package:projet1/offres.dart'; // Importation de la page Offres
import 'package:shared_preferences/shared_preferences.dart';

class ClientScreen extends StatelessWidget {
  final String nomClient;

  const ClientScreen({Key? key, required this.nomClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Permet le défilement si le contenu dépasse
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade300, Colors.blue.shade900],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10), // Espace réduit
              _buildFrontCard(), // Carte réduite
              const SizedBox(height: 10), // Espace réduit
              Text(
                "Bonjour $nomClient",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5), // Espace réduit
              const Text(
                "Bienvenue dans votre espace client",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10), // Espace réduit
              // Section des icônes
              GridView.count(
                crossAxisCount: 3, // 3 icônes par ligne
                shrinkWrap: true,
                physics:
                    NeverScrollableScrollPhysics(), // Désactive le défilement
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                childAspectRatio: 1.5, // Ajuste la taille des carreaux
                mainAxisSpacing: 10, // Espace vertical entre les carreaux
                crossAxisSpacing: 10, // Espace horizontal entre les carreaux
                children: [
                  _buildMenuItem(Icons.vpn_key, 'Mots de passes', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MotDePasse(nomClient: nomClient)),
                    );
                  }),
                  _buildMenuItem(Icons.local_offer, 'Offres', () {
                    _onOffresPressed(context);
                  }),
                  _buildMenuItem(Icons.location_on, 'Agences & GAB', () {
                    _onAgencesPressed(context);
                  }),
                  _buildMenuItem(Icons.settings, 'Paramètres', () {
                    _onParametresPressed(context); // Action pour "Paramètres"
                  }),
                  _buildMenuItem(Icons.credit_card, 'Demande carte', () {
                    _onDemandeCartePressed(context);
                  }),
                  _buildMenuItem(Icons.video_call, 'Vidéo conférence', () {
                    // Action à définir pour la vidéo conférence
                  }),
                ],
              ),
              const SizedBox(height: 10), // Espace réduit
              Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 18, // Taille de police réduite
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5), // Espace réduit
              _buildTransactionList(),
              const SizedBox(height: 10), // Espace réduit
              // Bouton de déconnexion
              Padding(
                padding: const EdgeInsets.all(8.0), // Padding réduit
                child: ElevatedButton.icon(
                  onPressed: () => _onLogoutPressed(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Déconnexion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 2, horizontal: 1), // Padding réduit
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                  height: 10), // Espace en bas pour éviter le débordement
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Fond blanc
        foregroundColor: Colors.blue.shade900, // Couleur du texte et de l'icône
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Bordures arrondies
        ),
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        minimumSize: Size(35,
            35), // Réduit la largeur (ajuste selon ton besoin) // Padding réduit
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20), // Icône plus petite (taille réduite)
          const SizedBox(height: 5), // Espace réduit
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10), // Texte plus petit
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: 350,
      height: 120, // Hauteur encore réduite
      margin: EdgeInsets.all(10), // Marge réduite
      padding: EdgeInsets.all(10), // Padding réduit
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
                  fontSize: 16, // Taille de police réduite
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.credit_card,
                  color: Colors.white, size: 20), // Icône plus petite
            ],
          ),
          SizedBox(height: 10), // Espace réduit
          Text(
            '6501 0702 1205 5051',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // Taille de police réduite
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 5), // Espace réduit
          Text(
            'Exp: 12/20',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12, // Taille de police réduite
            ),
          ),
        ],
      ),
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

  void _onDemandeCartePressed(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token") ?? prefs.getString("access_token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur: Token non trouvé"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DemandeCarteScreen(
          clientId: nomClient,
          token: token,
        ),
      ),
    );
  }
}

Widget _buildTransactionList() {
  final List<Map<String, dynamic>> transactions = [
    {
      'icon': Icons.payment,
      'title': 'netflix',
      'amount': '-570 da',
      'status': 'Paid',
      'date': '14 Juillet 2025',
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'psplus',
      'amount': '-205 da',
      'status': 'Failed',
      'date': '02 Juillet 2025',
    },
    {
      'icon': Icons.directions_car,
      'title': 'yassir',
      'amount': '-398 da',
      'status': 'Failed',
      'date': '10 juin 2025',
    },
  ];

  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(), // Désactive le défilement
    padding: EdgeInsets.symmetric(horizontal: 10), // Padding réduit
    itemCount: transactions.length,
    itemBuilder: (context, index) {
      final transaction = transactions[index];
      return _buildTransactionItem(
        transaction['icon'],
        transaction['title'],
        transaction['amount'],
        transaction['status'],
        transaction['date'],
      );
    },
  );
}

Widget _buildTransactionItem(
    IconData icon, String title, String amount, String status, String date) {
  return Card(
    margin: EdgeInsets.only(bottom: 5), // Marge réduite
    elevation: 2, // Élévation réduite
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: ListTile(
      leading: Icon(icon,
          size: 18, color: Colors.blue.shade900), // Icône plus petite
      title: Text(
        title,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold), // Texte plus petit
      ),
      subtitle: Text(date, style: TextStyle(fontSize: 10)), // Texte plus petit
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 12, // Texte plus petit
              color: status == 'Failed' ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 10, // Texte plus petit
              color: status == 'Failed' ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    ),
  );
}

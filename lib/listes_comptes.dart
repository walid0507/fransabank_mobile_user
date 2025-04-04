import 'package:flutter/material.dart';
import 'curved_header.dart';
import 'comptes.dart';

class CustomPage extends StatelessWidget {
  // Liste d'exemple de comptes bancaires (sans solde)
  final List<Map<String, String>> comptesBancaires = [
    {'id': '123456789', 'titulaire': 'Ali Ben Ahmed'},
    {'id': '987654321', 'titulaire': 'Sofia Djellouli'},
    {'id': '456123789', 'titulaire': 'Khaled Maâti'},
    {'id': '321654987', 'titulaire': 'Nadia Boudiaf'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildHeader(context),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.transparent,
              child: _buildBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipPath(
      clipper: InvertedCurvedClipper(),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFF024DA2),
          image: DecorationImage(
            image: AssetImage('assets/images/stars.jpg'), // Assurez-vous d'avoir cette image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color(0xFF024DA2).withOpacity(0.9),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AnimatedCrossFade(
                duration: Duration(milliseconds: 1500),
                firstChild: Text(
                  'listes demandes comptes',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                secondChild: Text(
                  'Bienvenue chez Fransabank!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                crossFadeState: CrossFadeState.showFirst,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 5),
            Image.asset(
              'assets/images/fransa2bk.png', // Assurez-vous d'avoir cette image
              width: 160,
              height: 160,
            ),
            SizedBox(height: 10),
            // Liste des comptes bancaires
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comptesBancaires.length,
              itemBuilder: (context, index) {
                return _buildListTile(context, comptesBancaires[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour construire chaque élément de la liste (compte bancaire)
  Widget _buildListTile(BuildContext context, Map<String, String> compte) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          // Appel de la fonction pour afficher le dialogue personnalisé
          // Le statut sera géré dans la fonction _showCustomDialog
          _showCustomDialog(context, 'en attente'); // Tu peux passer ici n'importe quel statut dynamique
        },
        title: Text(
          compte['titulaire']!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'ID Compte: ${compte['id']}',
          style: TextStyle(color: Colors.black54),
        ),
        // Supprime le trailing qui affichait le solde
      ),
    );
  }

  // Fonction pour afficher les détails du compte lorsque l'utilisateur clique
  void _showAccountDetails(BuildContext context, Map<String, String> compte) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails du compte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Titulaire: ${compte['titulaire']}'),
              Text('ID Compte: ${compte['id']}'),
              // Retiré le solde, car ce n'est pas applicable ici
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}

class InvertedCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Point de départ
    path.lineTo(0, size.height * 0.77);

    // Première courbe
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.82,
        size.width * 0.25, size.height * 0.82);

    // Deuxième courbe
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.82, size.width, size.height * 0.57);

    // Compléter le chemin
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CustomPage(),
  ));
}

void _showCustomDialog(BuildContext context, String status) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Si le statut est "en attente", on montre l'animation du sablier
            if (status == "en attente")
              Image.asset(
                  'assets/images/sablier_animation.gif'), // Remplace par une animation de sablier
            // Si le statut est "approuvé", on montre l'icône OK
            if (status == "approuvé")
              Icon(Icons.check_circle, size: 50, color: Colors.green),
            SizedBox(height: 15),
            // Texte dynamique en fonction du statut
            Text(
              status == "en attente"
                  ? "Votre demande est en train d'être étudiée"
                  : "Votre demande a été approuvée",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor:
                        Colors.blue, // Remplacé "primary" par "backgroundColor"
                  ),
                  child: Text("OK"),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

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
          CurvedHeader(
            title: 'Listes demandes comptes',
            onBackPressed: () => Navigator.pop(context),
            child: Container(),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    Image.asset(
                      'assets/images/fransa2bk.png',
                      width: 160,
                      height: 160,
                    ),
                    SizedBox(height: 10),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, Map<String, String> compte) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          _showCustomDialog(context, 'en attente');
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
            if (status == "en attente")
              Image.asset('assets/images/sablier_animation.gif'),
            if (status == "approuvé")
              Icon(Icons.check_circle, size: 50, color: Colors.green),
            SizedBox(height: 15),
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
                    backgroundColor: Colors.blue,
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

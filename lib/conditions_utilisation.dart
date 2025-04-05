import 'package:flutter/material.dart';
import 'creecompte.dart';
import 'comptes.dart';

class ConditionsUtilisationPage extends StatefulWidget {
  final String nomClient;

  const ConditionsUtilisationPage({Key? key, required this.nomClient}) : super(key: key);

  @override
  _ConditionsUtilisationPageState createState() => _ConditionsUtilisationPageState();
}

class _ConditionsUtilisationPageState extends State<ConditionsUtilisationPage> {
  final ScrollController _scrollController = ScrollController();

  void _showRefusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conditions d\'utilisation refusées'),
          content: const Text('Si vous refusez les conditions d\'utilisation, l\'ouverture d\'un compte à distance ne sera pas possible. Nous vous invitons à vous rendre en agence pour obtenir davantage d\'informations.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComptesPage(nomClient: widget.nomClient),
                  ),
                );
              },
              child: const Text('J\'ai compris'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
    bool outline = false,
  }) {
    final Color primaryBlue = const Color(0xFF024DA2);
    
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: outline ? Colors.white : primaryBlue,
          foregroundColor: outline ? primaryBlue : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: outline ? BorderSide(color: primaryBlue) : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF024DA2);
    
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: primaryBlue,
              image: DecorationImage(
                image: const AssetImage('assets/images/stars.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  primaryBlue.withOpacity(0.9),
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Conditions d\'utilisation',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Avant de soumettre votre demande de compte bancaire, veuillez lire attentivement les conditions ci-dessous. En continuant le processus de demande, vous acceptez de vous conformer à ces conditions.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSection('Consentement et Informations Personnelles',
                          'En soumettant votre demande, vous consentez à fournir des informations personnelles exactes et complètes, y compris, mais sans s\'y limiter, votre nom, prénom, adresse, numéro de téléphone, date de naissance et adresse e-mail. Vous comprenez que ces informations seront utilisées pour l\'ouverture de votre compte bancaire et la vérification de votre identité.'),
                      _buildSection('Vérification d\'Identité',
                          'Vous acceptez de soumettre les documents nécessaires pour compléter votre processus de vérification d\'identité. Cela peut inclure, mais sans s\'y limiter, une photo de votre pièce d\'identité (carte d\'identité, passeport ou permis de conduire), un justificatif de domicile à jour, ainsi que toute autre pièce justificative demandée par nos services.'),
                      _buildSection('Reconnaissance Faciale',
                          'Vous êtes informé que, dans le cadre du processus de vérification, une reconnaissance faciale pourra être utilisée pour confirmer que la personne qui soumet la demande est bien la même que celle figurant sur les documents d\'identité fournis. En soumettant votre demande, vous consentez à l\'utilisation de cette technologie.'),
                      _buildSection('Signature Électronique',
                          'Vous acceptez de signer électroniquement toutes les autorisations et accords nécessaires pour l\'ouverture et la gestion de votre compte bancaire, y compris la signature de documents légaux relatifs à l\'ouverture du compte. La signature électronique a la même valeur juridique qu\'une signature manuscrite.'),
                      _buildSection('Lutte contre la Fraude',
                          'Vous confirmez que toutes les informations fournies dans le cadre de votre demande sont exactes et authentiques. En cas de fausse déclaration, de fraude ou d\'utilisation d\'informations trompeuses, nous nous réservons le droit de rejeter votre demande, de fermer votre compte ou de signaler l\'incident aux autorités compétentes.'),
                      _buildSection('Sécurité et Confidentialité',
                          'Nous nous engageons à protéger vos informations personnelles conformément à la législation sur la protection des données. Toutes les données recueillies, y compris vos documents et images, seront traitées de manière sécurisée et confidentielle.'),
                      _buildSection('Consentement pour l\'utilisation des Données',
                          'En soumettant votre demande, vous acceptez que vos données personnelles soient utilisées exclusivement dans le cadre de l\'ouverture de votre compte bancaire et des vérifications associées. Vous consentez également à recevoir des communications relatives à l\'état de votre demande et à la gestion de votre compte.'),
                      _buildSection('Modification des Conditions',
                          'Nous nous réservons le droit de modifier ces conditions d\'utilisation à tout moment. Toute modification sera communiquée et prendra effet dès sa publication sur cette page.'),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildModernButton(
                                text: 'Refuser',
                                onPressed: () => _showRefusDialog(context),
                                outline: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildModernButton(
                                text: 'Accepter',
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CreateAccountScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25.0),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.3), width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

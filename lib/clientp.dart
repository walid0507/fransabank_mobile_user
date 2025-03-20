import 'package:flutter/material.dart';
import 'package:projet1/demcarte.dart';
import 'package:projet1/motdepasse.dart';
import 'package:projet1/main.dart'; // Importation de la page de connexion
import 'package:projet1/agences_gab.dart'; // Importation de la page Agences & GAB
import 'package:projet1/parametres.dart'; // Importation de la page Paramètres
import 'package:projet1/offres.dart'; // Importation de la page Offres
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet1/video_conference.dart';
import 'package:projet1/virements.dart';

class ClientScreen extends StatefulWidget {
  final String nomClient;
  const ClientScreen({Key? key, required this.nomClient}) : super(key: key);

  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<double>> _scaleAnimations = {};

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs d'animation pour chaque service
    _initializeAnimationControllers();
  }

  void _initializeAnimationControllers() {
    // Services
    _createAnimationController('password');
    _createAnimationController('offres');
    _createAnimationController('agences');
    _createAnimationController('parametres');
    _createAnimationController('carte');
    _createAnimationController('video');

    // Transactions
    _createAnimationController('netflix');
    _createAnimationController('psplus');
    _createAnimationController('yassir');
  }

  void _createAnimationController(String key) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    final animation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    _animationControllers[key] = controller;
    _scaleAnimations[key] = animation;
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header avec dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[900]!,
                  Colors.blue[700]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Barre de navigation
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Accueil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                            width: 40), // Pour équilibrer avec la flèche retour
                      ],
                    ),
                  ),
                  // Section solde
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Solde disponible',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '\$4,180.20',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Section des icônes avec slide
                  SizedBox(
                    height: 130,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        // Première page d'icônes
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildServiceItem(
                                icon: Icons.password_rounded,
                                color: Colors.blue[700]!,
                                label: 'Mots de passe',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MotDePasse(nomClient: widget.nomClient),
                                  ),
                                ),
                              ),
                              _buildServiceItem(
                                icon: Icons.local_offer_rounded,
                                color: Colors.orange,
                                label: 'Offres',
                                onTap: () => _onOffresPressed(context),
                              ),
                              _buildServiceItem(
                                icon: Icons.location_on_rounded,
                                color: Colors.red,
                                label: 'Agences',
                                onTap: () => _onAgencesPressed(context),
                              ),
                            ],
                          ),
                        ),
                        // Deuxième page d'icônes
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildServiceItem(
                                icon: Icons.settings_rounded,
                                color: Colors.grey[700]!,
                                label: 'Paramètres',
                                onTap: () => _onParametresPressed(context),
                              ),
                              _buildServiceItem(
                                icon: Icons.credit_card_rounded,
                                color: Colors.green,
                                label: 'Carte',
                                onTap: () => _onDemandeCartePressed(context),
                              ),
                              _buildServiceItem(
                                icon: Icons.video_camera_front_rounded,
                                color: Colors.purple,
                                label: 'Vidéo',
                                onTap: () => _onVideoConferencePressed(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Indicateurs de page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 2; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _currentPage
                                ? Colors.blue[900]
                                : Colors.grey[300],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Section Transactions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Transactions récentes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 15),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const VirementsScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Virements',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Voir tout',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildTransactionList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final List<Map<String, dynamic>> transactions = [
      {
        'icon': Icons.shopping_bag_rounded,
        'title': 'Netflix',
        'amount': '-570 da',
        'status': 'Payé',
        'date': '14 Juillet 2025',
        'key': 'netflix',
      },
      {
        'icon': Icons.sports_esports_rounded,
        'title': 'PS Plus',
        'amount': '-205 da',
        'status': 'Échoué',
        'date': '02 Juillet 2025',
        'key': 'psplus',
      },
      {
        'icon': Icons.directions_car_rounded,
        'title': 'Yassir',
        'amount': '-398 da',
        'status': 'Échoué',
        'date': '10 juin 2025',
        'key': 'yassir',
      },
    ];

    return Column(
      children: transactions.map((transaction) {
        return _buildTransactionItem(
          transaction['icon'],
          transaction['title'],
          transaction['amount'],
          transaction['status'],
          transaction['date'],
        );
      }).toList(),
    );
  }

  Widget _buildTransactionItem(
    IconData icon,
    String title,
    String amount,
    String status,
    String date,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(15),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.blue[800], size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: status == 'Échoué' ? Colors.red : Colors.green,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (status == 'Échoué' ? Colors.red : Colors.green)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: status == 'Échoué' ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  void _onVideoConferencePressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoConferencePage(),
      ),
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
          clientId: widget.nomClient,
          token: token,
        ),
      ),
    );
  }
}

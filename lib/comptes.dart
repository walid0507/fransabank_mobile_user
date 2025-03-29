import 'package:flutter/material.dart';
import 'package:projet1/home.dart';
import 'header.dart';
import 'creecompte.dart';
import 'curved_header.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'main.dart';

class ComptesPage extends StatefulWidget {
  final String nomClient;

  const ComptesPage({Key? key, required this.nomClient}) : super(key: key);

  @override
  _ComptesPageState createState() => _ComptesPageState();
}

class _ComptesPageState extends State<ComptesPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> comptes = [];
  bool _isLoading = false;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  static const int MAX_COMPTES = 4;

  @override
  void initState() {
    super.initState();
    print("Initialisation de la page Comptes");
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _loadSavedComptes().then((_) {
      print("Comptes chargés après initState");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _maskClientId(String id) {
    if (id.length <= 4) return id;
    return "${id.substring(0, 2)}*****${id.substring(id.length - 2)}";
  }

 

  Future<void> _loadSavedComptes() async {
    try {
      final comptesJson = await _storage.read(key: 'comptes_sauvegardes');
      print("Comptes chargés: $comptesJson");
      if (comptesJson != null) {
        final List<dynamic> comptesList = json.decode(comptesJson);
        setState(() {
          comptes = comptesList.map((compte) {
            String type = (compte['type'] ?? '').toString();
            // Appliquer le formatage directement lors du chargement
            

            return <String, String>{
              'id': compte['id'].toString(),
              'type': type,
            };
          }).toList();
        });
        print("Nombre de comptes chargés: ${comptes.length}");
        print("Détail des comptes: $comptes");
      } else {
        print("Aucun compte trouvé dans le stockage");
      }
    } catch (e) {
      print("Erreur lors du chargement des comptes: $e");
    }
  }

  Future<void> _saveComptes() async {
    await _storage.write(
      key: 'comptes_sauvegardes',
      value: json.encode(comptes),
    );
  }

  Future<void> _ajouterCompte(String nouveauCompte, String typeClient) async {
    if (comptes.length >= MAX_COMPTES) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Vous avez atteint la limite de $MAX_COMPTES comptes saubegardés.'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Oublier un compte',
            onPressed: () {
              _showForgetAccountDialog();
            },
          ),
        ),
      );
      return;
    }

    if (!comptes.any((compte) => compte['id'] == nouveauCompte)) {
      setState(() {
        comptes.add({
          'id': nouveauCompte,
          'type': typeClient,
        });
      });
      await _saveComptes();
    }
  }

  Future<void> _showForgetAccountDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisir un compte à oublier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: comptes.map((compte) {
                return ListTile(
                  title: Text(_maskClientId(compte['id'] ?? '')),
                  subtitle: Text(compte['type'] ?? ''),
                  onTap: () async {
                    setState(() {
                      comptes.remove(compte);
                    });
                    await _saveComptes();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: isEnabled ? onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: width ?? 200,
          height: height ?? 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    print("Construction de l'état vide");
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          Text(
            "Aucun compte sauvegardé",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "Ajoutez votre premier compte bancaire",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'étudiant':
        return Icons.school;
      case 'commerçant':
        return Icons.store;
      case 'professionnel':
        return Icons.business;
      case 'personnel':
        return Icons.person;
      case 'jeune/enfant':
        return Icons.child_care;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("État actuel - Nombre de comptes: ${comptes.length}");
    return Scaffold(
      body: Stack(
        children: [
          CurvedHeader(
            title: 'Comptes',
            onBackPressed: () => _showLogoutDialog(),
            icon: Icons.logout_rounded,
            child: Container(),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0, top: 0),
                      child: _buildModernButton(
                        text: "Ajouter",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                nomClient: widget.nomClient,
                                clearFields: true,
                              ),
                            ),
                          );
                        },
                        icon: Icons.add_circle_outline,
                        width: 100,
                        height: 40,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : comptes.isEmpty
                          ? _buildEmptyState()
                          : Padding(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                itemCount: comptes.length,
                                itemBuilder: (context, index) {
                                  final type =
                                      comptes[index]['type'] ?? '';
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfileScreen(
                                              nomClient: widget.nomClient),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade700
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 8),
                                        leading: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(_getIconForType(type),
                                              color: Colors.white),
                                        ),
                                        title: Text(
                                          _maskClientId(
                                              comptes[index]['id'] ?? ''),
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          type,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: Icon(Icons.arrow_forward_ios,
                                            color: Colors.white70),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildModernButton(
                    text: comptes.length >= MAX_COMPTES
                        ? "Limite atteinte"
                        : "Demander un nouveau compte",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAccountScreen(),
                        ),
                      );
                    },
                    isEnabled: comptes.length < MAX_COMPTES,
                    icon: Icons.account_balance,
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Voulez-vous vraiment vous déconnecter ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Non',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final storage = FlutterSecureStorage();
                            await storage.delete(key: 'client_id');
                            await storage.delete(key: 'rememberMe');

                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Oui',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

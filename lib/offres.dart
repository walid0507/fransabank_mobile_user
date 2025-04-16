import 'package:flutter/material.dart';
import 'package:projet1/header3.dart';
import 'package:projet1/configngrok.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class OffresScreen extends StatefulWidget {
  const OffresScreen({Key? key}) : super(key: key);

  @override
  State<OffresScreen> createState() => _OffresScreenState();
}

class _OffresScreenState extends State<OffresScreen> {
  final _storage = const FlutterSecureStorage();
  String? _typeClient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientType();
  }

  Future<void> _loadClientType() async {
    try {
      final comptesJson = await _storage.read(key: 'comptes_sauvegardes');
      if (comptesJson != null) {
        final List<dynamic> comptesList = json.decode(comptesJson);
        if (comptesList.isNotEmpty) {
          final clientId = await _storage.read(key: 'client_id');
          final compte = comptesList.firstWhere(
            (c) => c['id'] == clientId,
            orElse: () => null,
          );
          if (compte != null) {
            setState(() {
              _typeClient = compte['type'];
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print("Erreur lors du chargement du type de client: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getOffresForClientType() {
    if (_typeClient == null) return [];

    final offres = [
      {
        'title': 'Monétique',
        'description': 'Gestion de vos moyens de paiement et cartes bancaires',
        'icon': Icons.credit_card,
        'color': Colors.blue.shade900,
      },
      {
        'title': 'Banque à distance',
        'description': 'Accédez à vos services bancaires en ligne',
        'icon': Icons.laptop,
        'color': Colors.green.shade700,
      },
      {
        'title': 'Épargne et placement',
        'description': 'Solutions d\'épargne et d\'investissement adaptées',
        'icon': Icons.trending_up,
        'color': Colors.orange.shade700,
      },
      {
        'title': 'Financements',
        'description': 'Solutions de financement pour vos projets',
        'icon': Icons.monetization_on,
        'color': Colors.purple.shade700,
      },
    ];

    if (_typeClient!.toLowerCase() == 'professionnel' ||
        _typeClient!.toLowerCase() == 'commerçant') {
      offres.add({
        'title': 'Opérations à l\'international',
        'description':
            'Services bancaires pour vos transactions internationales',
        'icon': Icons.language,
        'color': Colors.red.shade700,
      });
    }

    return offres;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Header3(
            title: 'Offres',
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          ..._getOffresForClientType()
                              .map((offre) => _buildOfferCard(
                                    offre['title'],
                                    offre['description'],
                                    offre['icon'],
                                    offre['color'],
                                  )),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(
      String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

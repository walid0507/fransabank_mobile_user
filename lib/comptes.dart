import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projet1/home.dart';
import 'dart:convert';
import 'header.dart';
import 'creecompte.dart'; // Importation du header commun
import 'api_service.dart'; // Importer l'API Service
import 'package:shared_preferences/shared_preferences.dart'; // Importer SharedPreferences

class ComptesPage extends StatefulWidget {
  final String nomClient;

  const ComptesPage({Key? key, required this.nomClient}) : super(key: key);

  @override
  _ComptesPageState createState() => _ComptesPageState();
}

class _ComptesPageState extends State<ComptesPage> {
  List<Map<String, dynamic>> comptes = []; // Liste dynamique des comptes
  bool _isLoading = true; // Pour gérer l'affichage du chargement
  String? _errorMessage; // Message d'erreur si échec

  Future<void> _fetchComptes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Vérifier le token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('Token utilisé: $token'); // Pour déboguer

      List<dynamic>? data = await ApiService().getComptes();
      if (data != null) {
        setState(() {
          comptes = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Aucune donnée reçue du serveur";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur: ${e.toString()}";
        _isLoading = false;
      });
      print('Erreur complète: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchComptes();
  }

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
            AppHeader(), // Utilisation du header commun
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Comptes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ListView.builder(
                            itemCount: comptes.length,
                            itemBuilder: (context, index) {
                              final compte = comptes[index];
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
                                  padding: EdgeInsets.all(16.0),
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${compte['type_compte']} - ${compte['solde']} DA",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAccountScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                    ),
                    child: Text(
                      '+ Ajouter',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

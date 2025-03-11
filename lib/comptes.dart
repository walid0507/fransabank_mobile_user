import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'header.dart';
import 'creecompte.dart'; // Importation du header commun

class ComptesPage extends StatefulWidget {
  final String nomClient;

  const ComptesPage({Key? key, required this.nomClient}) : super(key: key);

  @override
  _ComptesPageState createState() => _ComptesPageState();
}

class _ComptesPageState extends State<ComptesPage> {
  List<String> comptes = [
    "Compte 1",
    "Compte 2",
    "Compte 3"
  ]; // Liste statique temporaire

  /*
  Future<void> _fetchComptes() async {
    const String API_BASE_URL = "https://example.com"; // Remplace par ton URL
    final url = Uri.parse('$API_BASE_URL/api/comptes?client=${widget.nomClient}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          comptes = data.map((compte) => compte['nom']).toList();
        });
      } else {
        print("Erreur lors du chargement des comptes");
      }
    } catch (error) {
      print("Erreur de connexion au serveur : $error");
    }
  }
  */

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView.builder(
                  itemCount: comptes.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        print('Compte sélectionné : ${comptes[index]}');
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          comptes[index],
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
                            builder: (context) => CreateAccountScreen()),
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

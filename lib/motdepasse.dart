import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projet1/chanmot.dart';
import 'package:projet1/home.dart';
import 'dart:convert';
import 'header.dart';
import 'creecompte.dart'; // Importation du header commun
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet1/api_service.dart';

class MotDePasseScreen extends StatelessWidget {
  final String nomClient;

  const MotDePasseScreen({Key? key, required this.nomClient}) : super(key: key);

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Changement de mot de passe",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  // Récupérer le token depuis SharedPreferences
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? token = prefs.getString('access_token');

                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Erreur: Token non trouvé"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Nettoyer l'ID du client (enlever "Client" et les espaces)
                  String cleanClientId =
                      nomClient.replaceAll('Client', '').trim();

                  // Naviguer vers l'écran de changement de mot de passe
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(
                        clientId: cleanClientId,
                        token: token,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Changer le mot de passe",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MotDePasse extends StatefulWidget {
  final String nomClient;

  const MotDePasse({Key? key, required this.nomClient}) : super(key: key);

  @override
  _MotDePasseState createState() => _MotDePasseState();
}

class _MotDePasseState extends State<MotDePasse> {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Changement de mot de passe",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  // Récupérer le token depuis SharedPreferences
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? token = prefs.getString('access_token');

                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Erreur: Token non trouvé"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Nettoyer l'ID du client (enlever "Client" et les espaces)
                  String cleanClientId =
                      widget.nomClient.replaceAll('Client', '').trim();

                  // Naviguer vers l'écran de changement de mot de passe
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(
                        clientId: cleanClientId,
                        token: token,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Changer le mot de passe",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

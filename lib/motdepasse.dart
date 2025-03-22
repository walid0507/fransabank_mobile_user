import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projet1/chanmot.dart';
import 'package:projet1/home.dart';
import 'dart:convert';
import 'header.dart';
import 'creecompte.dart'; // Importation du header commun
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet1/api_service.dart';
import 'package:projet1/configngrok.dart';
import 'package:projet1/header3.dart';

class MotDePasseScreen extends StatefulWidget {
  final String nomClient;
  const MotDePasseScreen({Key? key, required this.nomClient}) : super(key: key);

  @override
  State<MotDePasseScreen> createState() => _MotDePasseScreenState();
}

class _MotDePasseScreenState extends State<MotDePasseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header3(
            title: 'Mot de passe',
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
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

                  String cleanClientId =
                      widget.nomClient.replaceAll('Client', '').trim();

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
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }
}

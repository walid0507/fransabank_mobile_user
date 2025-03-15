import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'creecompte.dart'; // Importation de la page de création de compte
import 'main.dart'; // Importation de la page de connexion
import 'header.dart'; // Importation du header commun
import 'clientp.dart'; // Importation de la page client
import 'api_service.dart'; // Importation du service API

class ProfileScreen extends StatefulWidget {
  final String nomClient;

  const ProfileScreen({Key? key, required this.nomClient}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    String clientId = _clientIdController.text.trim();
    String password = _passwordController.text.trim();

    if (clientId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.clientSec(clientId, password);
      if (response["error"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["error"])),
        );
      } else {
        // Stocker le token et client_id dans SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", response["token"]);
        await prefs.setString("client_id", response["client_id"]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connexion réussie !")),
        );

        // Redirection vers ClientScreen après connexion
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientScreen(nomClient: widget.nomClient),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
            AppHeader(), // Utilisation du header
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Bonjour nomClient",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(height: 15),
                    _buildTextField("Numéro du compte"),
                    const SizedBox(height: 15),
                    _buildTextField("Mot de passe", obscureText: true),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ClientScreen(nomClient: widget.nomClient)),
                          );
                        },
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

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
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("Tentative de connexion avec ID: $clientId");
      final response = await ApiService.clientSec(clientId, password);
      print("Réponse reçue: $response");

      if (response["error"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: ${response["error"]}"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Sauvegarder uniquement le client_id car il n'y a pas de token
        if (response["client_id"] != null) {
          await prefs.setString("client_id", response["client_id"]);
          print("Client ID sauvegardé: ${response["client_id"]}");
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connexion réussie !"),
            backgroundColor: Colors.green,
          ),
        );

        // Attendre un court instant pour que l'utilisateur voie le message de succès
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClientScreen(
              nomClient: "Client ${response["client_id"]}",
            ),
          ),
        );
      }
    } catch (e) {
      print("Erreur de connexion détaillée: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur de connexion: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
                          loginUser(); // Appel de la méthode de connexion
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
      controller: label == "Numéro du compte"
          ? _clientIdController
          : _passwordController,
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

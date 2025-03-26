import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'creecompte.dart'; // Importation de la page de création de compte
import 'main.dart'; // Importation de la page de connexion
import 'header.dart'; // Importation du header commun
import 'clientp.dart'; // Importation de la page client
import 'api_service.dart'; // Importation du service API
import 'package:projet1/configngrok.dart';
import 'curved_header.dart'; // Ajout de l'import pour curved_header.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'comptes.dart'; // Importation de la page des comptes

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
  bool _rememberMe = false;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSavedClientId();
  }

  Future<void> _loadSavedClientId() async {
    final clientId = await _storage.read(key: 'client_id');
    final rememberMe = await _storage.read(key: 'rememberMe');

    if (clientId != null && rememberMe == 'true') {
      setState(() {
        _clientIdController.text = clientId;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveClientId() async {
    if (_rememberMe) {
      await _storage.write(key: 'client_id', value: _clientIdController.text);
      await _storage.write(key: 'rememberMe', value: 'true');
    } else {
      await _storage.delete(key: 'client_id');
      await _storage.delete(key: 'rememberMe');
    }
  }

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
          await _saveClientId();
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
      body: Stack(
        children: [
          CurvedHeader(
            height: 0.9,
            title: 'Connexion',
            onBackPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComptesPage(nomClient: widget.nomClient),
                ),
              );
            },
            child: Container(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 200),
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
                    _buildTextField("Numéro du compte"),
                    const SizedBox(height: 25),
                    _buildTextField("Mot de passe", obscureText: true),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: Color(0xFF024DA2),
                        ),
                        Text(
                          'Se souvenir de moi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          loginUser();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return TextField(
      controller: label == "Numéro du compte"
          ? _clientIdController
          : _passwordController,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
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

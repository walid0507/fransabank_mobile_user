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
import 'dart:convert';
import 'header3.dart'; // Importation du nouveau header

class ProfileScreen extends StatefulWidget {
  final String nomClient;
  final bool clearFields;

  const ProfileScreen({
    Key? key,
    required this.nomClient,
    this.clearFields = false,
  }) : super(key: key);

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
    if (!widget.clearFields) {
      _loadSavedClientId();
    }
  }

  Future<void> _loadSavedClientId() async {
    try {
      final clientId = await _storage.read(key: 'client_id');
      final rememberMe = await _storage.read(key: 'rememberMe');
      print("Chargement des données sauvegardées:");
      print("Client ID: $clientId");
      print("Remember Me: $rememberMe");

      if (clientId != null && rememberMe == 'true') {
        setState(() {
          _clientIdController.text = clientId;
          _rememberMe = true;
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des données: $e");
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
        final storage = FlutterSecureStorage();

        // Sauvegarder le client_id et le type de client
        if (response["client_id"] != null) {
          await prefs.setString("client_id", response["client_id"]);
          await storage.write(key: 'client_id', value: response["client_id"]);
          print("Client ID sauvegardé: ${response["client_id"]}");
          print("Type Client reçu: ${response["type_client"]}");

          // Si "Se souvenir de moi" est coché, sauvegarder dans la liste des comptes
          if (_rememberMe) {
            // Sauvegarder rememberMe
            await storage.write(key: 'rememberMe', value: 'true');

            // Charger les comptes existants
            final comptesJson = await storage.read(key: 'comptes_sauvegardes');
            List<Map<String, String>> comptes = [];

            if (comptesJson != null) {
              final List<dynamic> comptesList = json.decode(comptesJson);
              comptes = comptesList
                  .map((compte) => Map<String, String>.from(compte))
                  .toList();
              print("Comptes existants chargés: $comptes");
            }

            // Vérifier si le compte existe déjà
            if (!comptes
                .any((compte) => compte['id'] == response["client_id"])) {
              // Ajouter le nouveau compte avec le type_client
              final newCompte = {
                'id': response["client_id"].toString(),
                'type': (response["type_client"] ?? 'Client')
                    .toString()
                    .replaceAll('Ã§', 'ç'),
              };
              print("Nouveau compte à ajouter: $newCompte");
              comptes.add(newCompte);

              // Sauvegarder la liste mise à jour
              await storage.write(
                key: 'comptes_sauvegardes',
                value: json.encode(comptes),
              );
              print("Liste des comptes sauvegardée: $comptes");
            }
          } else {
            // Si "Se souvenir de moi" n'est pas coché, supprimer les données
            await storage.delete(key: 'rememberMe');
            await storage.delete(key: 'client_id');
          }
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
            onBackPressed: () => Navigator.pop(context),
            child: Container(),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 150),
                Center(
                  child: Text(
                    "Bonjour ${widget.nomClient}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildTextField("Numéro du compte"),
                          SizedBox(height: 12),
                          _buildTextField("Mot de passe", obscureText: true),
                          SizedBox(height: 12),
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
                          SizedBox(height: 40),
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

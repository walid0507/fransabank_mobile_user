import 'package:flutter/material.dart';
import 'header.dart'; // Importation du header personnalisé
import 'inscription.dart'; // Importation de la page d'inscription
import 'mdpoub.dart'; // Importation de la page Mot de passe oublié
import 'home.dart'; // Importation de la page d'accueil
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'verif_mail.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;
      const String API_BASE_URL = "https://xxxxx.ngrok.io";

      final url = Uri.parse('$API_BASE_URL/api/register/');
 // URL de l'API de connexion
      print("🔹 Envoi des identifiants à l'API...");

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        print("🔹 Réponse API reçue: ${response.statusCode}");
        print("🔹 Corps de la réponse: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String token = data['access']; // Récupération du token JWT

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          print("✅ Connexion réussie, Token JWT : $token");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(nomClient: email.split('@')[0]),
            ),
          );
        } else {
          print("❌ Erreur de connexion: ${response.body}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Identifiants incorrects')),
          );
        }
      } catch (error) {
        print("❌ Erreur réseau: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Problème de connexion au serveur')),
        );
      }
    }
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangerMotDePasse()),
    );
  }

  void _navigateToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Inscription()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade300],
          ),
        ),
        child: Column(
          children: [
            AppHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          if (value.length < 8) {
                            return 'Le mot de passe doit contenir au moins 8 caractères';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.0),
                      TextButton(
                        onPressed: _navigateToForgotPassword,
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToCreateAccount,
                        child: Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text('Se connecter'),
                      ),
                    ],
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
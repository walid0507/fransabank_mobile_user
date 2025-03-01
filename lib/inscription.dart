import 'package:flutter/material.dart';
import 'header.dart';
import 'home.dart'; // Importe la page ProfileScreen
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showMessage("Les mots de passe ne correspondent pas.");
        return;
      }

      final url = Uri.parse(
          'http://127.0.0.1:8000/api/register/'); // URL de l'API d'inscription
      final body = jsonEncode({
        'username':
            _emailController.text, // Utilisez l'email comme nom d'utilisateur
        'email': _emailController.text,
        'password': _passwordController.text,
        'password2': _confirmPasswordController.text, // Ajoutez ce champ
        'first_name': _prenomController.text,
        'last_name': _nomController.text,
      });

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 201) {
          _showMessage("Inscription réussie !");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                nomClient: _prenomController.text,
              ),
            ),
          );
        } else {
          final data = jsonDecode(response.body);
          print(
              "Erreur API: ${response.statusCode}, ${response.body}"); // Affichez l'erreur
          _showMessage(data['error'] ?? "Erreur lors de l'inscription");
        }
      } catch (error) {
        _showMessage("Erreur réseau: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade300,
              ],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              AppHeader(),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      _buildTextField(Icons.account_circle, "Votre nom", "Nom",
                          _nomController),
                      SizedBox(height: 20),
                      _buildTextField(Icons.account_circle, "Votre prénom",
                          "Prénom", _prenomController),
                      SizedBox(height: 20),
                      _buildTextField(
                          Icons.mail, "Votre mail", "E-mail", _emailController),
                      SizedBox(height: 20),
                      _buildTextField(Icons.lock, "Votre mot de passe",
                          "Créer un mot de passe", _passwordController,
                          isPassword: true),
                      SizedBox(height: 20),
                      _buildTextField(
                          Icons.lock,
                          "Confirmez",
                          "Confirmez votre mot de passe",
                          _confirmPasswordController,
                          isPassword: true),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text("S'inscrire"),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child:
                                  Divider(thickness: 0.5, color: Colors.white)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Nous contacter",
                                style: TextStyle(color: Colors.white)),
                          ),
                          Expanded(
                              child:
                                  Divider(thickness: 0.5, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showMessage("021 99 92 04"),
                    child: _buildIconContainer("assets/images/telephone.png"),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => _showMessage("info@fransabank.dz"),
                    child: _buildIconContainer("assets/images/mail.png"),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hintText, String labelText,
      TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        labelText: labelText,
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire';
        }
        if (labelText.contains("mail") && !value.contains('@')) {
          return 'Veuillez entrer un email valide';
        }
        if (labelText.contains("mot de passe") && value.length < 8) {
          return 'Le mot de passe doit contenir au moins 8 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildIconContainer(String assetPath) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey,
      ),
      child: Image.asset(
        assetPath,
        height: 20,
      ),
    );
  }
}

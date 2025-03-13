import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'verif_mail.dart';
import 'header.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
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

      const String API_BASE_URL = "https://87a5-105-100-214-164.ngrok-free.app";
      final url = Uri.parse('$API_BASE_URL/api/register/');

      final body = jsonEncode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password2': _confirmPasswordController.text,
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
          _showMessage("Inscription réussie ! Vérifiez votre email.");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EmailVerificationScreen(email: _emailController.text),
            ),
          );
        } else {
          final data = jsonDecode(response.body);
          _showMessage(data['error'] ?? "Erreur lors de l'inscription.");
        }
      } catch (error) {
        _showMessage("Erreur réseau : $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppHeader(),
              Padding(
                padding: EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(Icons.person, "Nom d'utilisateur",
                          _usernameController),
                      SizedBox(height: 16.0),
                      _buildTextField(
                          Icons.account_circle, "Nom", _nomController),
                      SizedBox(height: 20),
                      _buildTextField(
                          Icons.account_circle, "Prénom", _prenomController),
                      SizedBox(height: 20),
                      _buildTextField(Icons.mail, "E-mail", _emailController),
                      SizedBox(height: 20),
                      _buildTextField(Icons.lock, "Créer un mot de passe",
                          _passwordController,
                          isPassword: true),
                      SizedBox(height: 20),
                      _buildTextField(
                          Icons.lock,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String labelText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
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
}

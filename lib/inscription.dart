import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'verif_mail.dart';
import 'header.dart';
import 'main.dart';
import 'package:projet1/configngrok.dart';
import 'curved_header.dart';

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
  bool _areFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkFields);
    _nomController.addListener(_checkFields);
    _prenomController.addListener(_checkFields);
    _emailController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
    _confirmPasswordController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_checkFields);
    _nomController.removeListener(_checkFields);
    _prenomController.removeListener(_checkFields);
    _emailController.removeListener(_checkFields);
    _passwordController.removeListener(_checkFields);
    _confirmPasswordController.removeListener(_checkFields);
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      _areFieldsFilled = _usernameController.text.isNotEmpty &&
          _nomController.text.isNotEmpty &&
          _prenomController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

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

      final url = Uri.parse('${Config.baseApiUrl}/api/register/');

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

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire';
        }
        if (hintText.contains("mail") && !value.contains('@')) {
          return 'Veuillez entrer un email valide';
        }
        if (hintText.contains("mot de passe") && value.length < 8) {
          return 'Le mot de passe doit contenir au moins 8 caractères';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CurvedHeader(
            height: 0.9,
            title: 'Inscription',
            onBackPressed: () => Navigator.pop(context),
            child: Container(),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/images/fransa2bk.png',
                    width: 130,
                    height: 130,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField("Nom d'utilisateur", _usernameController),
                            SizedBox(height: 12),
                            _buildTextField("Nom", _nomController),
                            SizedBox(height: 12),
                            _buildTextField("Prénom", _prenomController),
                            SizedBox(height: 12),
                            _buildTextField("Email", _emailController),
                            SizedBox(height: 12),
                            _buildTextField("Mot de passe", _passwordController, isPassword: true),
                            SizedBox(height: 12),
                            _buildTextField("Confirmer le mot de passe", _confirmPasswordController, isPassword: true),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: _areFieldsFilled ? 20 : -100,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _areFieldsFilled ? 1.0 : 0.0,
              child: Center(
                child: Container(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: _areFieldsFilled ? _submit : null,
                    child: Text(
                      "S'INSCRIRE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

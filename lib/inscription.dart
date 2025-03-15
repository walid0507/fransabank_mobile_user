import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'verif_mail.dart';
import 'header.dart';
import 'main.dart';

class InvertedCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Point de départ
    path.lineTo(0, size.height * 0.90);

    // Première courbe
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.95,
        size.width * 0.25, size.height * 0.95);

    // Deuxième courbe
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.95, size.width, size.height * 0.85);

    // Compléter le chemin
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

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
    // Ajouter des listeners à tous les contrôleurs
    _usernameController.addListener(_checkFields);
    _nomController.addListener(_checkFields);
    _prenomController.addListener(_checkFields);
    _emailController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
    _confirmPasswordController.addListener(_checkFields);
  }

  @override
  void dispose() {
    // Nettoyer les listeners
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

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
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
    Color primaryBlue = Color(0xFF024DA2);

    return Scaffold(
      body: Stack(
        children: [
          // Bouton retour en haut à gauche
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LoginScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 300),
                ),
              ),
            ),
          ),

          // Partie supérieure avec découpage inversé
          ClipPath(
            clipper: _areFieldsFilled ? InvertedCurvedClipper() : null,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: primaryBlue,
                image: DecorationImage(
                  image: AssetImage('assets/images/stars.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    primaryBlue.withOpacity(0.9),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        Image.asset(
                          'assets/images/fransa2bk.png',
                          width: 130,
                          height: 130,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Création de compte',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Column(
                            children: [
                              _buildTextField(
                                  "Nom d'utilisateur", _usernameController),
                              SizedBox(height: 12),
                              _buildTextField("Nom", _nomController),
                              SizedBox(height: 12),
                              _buildTextField("Prénom", _prenomController),
                              SizedBox(height: 12),
                              _buildTextField("Email", _emailController),
                              SizedBox(height: 12),
                              _buildTextField(
                                  "Mot de passe", _passwordController,
                                  isPassword: true),
                              SizedBox(height: 12),
                              _buildTextField("Confirmer le mot de passe",
                                  _confirmPasswordController,
                                  isPassword: true),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bouton d'inscription en bas à droite avec animation
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: _areFieldsFilled
                ? 20
                : -100, // Cache le bouton s'il n'est pas visible
            right: 20,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _areFieldsFilled ? 1.0 : 0.0,
              child: Container(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: _areFieldsFilled ? _submit : null,
                  child: Text(
                    "S'INSCRIRE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
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

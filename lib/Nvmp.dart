import 'package:flutter/material.dart';
import 'curved_header.dart';
import 'package:projet1/configngrok.dart';

class Nvmp extends StatefulWidget {
  const Nvmp({super.key});

  @override
  State<Nvmp> createState() => _NvmpState();
}

class _NvmpState extends State<Nvmp> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _validerMotDePasse() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mot de passe changé avec succès !")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          CurvedHeader(
            title: "Nouveau mot de passe",
            onBackPressed: () => Navigator.pop(context),
            backgroundColor: Colors.blue.shade900,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Padding(
                    padding: EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 50),
                          _buildPasswordField(
                              _passwordController, "Nouveau mot de passe"),
                          SizedBox(height: 30),
                          _buildConfirmPasswordField(_confirmPasswordController,
                              "Confirmez le nouveau mot de passe"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _validerMotDePasse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "Valider",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.blue.shade900),
        labelText: label,
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.blue.shade900),
        hintStyle: TextStyle(color: Colors.blue.shade900.withOpacity(0.5)),
      ),
      style: TextStyle(color: Colors.blue.shade900),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Veuillez entrer un mot de passe";
        }
        if (value.length < 6) {
          return "Le mot de passe doit contenir au moins 6 caractères";
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(
      TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.blue.shade900),
        labelText: label,
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.blue.shade900),
        hintStyle: TextStyle(color: Colors.blue.shade900.withOpacity(0.5)),
      ),
      style: TextStyle(color: Colors.blue.shade900),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Veuillez confirmer votre mot de passe";
        }
        if (value != _passwordController.text) {
          return "Les mots de passe ne correspondent pas";
        }
        return null;
      },
    );
  }
}

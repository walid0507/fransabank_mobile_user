import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'header.dart'; // Importation du header commun

class ChangePasswordScreen extends StatefulWidget {
  final String clientId;
  final String token;

  const ChangePasswordScreen({
    Key? key,
    required this.clientId,
    required this.token,
  }) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.changePassword(
        widget.clientId,
        _oldPasswordController.text,
        _newPasswordController.text,
        _confirmPasswordController.text,
        widget.token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Un email de confirmation a été envoyé. Veuillez vérifier votre boîte de réception."),
          backgroundColor: Colors.green,
        ),
      );

      // Attendre un court instant pour que l'utilisateur voie le message
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      String messageErreur =
          "Une erreur est survenue lors du changement de mot de passe.";
      if (e.toString().contains("400")) {
        if (e.toString().contains("ancien mot de passe")) {
          messageErreur = "Ancien mot de passe incorrect.";
        } else if (e.toString().contains("ne correspondent pas")) {
          messageErreur =
              "Le nouveau mot de passe et la confirmation ne correspondent pas.";
        } else if (e.toString().contains("8 caractères")) {
          messageErreur =
              "Le nouveau mot de passe doit contenir au moins 8 caractères.";
        } else {
          messageErreur = "Veuillez fournir tous les champs requis.";
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messageErreur),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade300, Colors.blue.shade900],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppHeader(),
                    const SizedBox(height: 20),
                    Text(
                      "Changement de mot de passe",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildPasswordField(
                      controller: _oldPasswordController,
                      label: "Ancien mot de passe",
                      obscureText: _obscureOldPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureOldPassword = !_obscureOldPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: "Nouveau mot de passe",
                      obscureText: _obscureNewPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: "Confirmer le nouveau mot de passe",
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildButton(
                        context, "Changer le mot de passe", _changePassword),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
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
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Ce champ est obligatoire";
        }
        if (label.contains("Nouveau") && value.length < 8) {
          return "Le mot de passe doit contenir au moins 8 caractères";
        }
        if (label.contains("Confirmer") &&
            value != _newPasswordController.text) {
          return "Les mots de passe ne correspondent pas";
        }
        return null;
      },
    );
  }

  Widget _buildButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

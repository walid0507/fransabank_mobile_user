import 'package:flutter/material.dart';
import 'curved_header.dart';
import 'Nvmp.dart';
import 'package:projet1/configngrok.dart';
import 'package:projet1/api_service.dart';
import 'package:projet1/documents.dart';

class ChangerMotDePasse extends StatefulWidget {
  const ChangerMotDePasse({super.key});

  @override
  State<ChangerMotDePasse> createState() => _ChangerMotDePasseState();
}

class _ChangerMotDePasseState extends State<ChangerMotDePasse> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _email;
  bool _showCodeInput = false;
  bool _showPasswordInput = false;
  bool _isLoading = false;

  void _requestResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      await ApiService.requestPasswordReset(email);
      setState(() {
        _email = email;
        _showCodeInput = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Code de confirmation envoyé à $email"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = "Une erreur est survenue";
      if (e.toString().contains("email")) {
        errorMessage = "Aucun compte n'est associé à cet email";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.verifyResetCode(_email!, _codeController.text);
      setState(() {
        _showPasswordInput = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.resetPassword(
        _email!,
        _codeController.text,
        _newPasswordController.text,
      );
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mot de passe réinitialisé avec succès")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
            title: "Mot de passe oublié",
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
                          if (!_showCodeInput && !_showPasswordInput) ...[
                            _buildEmailField(),
                            SizedBox(height: 30),
                            _buildModernButton(
                              text: "Recevoir le code",
                              onPressed: _requestResetCode,
                              isEnabled: !_isLoading,
                            ),
                          ],
                          if (_showCodeInput && !_showPasswordInput) ...[
                            _buildCodeField(),
                            SizedBox(height: 30),
                            _buildModernButton(
                              text: "Vérifier le code",
                              onPressed: _verifyCode,
                              isEnabled: !_isLoading,
                            ),
                          ],
                          if (_showPasswordInput) ...[
                            _buildNewPasswordField(),
                            SizedBox(height: 20),
                            _buildConfirmPasswordField(),
                            SizedBox(height: 30),
                            _buildModernButton(
                              text: "Réinitialiser le mot de passe",
                              onPressed: _resetPassword,
                              isEnabled: !_isLoading,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email, color: Colors.blue.shade900),
        labelText: "Email",
        hintText: "Entrez votre email",
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
          return "Veuillez entrer votre email";
        }
        if (!value.contains('@')) {
          return "Email invalide";
        }
        return null;
      },
    );
  }

  Widget _buildCodeField() {
    return TextFormField(
      controller: _codeController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.security, color: Colors.blue.shade900),
        // labelText: "Code de confirmation",
        hintText: "Entrez le code reçu par email",
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
        // suffixIcon: Icon(Icons.email, color: Colors.blue.shade900),
      ),
      style: TextStyle(color: Colors.blue.shade900),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Veuillez entrer le code";
        }
        if (value.length != 6) {
          return "Le code doit contenir 6 chiffres";
        }
        return null;
      },
    );
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.blue.shade900),
        labelText: "Nouveau mot de passe",
        hintText: "Entrez votre nouveau mot de passe",
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
        if (value.length < 8) {
          return "Le mot de passe doit contenir au moins 8 caractères";
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.blue.shade900),
        labelText: "Confirmer le mot de passe",
        hintText: "Confirmez votre nouveau mot de passe",
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
        if (value != _newPasswordController.text) {
          return "Les mots de passe ne correspondent pas";
        }
        return null;
      },
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'curved_header.dart';
import 'Nvmp.dart';
import 'package:projet1/configngrok.dart';

class ChangerMotDePasse extends StatefulWidget {
  const ChangerMotDePasse({super.key});

  @override
  State<ChangerMotDePasse> createState() => _ChangerMotDePasseState();
}

class _ChangerMotDePasseState extends State<ChangerMotDePasse> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _validerCode() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Nvmp()),
      );
    }
  }

  void _recevoirCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Code de confirmation envoyé !")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          CurvedHeader(
            title: "Changer le mot de passe",
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _recevoirCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade900,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                "Recevoir le code de confirmation",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          _buildCodeField(
                              _codeController, "Code de confirmation"),
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
                  onPressed: _validerCode,
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

  Widget _buildCodeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
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
          return "Veuillez entrer le code de confirmation";
        }
        return null;
      },
    );
  }
}

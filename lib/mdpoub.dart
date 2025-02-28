import 'package:flutter/material.dart';
import 'header.dart';
import 'Nvmp.dart';

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
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _recevoirCode,
                          child: Text("Recevoir le code de confirmation"),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildCodeField(_codeController, "Code de confirmation"),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _validerCode,
                          child: Text("Valider"),
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

  Widget _buildCodeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Veuillez entrer le code de confirmation";
        }
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'header.dart';
import 'home.dart'; // Importe la page ProfileScreen

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      _buildTextField(Icons.account_circle, "Votre nom", "Nom"),
                      SizedBox(height: 20),
                      _buildTextField(
                          Icons.account_circle, "Votre prénom", "Prénom"),
                      SizedBox(height: 20),
                      _buildTextField(Icons.mail, "Votre mail", "E-mail"),
                      SizedBox(height: 20),
                      _buildTextField(Icons.lock, "Votre mot de passe",
                          "Créer un mot de passe"),
                      SizedBox(height: 20),
                      _buildTextField(Icons.lock, "Confirmez",
                          "Confirmez votre mot de passe"),
                      SizedBox(height: 20),
                      _buildTextField(Icons.phone, "Votre numéro de téléphone",
                          "Numéro de téléphone"),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Redirection vers ProfileScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  nomClient: "Nom du Client", // Remplace par la valeur du formulaire
                                ),
                              ),
                            );
                          },
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

  Widget _buildTextField(IconData icon, String hintText, String labelText) {
    return TextFormField(
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
import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget {
  final Widget body;
  final String title;

  const CommonHeader({Key? key, required this.body, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fond transparent
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade800, // Début du dégradé
                Colors.blue.shade500, // Fin du dégradé
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/image003.jpeg',
          width: 250,
          height: 80,
          fit: BoxFit.contain,
          // Retirez la couleur pour afficher le logo dans sa couleur d'origine
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800, // Début du dégradé
              Colors.blue.shade500, // Fin du dégradé
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: body,
          ),
        ),
      ),
    );
  }
}
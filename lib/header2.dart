import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget {
  final Widget body;
  final String title;

  const CommonHeader({
    Key? key,
    required this.body,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/image003.jpeg', // Assurez-vous que cette image existe
          width: 250,
          height: 80,
          fit: BoxFit.contain,
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
        // Ajout d'un Padding en haut pour décaler le contenu vers le bas
        child: Padding(
          padding: const EdgeInsets.only(
              top: 50.0), // Ajustez cette valeur selon vos besoins
          child: body,
        ),
      ),
    );
  }
}

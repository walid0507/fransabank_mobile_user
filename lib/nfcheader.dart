import 'package:flutter/material.dart';

class CurvedHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;
  final Color backgroundColor;
  final Widget child;

  const CurvedHeader({
    Key? key,
    required this.title,
    required this.onBackPressed,
    required this.backgroundColor,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond bleu avec image des étoiles
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              image: const DecorationImage(
                image: AssetImage('assets/images/stars.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),
          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Barre de titre
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: onBackPressed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Contenu défilant
                Expanded(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

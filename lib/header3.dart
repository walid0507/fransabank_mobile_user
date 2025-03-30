import 'package:flutter/material.dart';

class Header3 extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLogoutPressed;
  final IconData? icon;

  const Header3({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.onLogoutPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Container principal avec le dégradé
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF1E40AF),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Effets décoratifs subtils
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                    ),
                  ),
                ),
              ),
              // Contenu principal
              SafeArea(
                child: Stack(
                  children: [
                    // Image centrée avec effet de lueur
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.15),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/fransa2bk.png',
                          height: 120,
                          width: 120,
                        ),
                      ),
                    ),
                    // Titre et flèche à gauche
                    Positioned(
                      left: 0,
                      top: 20,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onBackPressed != null)
                            IconButton(
                              icon: Icon(
                                icon ?? Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: onBackPressed,
                            ),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Icône de déconnexion à droite
                    if (onLogoutPressed != null)
                      Positioned(
                        right: 10,
                        top: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                          ),
                          onPressed: onLogoutPressed,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Ligne de séparation moderne
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(double.infinity, 30),
            painter: ModernPainter(
              color: Colors.white,
              height: 30,
            ),
          ),
        ),
      ],
    );
  }
}

class ModernPainter extends CustomPainter {
  final Color color;
  final double height;

  ModernPainter({
    required this.color,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(0, height);

    // Création d'une courbe douce
    path.quadraticBezierTo(
      width * 0.25,
      height * 0.5,
      width * 0.5,
      height * 0.3,
    );
    path.quadraticBezierTo(
      width * 0.75,
      height * 0.1,
      width,
      height * 0.4,
    );

    path.lineTo(width, height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

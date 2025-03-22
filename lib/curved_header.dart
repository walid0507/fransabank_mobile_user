import 'package:flutter/material.dart';

class CurvedHeader extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final String backgroundImage;
  final double height;

  const CurvedHeader({
    Key? key,
    required this.child,
    this.backgroundColor = const Color(0xFF024DA2),
    this.backgroundImage = 'assets/images/stars.jpg',
    this.height = 0.9,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: InvertedCurvedClipper(),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * height,
        decoration: BoxDecoration(
          color: backgroundColor,
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              backgroundColor.withOpacity(0.9),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

class InvertedCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Point de départ
    path.lineTo(0, size.height * 0.80);

    // Première courbe
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.85,
        size.width * 0.25, size.height * 0.85);

    // Deuxième courbe
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.85, size.width, size.height * 0.60);

    // Compléter le chemin
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

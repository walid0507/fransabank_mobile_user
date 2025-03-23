import 'package:flutter/material.dart';

class CurvedHeader extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final String backgroundImage;
  final double height;
  final String title;
  final VoidCallback onBackPressed;
  final TextStyle? titleStyle;

  const CurvedHeader({
    Key? key,
    required this.child,
    required this.title,
    required this.onBackPressed,
    this.backgroundColor = const Color(0xFF024DA2),
    this.backgroundImage = 'assets/images/stars.jpg',
    this.height = 0.9,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 16),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: onBackPressed,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          title,
                          style: titleStyle ?? TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ],
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

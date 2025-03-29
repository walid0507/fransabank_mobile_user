import 'package:flutter/material.dart';

class CurvedHeader extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final String backgroundImage;
  final double height;
  final String title;
  final VoidCallback onBackPressed;
  final TextStyle? titleStyle;
  final IconData? icon;

  const CurvedHeader({
    Key? key,
    required this.child,
    required this.title,
    required this.onBackPressed,
    this.backgroundColor = const Color(0xFF024DA2),
    this.backgroundImage = 'assets/images/stars.jpg',
    this.height = 0.9,
    this.titleStyle,
    this.icon,
  }) : super(key: key);

  @override
  State<CurvedHeader> createState() => _CurvedHeaderState();
}

class _CurvedHeaderState extends State<CurvedHeader> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: InvertedCurvedClipper(),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              image: DecorationImage(
                image: AssetImage(widget.backgroundImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  widget.backgroundColor.withOpacity(0.9),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onBackPressed != null)
                          GestureDetector(
                            onTapDown: (_) => setState(() => _isPressed = true),
                            onTapUp: (_) => setState(() => _isPressed = false),
                            onTapCancel: () =>
                                setState(() => _isPressed = false),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              transform: Matrix4.identity()
                                ..scale(_isPressed ? 0.8 : 1.0)
                                ..rotateZ(_isPressed ? -0.1 : 0.0),
                              child: IconButton(
                                icon: Icon(
                                  widget.icon ?? Icons.arrow_back,
                                  color: _isPressed
                                      ? Colors.blue[200]
                                      : Colors.white,
                                  size: _isPressed ? 28 : 24,
                                ),
                                onPressed: widget.onBackPressed,
                              ),
                            ),
                          ),
                        Text(
                          widget.title,
                          style: widget.titleStyle ??
                              TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: widget.child),
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

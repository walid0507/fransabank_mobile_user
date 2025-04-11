import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<Offset> _fallingMotion;
  late Animation<double> _horizontalFade;
  late Animation<double> _globalFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _rotation = Tween<double>(
      begin: -0.4,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)));

    _fallingMotion = Tween<Offset>(
      begin: const Offset(0, -2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.bounceOut)));

    _horizontalFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)));

    _globalFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)));

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) =>  LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildFadingLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withOpacity(_horizontalFade.value),
                Colors.transparent,
              ],
              stops: const [0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/fransa5.png',
        width: 180,
        height: 180,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SlideTransition(
          position: _fallingMotion,
          child: RotationTransition(
            turns: _rotation,
            child: FadeTransition(
              opacity: _globalFade,
              child: buildFadingLogo(),
            ),
          ),
        ),
      ),
    );
  }
}

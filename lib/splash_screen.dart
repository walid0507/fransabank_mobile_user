import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isDisposed = false;
  bool _showWhiteScreen = false;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/images/splashscreen.mp4',
    )
      ..initialize().then((_) {
        if (!_isDisposed) {
          setState(() {});
          _isVideoReady = true;
          _controller.play();
        }
      })
      ..setVolume(0.0);

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        if (!_isDisposed) {
          // Première transition : fondu vers blanc
          setState(() {
            _showWhiteScreen = true;
          });

          // Attendre puis lancer la transition vers LoginScreen
          Future.delayed(Duration(milliseconds: 1000), () {
            if (!_isDisposed) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LoginScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1.2, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutQuart,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: Duration(milliseconds: 1500),
                ),
              );
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🌟 Fond blanc au lieu d'un écran noir
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1️⃣ Fond blanc tant que la vidéo n'est pas prête
          if (!_isVideoReady) Container(color: Colors.white),

          // 2️⃣ Affiche la vidéo quand elle est prête
          if (_isVideoReady)
            Center(
              child: Transform.translate(
                offset: Offset(0, -30), // Réduction de l'offset à -50 pixels
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

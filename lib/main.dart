import 'package:flutter/material.dart';
import 'package:projet1/comptes.dart';
import 'header.dart';
import 'inscription.dart';
import 'mdpoub.dart'; // Mot de passe oublié
import 'home.dart'; // Page d'accueil
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'verif_mail.dart';
import 'clientp.dart'; // Page de vérification d'email
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showWelcome = false;

  @override
  void initState() {
    super.initState();
    // Déclencher l'animation après 2 secondes
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showWelcome = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text;
    const String API_BASE_URL = "https://8c45-41-220-151-61.ngrok-free.app";

    final url = Uri.parse('$API_BASE_URL/api/login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        bool emailVerifie = data['email_verified'] ?? false;

        if (!emailVerifie) {
          _showMessage(
            "Veuillez vérifier votre email avant de vous connecter.",
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(email: email),
            ),
          );
          return;
        }

        String token = data['access'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        print("✅ Connexion réussie, Token JWT : $token");
        _showMessage("Connexion réussie", isError: false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ComptesPage(nomClient: email.split('@')[0]),
          ),
        );
      } else {
        _showMessage(data['error'] ?? "Identifiants incorrects");
      }
    } catch (error) {
      _showMessage("Problème de connexion au serveur");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryBlue = Color(0xFF024DA2);

    return Scaffold(
      body: Stack(
        children: [
          // Partie supérieure avec découpage inversé
          ClipPath(
            clipper: InvertedCurvedClipper(),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: primaryBlue,
                image: DecorationImage(
                  image: AssetImage('assets/images/stars.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    primaryBlue.withOpacity(0.9),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      AnimatedCrossFade(
                        duration: Duration(milliseconds: 1500),
                        firstChild: Text(
                          'Tomorrow Starts Now',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        secondChild: Text(
                          'Welcome to Fransabank!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        crossFadeState: _showWelcome
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                      ),
                      SizedBox(height: 20),
                      Image.asset(
                        'assets/images/fransa2bk.png',
                        width: 160,
                        height: 160,
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Username or Email',
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangerMotDePasse(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Partie inférieure
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "LOG IN",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to Bank Apps? ',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      Inscription(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOutCubic;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                              transitionDuration: Duration(milliseconds: 500),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

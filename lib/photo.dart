import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'signature.dart';
import 'dart:typed_data';
import 'shared_data.dart';

class Photo extends StatefulWidget {
  const Photo({super.key});

  @override
  State<Photo> createState() => _PhotoState();
}

class _PhotoState extends State<Photo> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool get _hasNfcImage => SharedData.imageData != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: isEnabled ? onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: width ?? 200,
          height: height ?? 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    // Empêcher de choisir une image si une image NFC existe
    if (_hasNfcImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez utiliser la photo récupérée depuis votre carte d\'identité'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imagenfc = SharedData.imageData;
    Color primaryBlue = Color(0xFF024DA2);

    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: InvertedCurvedClipper(),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
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
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Text(
                    'Ajoutez votre photo d\'identité',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.97),
                          Colors.white.withOpacity(0.92),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          spreadRadius: 0,
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.08),
                          spreadRadius: -1,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: primaryBlue.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87.withOpacity(0.9),
                              ),
                              children: [
                                TextSpan(
                                  text: _hasNfcImage
                                      ? 'Photo récupérée depuis votre carte d\'identité\n'
                                      : 'Ajoutez votre photo d\'identité depuis votre galerie\n',
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                    color: primaryBlue.withOpacity(0.9),
                                  ),
                                ),
                                TextSpan(
                                  text: _hasNfcImage
                                      ? 'Cette photo a été récupérée automatiquement depuis votre carte d\'identité et sera utilisée pour votre demande'
                                      : 'Si vous avez utilisé la fonction de scan NFC, votre photo a été automatiquement récupérée depuis votre carte d\'identité',
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    color: Colors.black87.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Si une photo NFC existe, on l'affiche directement
                      if (_hasNfcImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            imagenfc!,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        )
                      // Si pas de photo NFC et pas d'image sélectionnée, on affiche l'interface pour ajouter une photo
                      else if (_selectedImage == null)
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryBlue.withOpacity(0.7),
                                width: 2.5,
                              ),
                              borderRadius: BorderRadius.circular(35),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  spreadRadius: -2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/images/photo.json',
                                  height: 160,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 15),
                                Text('Ajouter une photo d\'identité',
                                    style: TextStyle(
                                      color: primaryBlue.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    )),
                              ],
                            ),
                          ),
                        )
                      // Si une image a été sélectionnée (et pas de photo NFC), on affiche l'image sélectionnée
                      else
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImage!,
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildModernButton(
                              text: 'Changer la photo',
                              onPressed: _pickImage,
                              icon: Icons.photo_camera,
                              width: 200,
                            ),
                          ],
                        ),
                      SizedBox(height: 20),
                      _buildModernButton(
                        text: 'Soumettre',
                        onPressed: () async {
                          try {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? demandeIdStr =
                                prefs.getString('demande_id');
                            int? demandeId = demandeIdStr != null
                                ? int.parse(demandeIdStr)
                                : null;

                            if (demandeId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Erreur: ID de demande non trouvé')),
                              );
                              return;
                            }

                            // Afficher un indicateur de chargement
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            // Si nous avons une image NFC, convertir en File temporaire pour l'upload
                            if (_hasNfcImage) {
                              // Créer un fichier temporaire depuis les données d'image NFC
                              final tempDir = await Directory.systemTemp.createTemp();
                              final tempFile = File('${tempDir.path}/nfc_photo.jpg');
                              await tempFile.writeAsBytes(imagenfc!);
                              
                              await ApiService.uploadPhoto(tempFile, demandeId);
                            } else if (_selectedImage != null) {
                              await ApiService.uploadPhoto(_selectedImage!, demandeId);
                            } else {
                              // Fermer l'indicateur de chargement
                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Veuillez sélectionner une photo'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Fermer l'indicateur de chargement
                            Navigator.pop(context);

                            // Afficher un message de succès
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Photo téléchargée avec succès')),
                            );

                            // Naviguer vers la page suivante
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignaturePage(),
                              ),
                            );
                          } catch (e) {
                            // Fermer l'indicateur de chargement s'il est encore ouvert
                            Navigator.of(context).pop();

                            // Afficher l'erreur
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Erreur lors du téléchargement: $e')),
                            );
                          }
                        },
                        isEnabled: _hasNfcImage || _selectedImage != null,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InvertedCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.90);
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.95,
        size.width * 0.25, size.height * 0.95);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.95, size.width, size.height * 0.85);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
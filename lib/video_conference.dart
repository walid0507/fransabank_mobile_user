import 'package:flutter/material.dart';
import 'package:projet1/configngrok.dart';
import 'package:projet1/api_service.dart';
import 'dart:ui'; // Pour ImageFilter
import 'package:projet1/header3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoConferencePage extends StatefulWidget {
  @override
  _VideoConferencePageState createState() => _VideoConferencePageState();
}

class _VideoConferencePageState extends State<VideoConferencePage>
    with SingleTickerProviderStateMixin {
    
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> conferences = [];

  Future<void> loadConferences() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final confs = await ApiService.getVideoConferences();
      setState(() {
        conferences = confs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du chargement des conférences: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Color getCardColor(String status, String clientDecision, DateTime scheduledDate) {
    // Si la date est dépassée de plus de 30 minutes
    if (DateTime.now().difference(scheduledDate).inMinutes > 30) {
      return Color(0xFF757575); // Gris pour expiré
    }

    // Si le client a déjà pris une décision
    if (clientDecision != 'pending') {
      switch (clientDecision) {
        case 'accepted':
          return Color(0xFF2E7D32); // Vert pour accepté
        case 'refused':
          return Color(0xFF757575); // Gris pour refusé
        default:
          return Color(0xFF757575); // Gris par défaut
      }
    }

    // Si le client n'a pas encore pris de décision
    return Color(0xFF1976D2); // Bleu pour en attente
  }

  Color getGradientColor(Color baseColor) {
    if (baseColor == Color(0xFF757575)) {
      return HSLColor.fromColor(baseColor)
          .withLightness(HSLColor.fromColor(baseColor).lightness * 1.1)
          .toColor();
    } else {
      return HSLColor.fromColor(baseColor)
          .withLightness(HSLColor.fromColor(baseColor).lightness * 1.3)
          .toColor();
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Acceptée';
      default:
        return 'Expirée';
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle_outline;
      default:
        return Icons.event_busy;
    }
  }

  void markConferenceAsExpired(Map<String, dynamic> conf) {
    setState(() {
      final index = conferences.indexOf(conf);
      if (index != -1) {
        conferences[index]['status'] = 'expired';
        conferences[index]['date'] = DateTime.now().subtract(Duration(days: 1));
      }
    });
  }
  void _launchURL(String url) async {
  Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw "Impossible d'ouvrir le lien : $url";
  }
}


  void showConferenceDetails(Map<String, dynamic> conf) {
    final DateTime scheduledDate = DateTime.parse(conf['scheduled_at']);
    final String formattedTime = "${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}";

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec le titre
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade200.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.videocam, color: Colors.blue.shade900, size: 24),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conf['titre'] ?? 'Sans titre',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Le ${scheduledDate.toLocal().toString().split(' ')[0]} à $formattedTime",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Informations principales avec des icônes
                    _buildInfoRow(Icons.person, "Employé", "${conf['employe_prenom']} ${conf['employe_nom']}"),
                    _buildInfoRow(Icons.calendar_today, "Date", scheduledDate.toLocal().toString().split(' ')[0]),
                    _buildInfoRow(Icons.access_time, "Heure", formattedTime),
                    _buildInfoRow(Icons.info_outline, "Statut", getStatusText(conf['status'] ?? 'pending')),
                    _buildInfoRow(Icons.assignment_turned_in, "Décision client", getStatusText(conf['client_decision'] ?? 'pending')),
                    SizedBox(height: 20),

                    // Lien de la réunion avec un design moderne
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100.withOpacity(0.5),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.link, color: Colors.blue.shade900, size: 20),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Lien de la réunion",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          if (conf['meeting_url'] != null && conf['meeting_url'].isNotEmpty)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _launchURL(conf['meeting_url']),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conf['meeting_url'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue.shade700,
                                            decoration: TextDecoration.underline,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.shade200.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.open_in_new, color: Colors.blue.shade700, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Disponible quand la réunion commencera",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Bouton Fermer
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Fermer',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Boutons Accepter et Refuser
                if (conf['client_decision'] == 'pending')
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await ApiService.repondreVisio(conf['id'].toString(), 'accepted');
                            Navigator.pop(context);
                            // Recharger la liste des conférences
                            loadConferences();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Conférence acceptée"),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 20),
                            SizedBox(width: 8),
                            Text('Accepter'),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await ApiService.repondreVisio(conf['id'].toString(), 'refused');
                            Navigator.pop(context);
                            // Afficher le dialogue de reprogrammation ou annulation
                            showReprogramOrCancelDialog(conf);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, size: 20),
                            SizedBox(width: 8),
                            Text('Refuser'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade900, size: 20),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showReprogramOrCancelDialog(Map<String, dynamic> conf) {
    TextEditingController titleController = TextEditingController();
    TextEditingController subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Que souhaitez-vous faire ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choisissez si vous souhaitez reprogrammer la réunion ou l\'annuler définitivement.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Titre de la nouvelle demande',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: subtitleController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Détails de la nouvelle demande',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty || subtitleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Veuillez remplir le formulaire avant de reprogrammer la visioconférence'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await ApiService.reprogrammerVisio(
                        conf['id'].toString(),
                        titleController.text,
                        subtitleController.text,
                      );
                      Navigator.pop(context);
                      loadConferences();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('La réunion a été reprogrammée'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Reprogrammer'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ApiService.annulerTotalementVisio(conf['id'].toString());
                      Navigator.pop(context);
                      loadConferences();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('La réunion a été annulée'),
                          backgroundColor: Colors.grey,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Annuler totalement'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddConferenceDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController subtitleController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity:
                Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  title: Text(
                    'Demander une visioconférence',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  content: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              labelText: 'Nature de la demande',
                              prefixIcon: Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: subtitleController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Détailler votre demande',
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 45),
                                child: Icon(Icons.description),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: titleController.text.isNotEmpty
                          ? () async {
                              try {
                                await ApiService.demanderVisio(
                                  titleController.text,
                                  subtitleController.text,
                                );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Votre demande a été envoyée'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Erreur lors de l\'envoi de la demande: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Envoyer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Rechercher une conférence...',
          prefixIcon: Icon(Icons.search, color: Colors.blue[900]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildFilterChip('Tout', 'all'),
            _buildFilterChip('En attente', 'pending'),
            _buildFilterChip('Acceptée', 'accepted'),
            _buildFilterChip('Expirée', 'expired'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _selectedFilter == value;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [Colors.blue[900]!, Colors.blue[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue[900]!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _selectedFilter = value);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[800],
                    ),
                    SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[800],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConferenceCard(Map<String, dynamic> conf) {
    final DateTime scheduledDate = DateTime.parse(conf['scheduled_at']);
    final String status = conf['status'] ?? 'pending';
    final String clientDecision = conf['client_decision'] ?? 'pending';
    final Color cardColor = getCardColor(status, clientDecision, scheduledDate);
    final Color gradientColor = getGradientColor(cardColor);
    
    // Vérifier si la carte doit être floutée
    bool shouldBlur = false;
    if (_selectedFilter != 'all') {
      if (_selectedFilter == 'pending') {
        shouldBlur = clientDecision != 'pending';
      } else if (_selectedFilter == 'accepted') {
        shouldBlur = clientDecision != 'accepted';
      } else if (_selectedFilter == 'expired') {
        shouldBlur = !(DateTime.now().difference(scheduledDate).inMinutes > 30 || clientDecision == 'refused');
      }
    }
    
    return Hero(
      tag: 'conference-${conf['id']}',
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showConferenceDetails(conf),
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardColor.withOpacity(0.9),
                        gradientColor.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conf['titre'] ?? 'Sans titre',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        getStatusIcon(status),
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        getStatusText(status),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (status == 'pending' ||
                              status == 'accepted')
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${conf['employe_prenom']} ${conf['employe_nom']}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        color: Colors.white.withOpacity(0.8),
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "${scheduledDate.toLocal()}".split(' ')[0],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (shouldBlur)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Charger les conférences au démarrage
    loadConferences();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredConferences {
    // Filtrer uniquement par recherche
    var filtered = conferences.where((conf) {
      return conf['titre']?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ?? false ||
          "${conf['employe_prenom']} ${conf['employe_nom']}"
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    // Trier par date et heure (du plus récent au plus ancien)
    filtered.sort((a, b) {
      final DateTime dateA = DateTime.parse(a['scheduled_at']);
      final DateTime dateB = DateTime.parse(b['scheduled_at']);
      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Header3(
              title: 'VIDÉO CONFÉRENCE',
              onBackPressed: () => Navigator.pop(context),
            ),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: isLoading 
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
                    ),
                  )
                : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: loadConferences,
                            child: Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    )
                  : conferences.isEmpty
                    ? Center(
                        child: Text(
                          'Aucune vidéoconférence disponible',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: filteredConferences.length,
                        itemBuilder: (context, index) {
                          return _buildConferenceCard(filteredConferences[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _pulseAnimation,
        child: FloatingActionButton.extended(
          onPressed: showAddConferenceDialog,
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          icon: Icon(Icons.video_call, size: 28),
          label: Text('Nouvelle Visio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final spacing = 30.0;
    for (var i = 0; i < size.width; i += spacing.toInt()) {
      for (var j = 0; j < size.height; j += spacing.toInt()) {
        canvas.drawCircle(
          Offset(i.toDouble(), j.toDouble()),
          2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

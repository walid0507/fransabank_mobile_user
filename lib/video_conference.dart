import 'package:flutter/material.dart';
import 'package:projet1/configngrok.dart';

class VideoConferencePage extends StatefulWidget {
  @override
  _VideoConferencePageState createState() => _VideoConferencePageState();
}

class _VideoConferencePageState extends State<VideoConferencePage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> conferences = [
    {
      'title': 'Demande de prêt',
      'subtitle': 'Discussion sur les conditions du prêt immobilier',
      'date': DateTime.now(),
      'employee': 'M. Dupont',
      'status': 'pending'
    },
    {
      'title': 'Ouverture de compte',
      'subtitle': 'Vérification des documents et validation',
      'date': DateTime.now().add(Duration(days: 1)),
      'employee': 'Mme Durand',
      'status': 'accepted'
    },
    {
      'title': 'Problème de transaction',
      'subtitle': "Analyse d'une transaction suspecte",
      'date': DateTime.now().subtract(Duration(days: 1)),
      'employee': 'M. Leroy',
      'status': 'cancelled'
    },
  ];

  Color getCardColor(String status) {
    switch (status) {
      case 'pending':
        return Color(0xFF1976D2);
      case 'accepted':
        return Color(0xFF2E7D32);
      case 'cancelled':
        return Color(0xFFE57373);
      case 'expired':
        return Color(0xFF757575);
      default:
        return Color(0xFF1976D2);
    }
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
      case 'cancelled':
        return 'Annulée';
      case 'expired':
        return 'Expirée';
      default:
        return 'En attente';
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'expired':
        return Icons.event_busy;
      default:
        return Icons.schedule;
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

  void showConferenceDetails(Map<String, dynamic> conf) {
    final bool isExpired = conf['status'] == 'expired' ||
        conf['date'].isBefore(DateTime.now().subtract(Duration(hours: 24)));

    if (isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cette réunion est expirée'),
          backgroundColor: Colors.grey,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            conf['title'],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 20, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Employé: ${conf['employee']}',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 20, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Date: ${conf['date'].toLocal()}'.split(' ')[0],
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 20, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'Heure: ${TimeOfDay.fromDateTime(conf['date']).format(context)}',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showReprogramOrCancelDialog(conf);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Refuser'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("Le lien s'affichera à l'heure de la réunion"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Accepter'),
            ),
          ],
        );
      },
    );
  }

  void showReprogramOrCancelDialog(Map<String, dynamic> conf) {
    showDialog(
      context: context,
      builder: (context) {
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
          content: Text(
            'Choisissez si vous souhaitez reprogrammer la réunion ou l\'annuler définitivement.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showAddConferenceDialog();
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
              onPressed: () {
                Navigator.pop(context);
                markConferenceAsExpired(conf);
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
                          ? () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Votre demande a été envoyée'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visioconférences'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Hero(
              tag: 'demander-visio',
              child: ElevatedButton(
                onPressed: showAddConferenceDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 3,
                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.video_call, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Demander Visio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: conferences.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: conferences.length,
                itemBuilder: (context, index) {
                  final conf = conferences[index];
                  final String status = conf['status'];
                  final Color cardColor = getCardColor(status);
                  final Color gradientColor = getGradientColor(cardColor);

                  return Hero(
                    tag: 'conference-${conf['title']}',
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => showConferenceDetails(conf),
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [cardColor, gradientColor],
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            conf['title'],
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
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  getStatusIcon(status),
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  getStatusText(status),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
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
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.videocam,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    conf['subtitle'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        color: Colors.white.withOpacity(0.95),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        conf['employee'],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.95),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_outlined,
                                              color: Colors.white
                                                  .withOpacity(0.95),
                                              size: 16,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "${conf['date'].toLocal()}"
                                                  .split(' ')[0],
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.95),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(child: Text('Aucune visioconférence disponible')),
    );
  }
}


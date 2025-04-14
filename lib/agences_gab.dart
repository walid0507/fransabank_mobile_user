import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projet1/header3.dart';
import 'package:url_launcher/url_launcher.dart';

class AgencesGab extends StatefulWidget {
  const AgencesGab({Key? key}) : super(key: key);

  @override
  State<AgencesGab> createState() => _AgencesGabState();
}

class _AgencesGabState extends State<AgencesGab> {
  bool _isFullScreen = false;
  final MapController _mapController = MapController();
  bool _isExpanded = false;

  final Map<String, List<Map<String, dynamic>>> _agenciesByRegion = {
    'Direction Générale': [
      {
        'name': 'Direction Générale',
        'image': 'assets/images/agences/direction.jpg',
        'lat': 36.74472998890608,
        'lon': 2.9495913225210226,
        'adresse':
            'Résidence des Pins, Bâtiment A, Lot N° 994, section N° 04, Cheraga, Alger.',
        'numéro de télephone': '(+213) 021 999 200',
        'fax': '(+213) 021 999 207',
        'e-mail': ' info@fransabank.dz',
        'lienmaps':
            'https://maps.app.goo.gl/LPQsCtpDzzr8dcVS6?g_st=com.google.maps.preview.copy',
      },
    ],
    'Agences Fransabank Centre': [
      {
        'name': 'Agence Sidi Yahia',
        'image': 'assets/images/agences/sidiyahia.jpg',
        'lat': 36.73927566349871,
        'lon': 3.0348093562047174,
        'adresse': '45B, Lot Petite Provence Sidi Yahia Hydra, Alger.',
        'numéro de télephone':
            '(+213) 023 47 61 41 / 47 61 36 / 47 61 34 / 54 44 45',
        'fax': ' (+213) 023 47 61 37',
        'lienmaps':
            'https://maps.app.goo.gl/eoKg9TWQe9bXJGPd8?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Ouled Fayet',
        'image': 'assets/images/agences/direction.jpg',
        'lat': 36.744793512659946,
        'lon': 2.949679691562442,
        'adresse':
            'Résidence des Pins, Bâtiment A, Lot N° 994, section N° 04, Cheraga, Alger.',
        'numéro de télephone': '(+213) 021 999 204',
        'fax': '(+213) 021 999 209',
        'lienmaps':
            'https://maps.app.goo.gl/LPQsCtpDzzr8dcVS6?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Blida',
        'image': 'assets/images/agences/blida.jpg',
        'lat': 36.480146756851596,
        'lon': 2.835535094133326,
        'adresse':
            'Boulevard Kritli Mokhtar, lotissement Ennakhile N°01, Blida.',
        'numéro de télephone':
            '(+213) 025 22 47 61 / 22 47 69 / 23 79 46 / 49 48 18',
        'fax': '(+213) 025 22 48 29',
        'lienmaps': '',
      },
      {
        'name': 'Agence Bab Ezzouar',
        'image': 'assets/images/agences/babezzouar.jpg',
        'lat': 36.71455593564886,
        'lon': 3.2009032316147428,
        'adresse':
            "Quartier des affaires d'Alger, lot 02 N°15 et 16, Immeuble CMA CGM, Bab Ezzouar, Alger.",
        'numéro de télephone': '(+213) 023 92 49 94 / 92 49 95 / 92 50 03',
        'fax': '(+213) 023 92 50 02',
        'lienmaps':
            'https://maps.app.goo.gl/A8jHc3wPw5GLLuw9A?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Kouba',
        'image': 'assets/images/agences/kouba.jpg',
        'lat': 36.72513943052998,
        'lon': 3.0728849550068036,
        'adresse':
            'Rue Garidi G4 Groupement de propriété 101, Lot 49 commune de Kouba, Alger.',
        'numéro de télephone':
            '(+213) 023 70 63 35 /  70 63 47 / 70 63 69 / 70 62 42',
        'fax': ' (+213) 023 70 63 70',
        'lienmaps':
            'https://maps.app.goo.gl/1BEyoCXaFZiNLP2z5?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Baba Hassen',
        'image': 'assets/images/agences/babahassen.jpg',
        'lat': 36.69910908147914,
        'lon': 2.973378301701347,
        'adresse': 'Ilot N°211, Section 03, N°01 et 02, Baba Hassen, Alger.',
        'numéro de télephone':
            '(+213) 023 35 32 02 / 35 32 03/ 35 32 06 / 35 30 15',
        'fax': ' (+213) 023 35 30 98',
        'lienmaps':
            'https://maps.app.goo.gl/yXhEkNJm3Ey8wpLE7?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Rouiba',
        'image': 'assets/images/agences/rouiba.jpg',
        'lat': 36.7394504755736,
        'lon': 3.276088160217714,
        'adresse': 'Ilot 158 Bis, les Cadettes Commune de Rouiba, Alger.',
        'numéro de télephone': ' (+213) 023 85 43 47 / 85 43 20 / 85 43 41',
        'fax': '(+213) 023 85 43 21',
        'lienmaps':
            'https://maps.app.goo.gl/UmrYS69F7s96e73j7?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Tizi Ouzou',
        'image': 'assets/images/agences/tizi.jpg',
        'lat': 36.70975731102915,
        'lon': 4.0355921171127775,
        'adresse':
            'Adresse : 12 Boulevard Stiti Ali, N°15, Groupement de propriété 53, Section 66. Commune de Tizi Ouzou',
        'numéro de télephone':
            ' (+213) 026 45 87 00 / 45 88 60 / 45 88 56 / 45 88 48',
        'fax': '(+213) 026 45 88 59',
        'lienmaps':
            'https://maps.app.goo.gl/xkqnJaiCDMdwdgpp9?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Alger Centre',
        'image': 'assets/images/agences/algercentre.jpg',
        'lat': 36.7649657870512,
        'lon': 3.0539005052669164,
        'adresse': "N°18/20 Rue Ahmed Zabana, Commune Sidi M'Hammed, Alger.",
        'numéro de télephone': ' (+213) 021 74 15 42 / 74 64 22 / 74 71 37',
        'fax': '(+213) 021 73 08 02',
        'lienmaps':
            'https://maps.app.goo.gl/cMiEKa4s7MFdYKy59?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Garden City',
        'image': 'assets/images/agences/fransagarden.png',
        'lat': 36.75050919453092,
        'lon': 2.9518361826846578,
        'adresse':
            'Centre Commercial Garden City Local 303 B, 3ème étage, Commune de Dely Ibrahim, Alger.',
        'numéro de télephone': '(+213) 023 28 03 03 / 28 03 14 / 28 06 27',
        'fax': ' (+213) 023 28 07 63',
        'lienmaps':
            'https://maps.app.goo.gl/PfHzwtAb2BWWr3iT6?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Zeralda',
        'image': 'assets/images/agences/zeralda.jpg',
        'lat': 36.71846921651968,
        'lon': 2.848701152037131,
        'adresse':
            'Zighoud Youcef, section 09 ilot 181, Commune de Zéralda, Alger',
        'numéro de télephone': '(+213) 023 32 54 57 / 32 65 01 / 32 67 79',
        'fax': '(+213) 023 32 69 00',
        'lienmaps':
            'https://maps.app.goo.gl/KjFAREmTEpyLGFPB7?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Dely Brahim',
        'image': 'assets/images/agences/delybrahim.jpg',
        'lat': 36.7537431546275,
        'lon': 2.97741143283714,
        'adresse':
            'Bois des Cars 2, Groupe de propriété 11, Section 12, N°216, Dely Brahim, Alger',
        'numéro de télephone': ' (+213) 023 30 88 00 / 30 88 22',
        'fax': ' (+213) 023 30 88 66',
        'lienmaps':
            'https://maps.app.goo.gl/WumNsKdrCz3yrCs18?g_st=com.google.maps.preview.copy',
      },
    ],
    'Agences Fransabank Est': [
      {
        'name': 'Agence Béjaia',
        'image': 'assets/images/agences/bejaia.jpg',
        'lat': 36.74516715456071,
        'lon': 5.0594578135128,
        'adresse': 'Route des AURES, Ilo n° 43 / Section n° 74, Béjaia',
        'numéro de télephone': ' (+213) 034 18 72 66 / 18 72 67 / 18 72 68',
        'fax': '(+213) 034 18 72 69',
        'lienmaps':
            'https://maps.app.goo.gl/N1ndrjqHcsWFridf6?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Bordj BA',
        'image': 'assets/images/agences/bordj.jpg',
        'lat': 36.075310929384564,
        'lon': 4.7466877164763,
        'adresse': 'Lot 475, N°T30, Bordj Bou Arréridj',
        'numéro de télephone': '(+213) 035 76 49 41 / 76 49 63 / 76 49 68',
        'fax': '(+213) 035 76 49 95',
        'lienmaps':
            'https://maps.app.goo.gl/CHZnpDfujVTnkeEJ6?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Sétif',
        'image': 'assets/images/agences/setif.jpg',
        'lat': 36.20056113632666,
        'lon': 5.410176587442805,
        'adresse':
            'Boulevard des Entrepreneurs, Nouvelle Zone urbaine secteur "A" lot 06 parts N°110 ilot 65, Sétif',
        'numéro de télephone': '(+213) 036 51 44 14 / 51 35 98 / 51 41 35',
        'fax': '(+213) 036 51 41 57',
        'lienmaps':
            'https://maps.app.goo.gl/juUat8aZ68Zcc9aK9?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence El Eulma',
        'image': 'assets/images/agences/eleulma.jpg',
        'lat': 36.152899576164685,
        'lon': 5.677293916502533,
        'adresse': 'Promotion Immobilière REKKAB, Bt "G", Bloc 1, El Eulma.',
        'numéro de télephone':
            '(+213) 036 47 71 03 / 47 71 14 / 47 71 35 / 47 70 61',
        'fax': '(+213) 036 47 70 72',
        'lienmaps':
            'https://maps.app.goo.gl/QnmWoiHo9y6Fih8C8?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Constantine',
        'image': 'assets/images/agences/constantine.jpg',
        'lat': 36.357592136521696,
        'lon': 6.635605747663993,
        'adresse': 'Cité Ali Besbes, Lot G N° 23, Sidi Mabrouk, Constantine.',
        'numéro de télephone':
            '(+213) 031 73 27 14 / 73 27 17 / 73 27 33 / 73 26 78',
        'fax': '(+213) 031 73 27 44',
        'lienmaps':
            'https://maps.app.goo.gl/Pp9nTCggTZ2nxtfn8?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Batna',
        'image': 'assets/images/agences/batna.jpg',
        'lat': 35.553862917721354,
        'lon': 6.1836037031341515,
        'adresse': 'Rue des Frères Guellil, lot N°9, Batna.',
        'numéro de télephone': '(+213) 033 85 10 68 / 85 31 80 / 80 63 74',
        'fax': '(+213) 033 80 57 07',
        'lienmaps':
            'https://maps.app.goo.gl/HsRtCZTvzkyTrTgC9?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Annaba',
        'image': 'assets/images/agences/annaba.jpg',
        'lat': 36.89442040019443,
        'lon': 7.757188761665468,
        'adresse': "07, avenue de l'ALN, Annaba.",
        'numéro de télephone': '(+213) 038 43 32 77',
        'fax': '(+213) 038 43 32 89',
        'lienmaps':
            'https://maps.app.goo.gl/ynxZ7QqPKg1Vo3Hc9?g_st=com.google.maps.preview.copy',
      },
    ],
    'Agences Fransabank Ouest': [
      {
        'name': 'Agence Oran 1',
        'image': 'assets/images/agences/oran1.jpg',
        'lat': 35.69673220510397,
        'lon': -0.6059391335040081,
        'adresse': 'Cité Dar El Beida – Coopérative El Zouhour N°12, Oran.',
        'numéro de télephone':
            '(+213) 041 85 13 94 / 85 13 95 / 85 13 97 / 85 13 98',
        'fax': '(+213) 41 85 13 96',
        'lienmaps':
            'https://maps.app.goo.gl/rvRawcfZ76NDi1ZA8?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Oran 2',
        'image': 'assets/images/agences/oran2.jpg',
        'lat': 35.672663427176424,
        'lon': -0.6392721825016395,
        'adresse': "Cité des Palmiers, avenue de l'ANP, Oran.",
        'numéro de télephone': '(+213) 041 22 12 09 / 22 12 23 / 22 11 92',
        'fax': '(+213) 041 22 11 79',
        'lienmaps':
            'https://maps.app.goo.gl/adPHdwkU59YQSaBH8?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Sidi Bel Abbès',
        'image': 'assets/images/agences/belabbes.jpg',
        'lat': 35.17924206483503,
        'lon': -0.6417915627385755,
        'adresse':
            'Section 256, Ilot 125,Cité El Madina El Mounawara, Rue Mokdad Ben Amar. Sidi Bel Abbès.',
        'numéro de télephone': '(+213) 048 75 57 84 / 75 59 27',
        'fax': '(+213) 048 75 54 54',
        'lienmaps':
            'https://maps.app.goo.gl/2TGXgcFcvHyojcij6?g_st=com.google.maps.preview.copy',
      },
      {
        'name': 'Agence Tlemcen',
        'image': 'assets/images/agences/tlemcen.jpg',
        'lat': 34.88454284848412,
        'lon': -1.3212830916133036,
        'adresse': 'Section 149, Ilot 138, lieu-dit Bab Wahrane, Tlemcen.',
        'numéro de télephone': '(+213) 043 41 33 60 / 41 34 40 /  41 34 44',
        'fax': '(+213) 043 41 35 46',
        'lienmaps':
            'https://maps.app.goo.gl/1vEAMGNCZXdoUUrq9?g_st=com.google.maps.preview.copy',
      },
    ],
    'Agences Fransabank Sud': [
      {
        'name': 'Agence Biskra',
        'image': 'assets/images/agences/biskra.jpg',
        'lat': 34.846318928141244,
        'lon': 5.710089981076843,
        'adresse': 'Cité 1000 Logements, Bâtiment N°34, Biskra.',
        'numéro de télephone': '(+213) 033 54 11 35 / 54 11 37 / 54 11 38',
        'fax': ' (+213) 033 54 10 01',
        'lienmaps':
            'https://maps.app.goo.gl/Bgw341ZxoiyNW5Ge7?g_st=com.google.maps.preview.copy',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!_isFullScreen)
              Header3(
                title: 'Agences & GAB',
                onBackPressed: () => Navigator.pop(context),
              ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(28.0339, 1.6596),
                      initialZoom: 5.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName: "com.example.projet1",
                      ),
                      MarkerLayer(
                        markers: _getMarkers(),
                      ),
                    ],
                  ),
                  if (!_isFullScreen)
                    Positioned(
                      top: 10,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1E40AF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Nos différentes agences",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                AnimatedRotation(
                                  duration: Duration(milliseconds: 300),
                                  turns: _isExpanded ? 0.5 : 0.0,
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          AnimatedSize(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _isExpanded
                                ? Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.all(10),
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 5)
                                      ],
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: _agenciesByRegion.keys
                                            .map((region) {
                                          return ExpansionTile(
                                            title: Text(region,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            children: _agenciesByRegion[region]!
                                                .map((agency) {
                                              return ListTile(
                                                title: Text(agency['name']),
                                                onTap: () {
                                                  _moveToAgency(agency);
                                                  setState(() {
                                                    _isExpanded = false;
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    child: FloatingActionButton(
                      onPressed: () => _showAgencyDialog(),
                      child: Icon(Icons.list),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _isFullScreen = !_isFullScreen;
                        });
                      },
                      child: Icon(_isFullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _moveToAgency(Map<String, dynamic> agency) {
    _mapController.move(LatLng(agency['lat'], agency['lon']), 14.0);
  }

  void _showAgencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sélectionner une région"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _agenciesByRegion.keys.map((region) {
            return ExpansionTile(
              title: Text(region),
              children: _agenciesByRegion[region]!.map((agency) {
                return ListTile(
                  title: Text(agency['name']),
                  onTap: () {
                    _moveToAgency(agency);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Marker> _getMarkers() {
    List<Marker> markers = [];
    _agenciesByRegion.forEach((region, agencies) {
      for (var agency in agencies) {
        markers.add(
          Marker(
            point: LatLng(agency['lat'], agency['lon']),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                _showAgencyDetails(agency);
              },
              child: Image.asset(
                'assets/images/markerbank.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
        );
      }
    });
    return markers;
  }

  void _showAgencyDetails(Map<String, dynamic> agency) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      agency['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    agency['image'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.location_on, agency['adresse']),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.phone, agency['numéro de télephone']),
                if (agency['fax'] != null) ...[
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.fax, agency['fax']),
                ],
                if (agency['e-mail'] != null) ...[
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.email, agency['e-mail']),
                ],
                const SizedBox(height: 20),
                if (agency['lienmaps'] != null && agency['lienmaps'].isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _launchMaps(agency['lienmaps']),
                    icon: const Icon(Icons.map),
                    label: const Text('Itinéraire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
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

  Widget _buildInfoRow(IconData icon, String content) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF1E40AF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF1E40AF), size: 20),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchMaps(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

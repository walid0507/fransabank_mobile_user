import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projet1/header3.dart';

class AgencesGab extends StatefulWidget {
  const AgencesGab({Key? key}) : super(key: key);

  @override
  State<AgencesGab> createState() => _AgencesGabState();
}

class _AgencesGabState extends State<AgencesGab> {
  bool _isFullScreen = false;
  final MapController _mapController = MapController();
  bool _isExpanded = false; // Pour afficher/masquer la liste

  final Map<String, List<Map<String, dynamic>>> _agenciesByRegion = {
    'Direction Générale': [
      {
        'name': 'Direction Générale',
        'lat': 36.73963361242001,
        'lon': 3.034487876461612
      },
    ],
    'Agences Fransabank Centre': [
      {
        'name': 'Sidi Yahia',
        'lat': 36.73927566349871,
        'lon': 3.0348093562047174
      },
      {
        'name': 'Ouled Fayet',
        'lat': 36.73963361242001,
        'lon': 3.034487876461612
      },
      {'name': 'Blida', 'lat': 36.480146756851596, 'lon': 2.835535094133326},
      {
        'name': 'Bab Ezzouar',
        'lat': 36.71455593564886,
        'lon': 3.2009032316147428
      },
      {'name': 'Kouba', 'lat': 36.72513943052998, 'lon': 3.0728849550068036},
      {
        'name': 'Baba Hassen',
        'lat': 36.69910908147914,
        'lon': 2.973378301701347
      },
      {'name': 'Rouiba', 'lat': 36.7394504755736, 'lon': 3.276088160217714},
      {
        'name': 'Tizi Ouzou',
        'lat': 36.70975731102915,
        'lon': 4.0355921171127775
      },
      {
        'name': 'Alger Centre',
        'lat': 36.7649657870512,
        'lon': 3.0539005052669164
      },
      {
        'name': 'Garden City',
        'lat': 36.75050919453092,
        'lon': 2.9518361826846578
      },
      {'name': 'Zeralda', 'lat': 36.71846921651968, 'lon': 2.848701152037131},
      {'name': 'Dely Brahim', 'lat': 36.7537431546275, 'lon': 2.97741143283714},
    ],
    'Agences Fransabank Est': [
      {'name': 'Béjaia', 'lat': 36.74516715456071, 'lon': 5.0594578135128},
      {'name': 'Bordj Bou Arréridj', 'lat': 23.5, 'lon': 5.33},
      {'name': 'Sétif', 'lat': 36.20056113632666, 'lon': 5.410176587442805},
      {'name': 'El Eulma', 'lat': 36.152899576164685, 'lon': 5.677293916502533},
      {
        'name': 'Constantine',
        'lat': 36.357592136521696,
        'lon': 6.635605747663993
      },
      {'name': 'Batna', 'lat': 35.553862917721354, 'lon': 6.1836037031341515},
      {'name': 'Annaba', 'lat': 36.89442040019443, 'lon': 7.757188761665468},
    ],
    'Agences Fransabank Ouest': [
      {'name': 'Oran 1', 'lat': 35.69673220510397, 'lon': -0.6059391335040081},
      {'name': 'Oran 2', 'lat': 35.672663427176424,  'lon':-0.6392721825016395},
      {'name': 'Sidi Bel Abbès', 'lat': 35.17924206483503,  'lon': -0.6417915627385755},
      {'name': 'Tlemcen', 'lat': 34.88454284848412, 'lon':  -1.3212830916133036},
    ],
    'Agences Fransabank Sud': [
      {'name': 'Biskra', 'lat': 34.846318928141244,  'lon': 5.710089981076843},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Masquer le Header en plein écran
            if (!_isFullScreen)
              Header3(
                title: 'Agences & GAB',
                onBackPressed: () => Navigator.pop(context),
              ),

            // ✅ Masquer le bouton "Nos différentes agences" en plein écran
            if (!_isFullScreen)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

                    // ✅ Liste déroulante animée
                    AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isExpanded
                          ? Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(top: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26, blurRadius: 5)
                                ],
                              ),
                              child: Column(
                                children: _agenciesByRegion.keys.map((region) {
                                  return ExpansionTile(
                                    title: Text(region,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
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
                            )
                          : SizedBox(),
                    ),
                  ],
                ),
              ),

            // ✅ ESPACE OCCUPÉ PAR LA CARTE (prend tout l'espace restant)
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

                  // ✅ Boutons placés SUR la carte, en bas
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
            width: 40, // Taille du marqueur
            height: 40,
            child: GestureDetector(
              onTap: () {
                _showAgencyInfo(agency['name']);
              },
              child: Image.asset(
                'assets/image/markerbank.png', // ✅ Icône personnalisée (ajoute l'image dans assets/)
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
  void _showAgencyInfo(String agencyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(agencyName),
        content: Text("Informations sur l'agence"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer"),
          ),
        ],
      ),
    );
  }

}

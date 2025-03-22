import 'package:flutter/material.dart';
import 'package:projet1/header3.dart';
import 'package:projet1/configngrok.dart';

class AgencesGab extends StatefulWidget {
  const AgencesGab({Key? key}) : super(key: key);

  @override
  State<AgencesGab> createState() => _AgencesGabState();
}

class _AgencesGabState extends State<AgencesGab> {
  final Map<String, List<Map<String, String>>> agencesParRegion = {
    "Direction Générale": [
      {
        "nom": "Cheraga",
        "adresse":
            "Résidence des Pins, Bâtiment A, Lot N° 994, section N° 04, Cheraga, Alger.",
        "telephone": "(+213) 021 999 200",
        "fax": "(+213) 021 999 207",
        "swift": "FSBKDZAL",
        "email": "info@fransabank.dz"
      }
    ],
    "Agences Fransabank Centre": [
      {
        "nom": "Sidi Yahia",
        "adresse": "45B, Lot Petite Provence Sidi Yahia Hydra, Alger.",
        "telephone": "(+213) 023 47 61 41 / 47 61 36 / 47 61 34/ 54 44 45",
        "fax": "(+213) 023 47 61 37"
      },
      {
        "nom": "Ouled Fayet",
        "adresse":
            "Résidence des Pins, Bt. A, Lot N°994, Section N°04, Cheraga – Alger",
        "telephone": "(+213) 021 999 204",
        "fax": "(+213) 021 999 209"
      },
      {
        "nom": "Blida",
        "adresse":
            "Boulevard Kritli Mokhtar, lotissement Ennakhile N°01, Blida.",
        "telephone": "(+213) 025 22 47 61",
        "fax": "(+213) 025 22 48 29"
      },
      {
        "nom": "Bab Ezzouar",
        "adresse":
            "Quartier des affaires d'Alger, lot 02 N°15 et 16, Immeuble CMA CGM,  Bab Ezzouar, Alger",
        "telephone": "(+213) 023 92 49 94",
        "fax": "(+213) 023 92 50 02"
      },
      {
        "nom": "Kouba",
        "adresse":
            "Rue Garidi G4 Groupement de propriété 101, Lot 49 commune de Kouba, Alger.",
        "telephone": "(+213) 023 70 63 35 ",
        "fax": "(+213) 023 70 63 70"
      },
      {
        "nom": "Baba Hassen",
        "adresse": "Ilot N°211, Section 03, N°01 et 02, Baba Hassen, Alger",
        "telephone": "(+213)  023 35 32 02",
        "fax": "(+213) 023 35 30 98"
      },
      {
        "nom": "Rouiba",
        "adresse": "Ilot 158 Bis, les Cadettes Commune de Rouiba, Alger.",
        "telephone": "(+213) 023 85 43 47 ",
        "fax": "(+213) 023 85 43 21"
      },
      {
        "nom": "Tizi Ouzou",
        "adresse":
            "Groupement de propriété 53, Section 66. Commune de Tizi Ouzou",
        "telephone": "(+213) 026 45 87 00",
        "fax": "(+213) 026 45 88 59"
      },
      {
        "nom": "Ager centre",
        "adresse": "N°18/20 Rue Ahmed Zabana, Commune Sidi M'Hammed, Alger.",
        "telephone": "(+213) 021 74 15 42",
        "fax": "(+213) 021 73 08 02"
      },
      {
        "nom": "Garden City",
        "adresse":
            " Centre Commercial Garden City Local 303 B, 3ème étage, Commune de Dely Ibrahim, Alger.",
        "telephone": "(+213)  023 28 03 03",
        "fax": "(+213) 023 28 07 63"
      },
      {
        "nom": "Zeralda",
        "adresse":
            "Zighoud Youcef, section 09 ilot 181, Commune de Zéralda, Alger ",
        "telephone": "(+213)  023 32 54 57 ",
        "fax": "(+213) 023 32 69 00"
      },
      {
        "nom": "Daly Brahim",
        "adresse":
            "Bois des Cars 2, Groupe de propriété 11, Section 12, N°216, Dely Brahim, Alger ",
        "telephone": "(+213)  023 30 88 00  ",
        "fax": "(+213)  023 30 88 66"
      }
    ],
    "Agences Fransbank Est": [
      {
        "nom": "Béjaia",
        "adresse": "Route des AURES, Ilo n° 43 / Section n° 74, Béjaia ",
        "telephone": "(+213)  034 18 72 66  ",
        "fax": "(+213)  034 18 72 69"
      },
      {
        "nom": "Bordj Bou Arréridj",
        "adresse": "Lot 475, N°T30, Bordj Bou Arréridj ",
        "telephone": "(+213)  035 76 49 41 ",
        "fax": "(+213)   035 76 49 95"
      },
      {
        "nom": "Sétif",
        "adresse":
            "Boulevard des Entrepreneurs, Nouvelle Zone urbaine secteur « A » lot 06 parts N°110 ilot 65, Sétif ",
        "telephone": "(+213)  036 51 44 14  ",
        "fax": "(+213)   036 51 41 57"
      },
      {
        "nom": "Constantine",
        "adresse": "Cité Ali Besbes, Lot G N° 23, Sidi Mabrouk, Constantine. ",
        "telephone": "(+213)  031 73 27 14  ",
        "fax": "(+213)   031 73 27 44"
      },
      {
        "nom": "Batna",
        "adresse": "Rue des Frères Guellil, lot N°9, Batna. ",
        "telephone": "(+213)  033 85 10 68  ",
        "fax": "(+213)   033 80 57 07"
      },
      {
        "nom": "Annaba",
        "adresse": "07, avenue de l'ALN, Annaba. ",
        "telephone": "(+213)  038 43 32 77 ",
        "fax": "(+213)   031 73 27 44"
      },
    ],
    "Agences Fransabank Ouest": [
      {
        "nom": "Oran",
        "adresse": "Cité Dar El Beida – Coopérative El Zouhour N°12, Oran.",
        "telephone": "(+213)   041 85 13 94  ",
        "fax": "(+213)   41 85 13 96"
      },
      {
        "nom": "Sidi Bel Abbes",
        "adresse":
            "Section 256, Ilot 125,Cité El Madina El Mounawara, Rue Mokdad Ben Amar. Sidi Bel Abbès. ",
        "telephone": "(+213)  048 75 57 84 ",
        "fax": "(+213)   048 75 54 54"
      },
      {
        "nom": "Tlemcen",
        "adresse": "Section 149, Ilot 138, lieu-dit Bab Wahrane, Tlemcen. ",
        "telephone": "(+213)  043 41 33 60  ",
        "fax": "(+213)   031 73 27 44"
      },
      {
        "nom": "Annaba",
        "adresse": "07, avenue de l'ALN, Annaba. ",
        "telephone": "(+213)  038 43 32 77 ",
        "fax": "(+213)   031 73 27 44"
      }
    ],
    "Agence Fransabank Sud": [
      {
        "nom": "Biskra",
        "adresse": "Cité 1000 Logements, Bâtiment N°34, Biskra.",
        "telephone": "(+213) 033 54 11 35 ",
        "fax": "(+213)  033 54 10 01 "
      }
    ]
    // Ajouter toutes les autres ici
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header3(
            title: 'Agences & GAB',
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: agencesParRegion.entries
                      .map((entry) =>
                          _buildRegionSection(entry.key, entry.value))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionSection(String region, List<Map<String, String>> agences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            region,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Column(
          children: agences.map((agence) => _buildAgenceCard(agence)).toList(),
        )
      ],
    );
  }

  Widget _buildAgenceCard(Map<String, String> agence) {
    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agence["nom"]!,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 5),
            _buildInfoRow(Icons.location_on, agence["adresse"]!),
            _buildInfoRow(Icons.phone, "Tél: ${agence["telephone"]}"),
            if (agence.containsKey("fax"))
              _buildInfoRow(Icons.print, "Fax: ${agence["fax"]}"),
            if (agence.containsKey("swift"))
              _buildInfoRow(Icons.code, "SWIFT: ${agence["swift"]}"),
            if (agence.containsKey("email"))
              _buildInfoRow(Icons.email, "Email: ${agence["email"]}"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade900),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:projet1/home.dart';
import 'header.dart';
import 'creecompte.dart';
import 'curved_header.dart'; // Ajout du nouvel import

class ComptesPage extends StatefulWidget {
  final String nomClient;

  const ComptesPage({Key? key, required this.nomClient}) : super(key: key);

  @override
  _ComptesPageState createState() => _ComptesPageState();
}

class _ComptesPageState extends State<ComptesPage> {
  List<Map<String, dynamic>> comptes = [
    {"type_compte": "Épargne", "solde": "10 000"},
    {"type_compte": "Courant", "solde": "50 000"},
  ];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CurvedHeader(
            title: 'Comptes',
            onBackPressed: () => Navigator.pop(context),
            child:
                Container(), // Le contenu principal est maintenant géré par le padding en dessous
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : comptes.isEmpty
                          ? Center(
                              child: Text(
                                "Aucun compte disponible",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              itemCount: comptes.length,
                              itemBuilder: (context, index) {
                                final compte = comptes[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                            nomClient: widget.nomClient),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                          Icons.account_balance_wallet,
                                          color: Colors.white),
                                      title: Text(
                                        "${compte['type_compte']}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "${compte['solde']} DA",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      trailing: Icon(Icons.arrow_forward_ios,
                                          color: Colors.white70),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateAccountScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                        child: Text(
                          '+ Ajouter',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
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

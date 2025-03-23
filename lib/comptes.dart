import 'package:flutter/material.dart';
import 'package:projet1/home.dart';
import 'header.dart';
import 'creecompte.dart';
import 'curved_header.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ComptesPage extends StatefulWidget {
  final String nomClient;

  const ComptesPage({Key? key, required this.nomClient}) : super(key: key);

  @override
  _ComptesPageState createState() => _ComptesPageState();
}

class _ComptesPageState extends State<ComptesPage> {
  List<String> comptes = ["Compte 1", "Compte 2", "Compte 3"];
  bool _isLoading = false;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSavedClientId();
  }

  String _maskClientId(String id) {
    if (id.length <= 4) return id;
    return "${id.substring(0, 2)}*****${id.substring(id.length - 2)}";
  }

  Future<void> _loadSavedClientId() async {
    final clientId = await _storage.read(key: 'client_id');
    if (clientId != null) {
      setState(() {
        comptes[0] = _maskClientId(clientId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CurvedHeader(
            title: 'Comptes',
            onBackPressed: () => Navigator.pop(context),
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.white))
                      : comptes.isEmpty
                          ? Center(
                              child: Text(
                                "Aucun compte disponible",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              itemCount: comptes.length,
                              itemBuilder: (context, index) {
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
                                      leading: Icon(Icons.account_balance_wallet,
                                          color: Colors.white),
                                      title: Text(
                                        comptes[index],
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
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

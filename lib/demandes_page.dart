import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'curved_header.dart';

class DemandesPage extends StatefulWidget {
  const DemandesPage({Key? key}) : super(key: key);

  @override
  _DemandesPageState createState() => _DemandesPageState();
}

class _DemandesPageState extends State<DemandesPage> {
  List<Map<String, dynamic>> demandes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  Future<void> _loadDemandes() async {
    try {
      setState(() => _isLoading = true);
      final demandesData = await ApiService.getMesDemandes();

      // Vérifie que les données ne sont pas null avant de les utiliser
      if (demandesData != null) {
        setState(() {
          _isLoading = false;
          demandes = demandesData;
          // Trier les demandes par date (du plus récent au plus ancien)
          if (demandes.isNotEmpty) {
            demandes.sort((a, b) {
              final dateA = DateTime.tryParse(a['created_at'].toString() ?? '');
              final dateB = DateTime.tryParse(b['created_at'].toString() ?? '');
              if (dateA == null || dateB == null) return 0;
              return dateB.compareTo(dateA);
            });
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          demandes = [];
        });
      }
    } catch (e) {
      print("Erreur: $e");
      setState(() {
        _isLoading = false;
        demandes = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des demandes')),
      );
    }
  }

  String _getTypeName(int typeId) {
    switch (typeId) {
      case 1:
        return "Etudiant";
      case 2:
        return "Commercant";
      case 3:
        return "Professionnel";
      case 4:
        return "Personnel";
      default:
        return "Jeune/Enfant";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CurvedHeader(
        title: "Mes Demandes",
        onBackPressed: () => Navigator.pop(context),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : demandes.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune demande trouvée',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: demandes.length,
                    itemBuilder: (context, index) {
                      return _buildDemandeCard(demandes[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildDemandeCard(Map<String, dynamic> demande) {
    final status = demande['status'];
    final date = DateTime.parse(demande['created_at']);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);

    Widget statusIcon;
    String statusText;
    Color statusColor;

    switch (status) {
      case 'pending':
        statusIcon = const CircularProgressIndicator(
          strokeWidth: 2,
          value: null,
        );
        statusText = 'En attente';
        statusColor = Colors.orange;
        break;
      case 'approved':
        statusIcon = const Icon(Icons.check_circle, color: Colors.green);
        statusText = 'Approuvé';
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusIcon = const Icon(Icons.cancel, color: Colors.red);
        statusText = 'Rejeté';
        statusColor = Colors.red;
        break;
      default:
        statusIcon = const Icon(Icons.help_outline);
        statusText = 'Statut inconnu';
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(child: statusIcon),
        ),
        title: Text(
          'Demande du $formattedDate',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Statut: $statusText',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Type de compte: ${_getTypeName(demande['type_client'])}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DemandeDetailsPage(demande: demande),
            ),
          );
        },
      ),
    );
  }
}

class DemandeDetailsPage extends StatelessWidget {
  final Map<String, dynamic> demande;

  const DemandeDetailsPage({Key? key, required this.demande}) : super(key: key);
  String _getTypeName(int typeId) {
    switch (typeId) {
      case 1:
        return "Etudiant";
      case 2:
        return "Commercant";
      case 3:
        return "Professionnel";
      case 4:
        return "Personnel";
      default:
        return "Jeune/Enfant";
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = demande['status'];
    final date = DateTime.parse(demande['created_at']);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return Scaffold(
      body: CurvedHeader(
        title: "Détails de la demande",
        onBackPressed: () => Navigator.pop(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statut de la demande',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date de demande',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Statut',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                _buildStatusWidget(status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations personnelles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(
                          'Civilité', demande['civilité'] ?? 'Non spécifié'),
                      _buildInfoRow(
                          'Nom', demande['last_name'] ?? 'Non spécifié'),
                      _buildInfoRow(
                          'Prénom', demande['first_name'] ?? 'Non spécifié'),
                      _buildInfoRow('Nom de jeune fille',
                          demande['nom_jeunefille'] ?? 'Non spécifié'),
                      _buildInfoRow('Date de naissance',
                          demande['date_of_birth'] ?? 'Non spécifié'),
                      _buildInfoRow('Lieu de naissance',
                          demande['lieu_denaissance'] ?? 'Non spécifié'),
                      _buildInfoRow('Nationalité',
                          demande['Nationalité'] ?? 'Non spécifié'),
                      _buildInfoRow('Nationalité 2',
                          demande['Nationalité2'] ?? 'Non spécifiée'),
                      _buildInfoRow('Situation familiale',
                          demande['situation_familliale'] ?? 'Non spécifié'),
                      _buildInfoRow('Prénom du père',
                          demande['Prénom_pere'] ?? 'Non spécifié'),
                      _buildInfoRow('Nom de la mère',
                          demande['Nom_mere'] ?? 'Non spécifié'),
                      _buildInfoRow('Prénom de la mère',
                          demande['Prénom_mere'] ?? 'Non spécifié'),
                      _buildInfoRow('Pays de naissance',
                          demande['Pays_naissance'] ?? 'Non spécifié'),
                      _buildInfoRow('Adresse', demande['address']),
                      _buildInfoRow('Téléphone',
                          demande['phone_number'] ?? 'Non spécifié'),
                      _buildInfoRow('Numéro d\'identité',
                          demande['numero_identite'] ?? 'Non spécifié'),
                      _buildInfoRow('Numéro de document',
                          demande['numero_doc'] ?? 'Non spécifié'),
                      _buildInfoRow('Date d\'expiration du document',
                          demande['date_of_expiry'] ?? 'Non spécifié'),
                      _buildInfoRow(
                          'Type de client',
                          _getTypeName(demande['type_client']) ??
                              'Non spécifié'),
                      _buildInfoRow(
                          'Fonction', demande['fonction'] ?? 'Non spécifiée'),
                      _buildInfoRow('Nom de l\'employeur',
                          demande['nom_employeur'] ?? 'Non spécifié'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations FATCA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(
                          'Nationalité AM',
                          demande['fatca_nationalitéAM'] == true
                              ? 'Oui'
                              : 'Non'),
                      _buildInfoRow('Résidence AM',
                          demande['fatca_residenceAM'] == true ? 'Oui' : 'Non'),
                      _buildInfoRow('Green Card AM',
                          demande['fatca_greencardAM'] == true ? 'Oui' : 'Non'),
                      _buildInfoRow(
                          'TIN', demande['fatca_TIN'] ?? 'Non spécifié'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget(String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            status == 'approved'
                ? Icons.check_circle
                : status == 'rejected'
                    ? Icons.cancel
                    : Icons.hourglass_empty,
            color: status == 'approved'
                ? Colors.green
                : status == 'rejected'
                    ? Colors.red
                    : Colors.orange,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            status == 'approved'
                ? 'Approuvé'
                : status == 'rejected'
                    ? 'Rejeté'
                    : 'En attente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: status == 'approved'
                  ? Colors.green
                  : status == 'rejected'
                      ? Colors.red
                      : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    // Convertir value en String et gérer le cas null
    String displayValue = value == null ? 'Non spécifié' : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

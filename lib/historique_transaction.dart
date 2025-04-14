import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:projet1/header3.dart';

class HistoriqueTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  final List<Map<String, dynamic>>? transactions;

  const HistoriqueTransactionScreen({
    Key? key,
    this.transaction,
    this.transactions,
  }) : super(key: key);

  @override
  _HistoriqueTransactionScreenState createState() =>
      _HistoriqueTransactionScreenState();
}

class _HistoriqueTransactionScreenState
    extends State<HistoriqueTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Header3(
            title: 'Historique des transactions',
            icon: Icons.arrow_back,
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: widget.transaction != null
                ? _buildTransactionDetails(widget.transaction!)
                : _buildTransactionList(widget.transactions!),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(Map<String, dynamic> transaction) {
    final isReception = transaction['type'] == 'reception';
    final montant = double.parse(transaction['montant']);
    final date = DateTime.parse(transaction['date']);
    final source = transaction['source'];
    final destination = transaction['destination'];
    final sourceName = '${source['prenom']} ${source['nom']}';
    final destinationName = '${destination['prenom']} ${destination['nom']}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isReception ? 'Reçu de' : 'Envoyé à',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      isReception ? sourceName : destinationName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${isReception ? '+' : '-'}${montant.toStringAsFixed(2)}DZD',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isReception ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isReception
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isReception ? 'Réception' : 'Envoi',
                        style: TextStyle(
                          color: isReception ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    // Grouper les transactions par date
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var tx in transactions) {
      final date = DateTime.parse(tx['date']);
      final dateKey = '${date.day}/${date.month}/${date.year}';
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        String date = groupedTransactions.keys.elementAt(index);
        List<Map<String, dynamic>> dayTransactions = groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            ...dayTransactions.map((tx) => _buildTransactionItem(tx)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isReception = transaction['type'] == 'reception';
    final montant = double.parse(transaction['montant']);
    final date = DateTime.parse(transaction['date']);
    final otherClient =
        isReception ? transaction['source'] : transaction['destination'];
    final otherClientName = '${otherClient['prenom']} ${otherClient['nom']}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoriqueTransactionScreen(
              transaction: transaction,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
                        child: Row(
                          children: [
                            Container(
              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                color: isReception
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isReception ? Icons.arrow_downward : Icons.arrow_upward,
                color: isReception ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                    otherClientName,
                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                  const SizedBox(height: 4),
                                  Text(
                    '${date.hour}:${date.minute}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
              '${isReception ? '+' : '-'}${montant.toStringAsFixed(2)}DZD',
                              style: TextStyle(
                color: isReception ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
    );
  }
}

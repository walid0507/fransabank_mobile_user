import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:projet1/header3.dart';
import 'pret.dart';

class Transaction {
  final String title;
  final String date;
  final double amount;
  final String imageUrl;

  Transaction(
      {required this.title,
      required this.date,
      required this.amount,
      required this.imageUrl});
}

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  bool _isLoading = true;
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    await Future.delayed(Duration(seconds: 2)); // simulate loading
    setState(() {
      transactions = [
        Transaction(
            title: 'Pinky Jackets',
            date: '30 Dec, 10:24 am',
            amount: -93.72,
            imageUrl: 'assets/jacket.png'),
        Transaction(
            title: 'Top Up',
            date: '30 Dec, 10:24 am',
            amount: 200.00,
            imageUrl: 'assets/topup.png'),
        Transaction(
            title: 'Collar Contrast Cardigan',
            date: '30 Dec, 10:24 am',
            amount: -93.72,
            imageUrl: 'assets/cardigan.png'),
        Transaction(
            title: 'Cow Collar Cardigan',
            date: '30 Dec, 10:24 am',
            amount: -93.72,
            imageUrl: 'assets/cow_cardigan.png'),
        Transaction(
            title: 'Gradient Winter Coat',
            date: '30 Dec, 10:24 am',
            amount: -93.72,
            imageUrl: 'assets/winter_coat.png'),
        Transaction(
            title: 'Patchwork Skate Shoes',
            date: '30 Dec, 10:24 am',
            amount: -93.72,
            imageUrl: 'assets/skate_shoes.png'),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Header3(
            title: 'Historique',
            icon: Icons.arrow_back,
            onBackPressed: () => Navigator.pop(context),
            onLogoutPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoanPage()),
              );
            },
          ),
          Expanded(
              child: _isLoading ? _buildShimmerList() : _buildTransactionList())
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionList() {
    // Grouper les transactions par date
    Map<String, List<Transaction>> groupedTransactions = {};
    for (var tx in transactions) {
      if (!groupedTransactions.containsKey(tx.date.split(',')[0])) {
        groupedTransactions[tx.date.split(',')[0]] = [];
      }
      groupedTransactions[tx.date.split(',')[0]]!.add(tx);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        String date = groupedTransactions.keys.elementAt(index);
        List<Transaction> dayTransactions = groupedTransactions[date]!;

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
            ...dayTransactions
                .map((tx) => Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(tx.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    tx.date.split(',')[1],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${tx.amount > 0 ? '+' : ''}${tx.amount.abs().toStringAsFixed(2)} DA",
                              style: TextStyle(
                                color:
                                    tx.amount > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ],
        );
      },
    );
  }
}

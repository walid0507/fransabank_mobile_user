import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:projet1/header3.dart';

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
            onBackPressed: () => Navigator.pop(context),
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
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                tx.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                color: tx.amount > 0 ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            title:
                Text(tx.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(tx.date, style: TextStyle(color: Colors.grey)),
            trailing: Text(
              "${tx.amount > 0 ? '+' : ''}${tx.amount.abs().toStringAsFixed(2)} DA",
              style: TextStyle(
                color: tx.amount > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}

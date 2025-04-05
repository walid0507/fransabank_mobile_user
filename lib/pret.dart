import 'package:flutter/material.dart';
import 'emi.dart'; // Ajout de l'import pour la page EMI

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoanPage(),
    );
  }
}

class LoanPage extends StatelessWidget {
  const LoanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800], // Bleu au lieu du vert
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EMICalculatorPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Current Loan Amount
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'montant actuel du prêt',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '1,560.32 da',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Statistics'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Apply for Loan Section
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'demander un prêt',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.arrow_outward,
                              size: 30,
                              color: Colors.black,
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.account_balance_wallet,
                              size: 30,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Activity Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Activity',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Activity List
                  ActivityTile(
                    icon: Icons.directions_car,
                    title: 'Car EMI',
                    amount: '24.76 da',
                    date: '15-Sep-2023',
                    status: 'Due',
                    statusColor: Colors.red,
                  ),
                  ActivityTile(
                    icon: Icons.home,
                    title: 'Home Loan',
                    amount: '505.28 da',
                    date: '18-Sep-2023',
                    status: 'Approved',
                    statusColor: Colors.green,
                  ),
                  ActivityTile(
                    icon: Icons.local_hospital,
                    title: 'Medical Loan',
                    amount: '308.29 da',
                    date: '20-Sep-2023',
                    status: 'Processing',
                    statusColor: const Color.fromARGB(255, 8, 0, 255),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;
  final String date;
  final String status;
  final Color statusColor;

  const ActivityTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[800]),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(status, style: TextStyle(color: statusColor)),
          ],
        ),
      ),
    );
  }
}

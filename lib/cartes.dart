import 'package:flutter/material.dart';
import 'header2.dart'; // Importation du header commun

class CartesPage extends StatefulWidget {
  final String nomClient;

  const CartesPage({Key? key, required this.nomClient}) : super(key: key);

  @override
  _CartesPageState createState() => _CartesPageState();
}

class _CartesPageState extends State<CartesPage>
    with SingleTickerProviderStateMixin {
  bool isCardFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (isCardFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    isCardFlipped = !isCardFlipped;
  }

  @override
  Widget build(BuildContext context) {
    return CommonHeader(
      title: 'Mes Cartes',
      body: Column(
        children: [
          SizedBox(height: 50),
          // Carte bancaire avec animation de retournement
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_animation.value * 3.141592),
                  alignment: Alignment.center,
                  child: _animation.value <= 0.5
                      ? _buildFrontCard()
                      : _buildBackCard(),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          // Titre "Transactions"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          // Liste des transactions
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildTransactionItem(
                  index == 0
                      ? Icons.payment
                      : (index == 1
                          ? Icons.shopping_cart
                          : Icons.directions_car),
                  index == 0 ? 'netflix' : (index == 1 ? 'psplus' : 'yassir'),
                  index == 0 ? '-570 da' : (index == 1 ? '-205 da' : '-398 da'),
                  index == 0 ? 'Paid' : 'Failed',
                  index == 0
                      ? '14 Juillet 2025'
                      : (index == 1 ? '02 Juillet 2025' : '10 juin 2025'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Carte recto
  Widget _buildFrontCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 200, // Hauteur fixe pour la carte
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fransabank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.credit_card, color: Colors.white, size: 30),
            ],
          ),
          SizedBox(height: 20),
          Text(
            widget.nomClient,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '6501 0702 1205 5051',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Exp: 12/20',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Carte verso
  Widget _buildBackCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 200, // Hauteur fixe pour la carte
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CVV: 7Q2',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Élément de transaction
  Widget _buildTransactionItem(
      IconData icon, String title, String amount, String status, String date) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade900),
        title: Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(date, style: TextStyle(fontSize: 14)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                color: status == 'Failed' ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: status == 'Failed' ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

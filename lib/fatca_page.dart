import 'package:flutter/material.dart';

class FatcaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formulaire FATCA')),
      body: Center(
        child: Text(
          'Page FATCA - Formulaire à remplir',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

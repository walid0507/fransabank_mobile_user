import 'package:flutter/material.dart';

class CreateAccountStep3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Étape 3 - Informations complémentaires')),
      body: Center(
        child: Text(
          'Page suivante du processus de création de compte',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

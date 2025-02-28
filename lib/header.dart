import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 20),
      child: Center(
        child: Image.asset(
          'assets/images/image003.jpeg',
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}

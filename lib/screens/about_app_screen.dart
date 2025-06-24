import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('About Cup Tup')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Cup Tup POS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text('A modern and simple POS app for cafes.'),
          SizedBox(height: 20),
          Text('Developed using Flutter, Hive, and GetX.'),
        ],
      ),
    ),
  );
}
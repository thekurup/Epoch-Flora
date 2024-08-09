import 'package:flutter/material.dart';
import 'package:epoch/Screens/user/home.dart';  // Import home.dart to use FloatingNavBar

class FavouritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite'),
        backgroundColor: Color(0xFF013A09),
      ),
      body: Center(
        child: Text(
          'Favourite Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: FloatingNavBar(currentIndex: 1),  // Use FloatingNavBar from home.dart
    );
  }
}
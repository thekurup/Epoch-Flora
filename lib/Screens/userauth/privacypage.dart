import 'package:flutter/material.dart';

class PrivacyNoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Notice'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          // Add your privacy notice text here
          'This is our privacy notice...',
        ),
      ),
    );
  }
}
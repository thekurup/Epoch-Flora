import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:epoch/Screens/admin_auth/admin_login.dart'; // Make sure this import path is correct

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to Admin Home Page'),
      ),
    );
  }

  void _logout(BuildContext context) async {
    // Clear the login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Navigate back to the login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AdminLogin()),
      (Route<dynamic> route) => false,
    );
  }
}
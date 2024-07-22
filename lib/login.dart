import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text("Login Page",
      style: TextStyle(color: Colors.green,fontSize: 30,fontWeight: FontWeight.bold),))),
    );
  }
}
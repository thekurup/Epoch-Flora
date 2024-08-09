// This line tells the Dart analyzer to ignore certain warnings for this file
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// Import necessary packages and files
import 'package:epoch/Screens/admin/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define a stateful widget for the admin login page
class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

// Define the state for the AdminLogin widget
class _AdminLoginState extends State<AdminLogin> {
  // Variables to control password visibility and loading state
  bool _obscureText = true; // Controls whether the password is visible or hidden
  bool _isLoading = false; // Indicates if a login attempt is in progress

  // Controllers for username and password input fields
  final _usernameController = TextEditingController(); // Manages the username input
  final _passwordController = TextEditingController(); // Manages the password input

  // Function to handle the login process
  void _login() {
    // Get the entered username and password
    final _username = _usernameController.text;
    final _password = _passwordController.text;
    
    // Check if username or password is empty
    if (_username.isEmpty || _password.isEmpty) {
      // Show an error message if either field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password')),
      );
    } else if (_username == 'arjun' && _password == 'arjun24') {
      // If login is successful, save login state and navigate to admin home page
      SharedPreferences.getInstance().then((_sharedpref) {
        _sharedpref.setBool('isLoggedIn', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHome()),
        );
      });
    } else if (_username != 'arjun') {
      // Show error for incorrect username
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username you entered is incorrect'),
          backgroundColor: Color.fromARGB(255, 189, 18, 5),
        ),
      );
    } else {
      // Show error for incorrect password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password you entered is incorrect'),
          backgroundColor: Color.fromARGB(255, 189, 18, 5),
        ),
      );
    }

    // Update the loading state
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the UI for the login page
    return Scaffold(
      body: Container(
        // Set background image for the login page
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/adminbg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button at the top left
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                   Navigator.of(context).pop();
                  },
                ),
              ),
              // Main content of the login page
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Admin Login" title
                        Text(
                          'Admin Login',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Username input field
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.person, color: Colors.green),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Password input field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.lock, color: Colors.green),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                // Toggle password visibility
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // Login button
                        Center(
                          child: Container(
                            width: 200,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: <Color>[Color(0xFF01320F), Color(0xFF22A547)],
                                stops: <double>[0, 1],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x80000000),
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Start login process
                                setState(() {
                                  _isLoading = true;
                                });
                                _login(); 
                              },
                              child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Inspirational quote
                        Center(
                          child: Text(
                            '"Rooted in every seedling, lies the\npromise of a greener tomorrow"\n— Epoch Flora',
                            style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: 25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
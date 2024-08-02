// This line tells Dart to ignore warnings about using const constructors
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// These lines import necessary Flutter packages and custom files
import 'package:epoch/Screens/userauth/privacypage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:math' show pi;
import '../../database/user_database.dart';
import 'login.dart';

// This creates a registration page that can change over time (e.g., showing error messages)
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

// This class contains all the changeable content for the registration page
class _RegisterPageState extends State<RegisterPage> {
  // This key helps identify and validate the form
  final _formKey = GlobalKey<FormState>();

  // These controllers manage the text input for username, email, password, and confirm password
  // Example: When user types "john_doe", _usernameController.text will be "john_doe"
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // These booleans control whether the passwords are shown as dots or plain text
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // This boolean checks if the passwords match
  bool _passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    // Add listeners to check if passwords match when they change
    _passwordController.addListener(_checkPasswordsMatch);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  @override
  void dispose() {
    // Remove listeners and dispose of controllers when the widget is removed
    _passwordController.removeListener(_checkPasswordsMatch);
    _confirmPasswordController.removeListener(_checkPasswordsMatch);
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // This method checks if the passwords match
  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text.startsWith(_confirmPasswordController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic structure for the page
    return Scaffold(
      backgroundColor: Color(0xFFF7FFF3),
      // SafeArea ensures the app doesn't overlap with system UI (like the status bar)
      body: SafeArea(
        child: Stack(
          children: [
            // This adds padding around the main content
            Padding(
              padding: const EdgeInsets.all(20.0),
              // SingleChildScrollView allows the page to be scrolled if it's too long
              child: SingleChildScrollView(
                // Form groups together and validates form fields
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // This creates a back button
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(height: 20),
                      // This centers the "Register" text
                      Center(
                        child: Text(
                          'Register',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Create your new account',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // This creates the username input field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF0F0F0),
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        // This validates the username
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.length < 3) {
                            return 'Username is too short (minimum 3 characters)';
                          }
                          if (value.contains(RegExp(r'[0-9]'))) {
                            return 'Username should only contain letters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      // This creates the email input field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF0F0F0),
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        // This validates the email
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      // This creates the password input field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF0F0F0),
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              // This toggles the password visibility
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          _checkPasswordsMatch();
                        },
                        // This validates the password
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 4) {
                            return 'Password is too short (minimum 4 characters)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      // This creates the confirm password input field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF0F0F0),
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              // This toggles the confirm password visibility
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          hintText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _confirmPasswordController.text.isNotEmpty && !_passwordsMatch
                              ? 'Passwords do not match'
                              : null,
                        ),
                        onChanged: (value) {
                          _checkPasswordsMatch();
                        },
                        // This validates the confirm password
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 25),
                      // This creates the terms and privacy notice text
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            children: [
                              TextSpan(text: 'By signing you agree to our '),
                              TextSpan(
                                text: 'term of use',
                                style: TextStyle(color: Color(0xFF325A3E)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigate to terms of use page (not implemented yet)
                                  },
                              ),
                              TextSpan(text: '\n'),  // Line break
                              TextSpan(text: 'and '),
                              TextSpan(
                                text: 'privacy notice',
                                style: TextStyle(color: Color(0xFF325A3E)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigate to privacy notice page
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyNoticePage()));
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      // This displays an image
                      Center(
                        child: Image.asset(
                          'assets/images/jug.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                      SizedBox(height: 25),
                      // This creates the sign up button
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
                            onPressed: _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.robotoCondensed(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // This creates the "Already have an account?" link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.inter(color: Colors.grey),
                          ),
                          GestureDetector(
                            child: Text(
                              'Login',
                              style: GoogleFonts.inter(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              // Navigate to the login page
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // This positions a decorative leaf image in the top-right corner
            Positioned(
              top: 70,
              right: 20,
              child: Transform.rotate(
                angle: -30 * pi / 180,
                child: Image.asset(
                  'assets/images/leaf.png',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This method handles the user registration process
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      // Attempt to register the user
      final success = await UserDatabase.registerUser(username, email, password);

      if (success) {
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );
        // Navigate to the login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // Show an error message if registration fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username already exists')),
        );
      }
    }
  }
}
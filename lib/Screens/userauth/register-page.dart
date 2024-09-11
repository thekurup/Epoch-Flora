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

// AnimatedTextField widget for animated text input fields
class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AnimatedTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  }) : super(key: key);

  @override
  _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorTween;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _borderColorTween = ColorTween(
      begin: Colors.grey[600],
      end: Colors.blue[300],
    ).animate(_animationController);

    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    if (widget.controller.text.isNotEmpty) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderColorTween,
      builder: (context, child) {
        return TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(widget.prefixIcon, color: Colors.grey[600]),
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColorTween.value!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColorTween.value!),
            ),
            errorText: widget.errorText,
            errorStyle: TextStyle(color: Colors.red[300]),
          ),
          // New: Trim the input before validating
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(value?.trim());
            }
            return null;
          },
          // New: Trim the input when the field loses focus
          onEditingComplete: () {
            widget.controller.text = widget.controller.text.trim();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }
}

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
      _passwordsMatch = _passwordController.text.trim() == _confirmPasswordController.text.trim();
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
                      // AnimatedTextField for username
                      AnimatedTextField(
                        controller: _usernameController,
                        labelText: 'Username',
                        prefixIcon: Icons.person_outline,
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
                      // AnimatedTextField for email
                      AnimatedTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
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
                      // AnimatedTextField for password
                      AnimatedTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
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
                      // AnimatedTextField for confirm password
                      AnimatedTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        errorText: _confirmPasswordController.text.isNotEmpty && !_passwordsMatch
                            ? 'Passwords do not match'
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text.trim()) {
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
                                style: TextStyle(color: Colors.green),
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
                      SizedBox(height: 40),
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
      // Trim whitespace from input fields
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

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
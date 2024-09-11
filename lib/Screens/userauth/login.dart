// ignore_for_file: prefer_const_constructors

import 'package:epoch/Screens/admin_auth/admin_login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../database/user_database.dart';
import 'register-page.dart';
import '../user/home.dart';

// This creates a login page that can change over time (e.g., showing error messages)
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

// This class contains all the changeable content for the login page
class _LoginPageState extends State<LoginPage> {
  // This key helps identify and validate the form
  final _formKey = GlobalKey<FormState>();

  // These controllers manage the text input for username and password
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // This boolean controls whether the password is shown as dots or plain text
  bool _obscureText = true;

  // These will store error messages for username and password if needed
  String? _usernameError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic structure for the page
    return Scaffold(
      // New: Remove the app bar to allow full-screen design
      // New: Use a Stack to layer the background, curved image, and login form
      body: Stack(
        children: [
          // New: Gradient background for the entire page
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF3A3A5A)],
              ),
            ),
          ),
          // Curved cover photo section
          ClipPath(
            clipper: CurvedBottomClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4, // Takes up 40% of screen height
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/try2.jpeg'), // Make sure this image exists in your assets
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // New: Login form wrapped in SingleChildScrollView for scrolling if needed
          
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // New: Push content down to start below the curve
                    SizedBox(height: MediaQuery.of(context).size.height * 0.40),
                    // This centers the "Welcome to Flora" text
                    Center(
                      child: Text(
                        'Welcome to Flora',
                        // This uses a custom Google Font for styling
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 5), // Adds a small vertical space
                    Center(
                      child: Text(
                        'Login to your account',
                        style: GoogleFonts.roboto(
                          color: Colors.grey[300],
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Custom AnimatedTextField for username
                    AnimatedTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                      prefixIcon: Icons.person,
                      errorText: _usernameError,
                    ),
                    SizedBox(height: 20),
                    // Custom AnimatedTextField for password
                    AnimatedTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIcon: Icons.lock,
                      errorText: _passwordError,
                      obscureText: _obscureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // This toggles the password visibility
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    // This aligns the "Admin Login" text to the right
                    Align(
                      alignment: Alignment.centerRight,
                      // This detects taps on the "Admin Login" text
                      child: GestureDetector(
                        onTap: () {
                          // This navigates to the AdminLogin page when tapped
                         Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminLogin()),
                          );
                        },
                        child: Text(
                          'Admin Login',
                          style: TextStyle(
                            color: Colors.green[300],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // This creates the login button
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
                          onPressed: _loginUser, // Calls _loginUser when pressed
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Login',
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
                    // This creates the "Don't have an account?" link
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // This navigates to the RegisterPage when tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterPage()),
                          );
                        },
                        child: Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.grey[400],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // This method handles the login process
  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      // Trim whitespace from username and password
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Clear any previous error messages
      setState(() {
        _usernameError = null;
        _passwordError = null;
      });

      // Attempt to login the user
      final loginResult = await UserDatabase.loginUser(username, password);

      if (loginResult == LoginResult.success) {
        // Show a success popup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomPopup(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to HomePage after a short delay
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
          );
        });
      } else if (loginResult == LoginResult.invalidUsername) {
        // Show error for invalid username
        setState(() {
          _usernameError = 'Invalid username';
        });
      } else if (loginResult == LoginResult.invalidPassword) {
        // Show error for invalid password
        setState(() {
          _passwordError = 'Invalid password';
        });
      }
    }
  }
}

// This class creates a custom clipper for the curved bottom of the cover photo
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// This class creates a custom widget for the login success popup
class CustomPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF01320F), Color(0xFF22A547)],
          stops: <double>[0, 1],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_open, color: Colors.white),
          SizedBox(width: 12.0),
          Text(
            'Login Successful',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// Custom AnimatedTextField widget for animated text input fields
class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;

  const AnimatedTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
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
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(widget.prefixIcon, color: Colors.grey[400]),
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColorTween.value!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColorTween.value!),
            ),
            errorText: widget.errorText,
            errorStyle: TextStyle(color: Colors.red[300]),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
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
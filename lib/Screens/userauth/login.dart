// This line tells Dart to ignore warnings about using const constructors
// ignore_for_file: prefer_const_constructors

// These lines import necessary Flutter packages and custom files
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
  // Example: When user types "john_doe", _usernameController.text will be "john_doe"
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
      // SingleChildScrollView allows the page to be scrolled if it's too long
      body: SingleChildScrollView(
        // Form groups together and validates form fields
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // This creates a custom-shaped container for the top image
              ClipPath(
                clipper: CustomClipPath(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/startpage-plant.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // This adds space around its child widgets
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // This centers the "Welcome to Flora" text
                    Center(
                      child: Text(
                        'Welcome to Flora',
                        // This uses a custom Google Font for styling
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF01320F),
                        ),
                      ),
                    ),
                    SizedBox(height: 5), // Adds a small vertical space
                    Center(
                      child: Text(
                        'Login to your account',
                        style: GoogleFonts.roboto(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // This creates the username input field
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Color(0xFFE1E5E2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _usernameError,
                      ),
                      // This checks if the username is valid
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // This creates the password input field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText, // Hides the password text
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        // This adds a button to show/hide the password
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            // This toggles the password visibility
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Color(0xFFE1E5E2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _passwordError,
                      ),
                      // This checks if the password is valid
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
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
                            color: Colors.green,
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
                            color: Colors.grey[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This method handles the login process
  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

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

// This class creates a custom shape for the top image container
class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
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
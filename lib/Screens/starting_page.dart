// This line tells the Dart analyzer to ignore a specific lint rule
// ignore_for_file: prefer_const_constructors

// Importing necessary packages and files
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'userauth/login.dart'; // Importing the LoginPage for navigation

// Defining a stateless widget named StartingPage
class StartingPage extends StatelessWidget {
  // Constructor for StartingPage, with an optional key parameter
  const StartingPage({super.key});

  // Building the UI for this widget
  @override
  Widget build(BuildContext context) {
    // Scaffold provides a default app bar, title, and body property
    return Scaffold(
      // The main content of the Scaffold
      body: Stack(
        // Stack allows widgets to be placed on top of each other
        children: [
          // Positioned.fill makes the child occupy the entire stack space
          Positioned.fill(
            // Displaying a background image
            child: Image.asset(
              'assets/images/home.jpg',
              fit: BoxFit.cover, // Image covers the entire area
            ),
          ),
          // Adding a semi-transparent overlay on top of the image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0x5E000000), // Semi-transparent black color
              ),
            ),
          ),
          // Centering the main content
          Center(
            child: Column(
              // Arranging children vertically
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Container for the "Find Plants" text
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Find Plants',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Adding vertical space
                SizedBox(height: 60,),
                // Container for the description text
                Container(
                  margin: EdgeInsets.only(bottom: 40),
                  child: Text(
                    'Find your favorite\nplants on our shop',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Adding more vertical space
                SizedBox(height: 100,),
                // Container for the "Get Started" button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // Creating a gradient background for the button
                    gradient: LinearGradient(
                      begin: Alignment(-1, 0),
                      end: Alignment(1, 0),
                      colors: <Color>[Color(0xFF193E46), Color(0xFF3D98AC)],
                      stops: <double>[0, 1],
                    ),
                  ),
                  child: Container(
                    width: 252,
                    padding: EdgeInsets.fromLTRB(0, 16, 0.5, 15),
                    // Creating a button with text
                    child: TextButton(
                      onPressed: () {
                        // Navigate to LoginPage when button is pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
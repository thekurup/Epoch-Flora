// These lines tell the Dart analyzer to ignore specific lint rules
// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

// Importing necessary packages and files
import 'dart:async';
import 'package:epoch/Screens/starting_page.dart';
import 'package:epoch/database/user_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Defining a stateful widget named SplashScreen
class SplashScreen extends StatefulWidget {
  // Constructor for SplashScreen, with an optional key parameter
  const SplashScreen({super.key});

  // Creating the mutable state for this widget
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// The mutable state for the SplashScreen widget
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Setting up a timer to navigate after 3 seconds
    Timer(Duration(seconds: 3), () {
      // Replacing the current screen with StartingPage after 3 seconds
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => StartingPage()),
      );
    });
  }

  // Building the UI for this widget
  @override
  Widget build(BuildContext context) {
    // Main container for the splash screen
    return Container(
      // Styling the main container
      decoration: BoxDecoration(
        color: Color(0xFFE3FFD1), // Light green background color
        borderRadius: BorderRadius.circular(40), // Rounded corners
      ),
      child: Container(
        // Adding padding to the inner container
        padding: EdgeInsets.fromLTRB(34, 272, 33, 263),
        // Using a Stack to layer widgets on top of each other
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main content of the splash screen
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container for the app icon
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/epoch-icon.png'),
                      ),
                    ),
                    child: Container(
                      width: 300,
                      height: 300,
                    ),
                  ),
                  // Container for the app name text
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 3.3, 0),
                    child: RichText(
                      // Using RichText to style different parts of the text differently
                      text: TextSpan(
                        text: 'Epoch ',
                        style: GoogleFonts.getFont(
                          'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                          color: Color(0xFF000000),
                        ),
                        children: [
                          TextSpan(
                            text: 'Flora',
                            style: GoogleFonts.getFont(
                              'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 25,
                              height: 1.3,
                              color: Color(0xFF3A7F0D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Positioned widget for the top leaf image
            Positioned(
              left: -34,
              right: -33,
              top: -272,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/leaftop.png'),
                  ),
                ),
                child: Container(
                  width: 428,
                  height: 285,
                ),
              ),
            ),
            // Positioned widget for the bottom leaf image
            Positioned(
              left: -34,
              right: -33,
              bottom: -263,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/leafbottom.png'),
                  ),
                ),
                child: Container(
                  width: 428,
                  height: 285,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
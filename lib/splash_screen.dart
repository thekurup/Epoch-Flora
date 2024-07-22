// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'dart:async';
import 'package:epoch/starting_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
   @override
  void initState() {
    super.initState();
    // Set up the timer to navigate after 3 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => StartingPage()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE3FFD1),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(34, 272, 33, 263),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 3.3, 0),
                    child: RichText(
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/Screens/user/home.dart';
import 'package:epoch/database/user_database.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF013A09),
                            child: IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                // TODO: Implement edit profile functionality
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Arjun', // TODO: Replace with actual username from database
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    ProfileButton(
                      icon: Icons.shopping_bag,
                      text: 'My Orders',
                      onPressed: () {
                        // TODO: Implement My Orders functionality
                      },
                    ),
                    ProfileButton(
                      icon: Icons.cancel,
                      text: 'Canceled Orders',
                      onPressed: () {
                        // TODO: Implement Canceled Orders functionality
                      },
                    ),
                    ProfileButton(
                      icon: Icons.logout,
                      text: 'Logout',
                      onPressed: () {
                        // TODO: Implement logout functionality
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingNavBar(currentIndex: 4),
    );
  }
}

class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const ProfileButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          children: [
            SizedBox(width: 20),
            Icon(icon, color: Color(0xFF013A09)),
            SizedBox(width: 20),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
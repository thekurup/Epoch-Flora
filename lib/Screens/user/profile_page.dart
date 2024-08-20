// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:epoch/Screens/user/cancel_order_page.dart';
import 'package:epoch/Screens/user/edit_profile.dart';
import 'package:epoch/Screens/user/my_orders_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/Screens/user/home.dart';
import 'package:epoch/database/user_database.dart';
import 'package:epoch/Screens/userauth/login.dart';
import 'dart:io'; // New import for File

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}


// Declares variables for storing user data and loading state.
class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  bool isLoading = true;
  String? profileImagePath; // New variable to store profile image path

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    User? currentUser = await UserDatabase.getCurrentUser();
    setState(() {
      username = currentUser?.username ?? 'Guest';
      profileImagePath = currentUser?.profileImagePath; // Load profile image path
      isLoading = false;
    });
  }

  void _logout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm) {
      await UserDatabase.logoutUser();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/profileback.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.cyan,
                              backgroundImage: profileImagePath != null
                                  ? FileImage(File(profileImagePath!))
                                  : null,
                              child: profileImagePath == null
                                  ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Color(0xFF013A09),
                                child: IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditProfilePage()),
                                    );
                                    if (result == true) {
                                      _loadUserData(); // Reload user data if changes were made
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          username,
                          style: GoogleFonts.poppins(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                        SizedBox(height: 40),
                        ProfileButton(
                          icon: Icons.shopping_bag,
                          text: 'My Orders',
                          onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyOrdersPage()),
                                  );
                                },
                              ),
                        SizedBox(height: 20),
                        ProfileButton(
                              icon: Icons.cancel,
                              text: 'Canceled Orders',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CancelOrderPage()),
                                );
                              },
                            ),
                        SizedBox(height: 20),
                        ProfileButton(
                          icon: Icons.logout,
                          text: 'Logout',
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),
                ),
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.8),
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF013A09)),
            SizedBox(width: 20),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
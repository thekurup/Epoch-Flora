import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'dart:io'; // Add this import for File

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _loadUsers();
  }

  void _loadUsers() async {
    // Fetch all registered users from the database
    List<User> registeredUsers = await UserDatabase.getAllUsers();
    setState(() {
      users = registeredUsers;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Color(0xFF013A09),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[100],
        child: users.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _buildUserCard(users[index], index);
                },
              ),
      ),
    );
  }

  Widget _buildUserCard(User user, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval((index / users.length), 1.0, curve: Curves.easeOut),
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval((index / users.length), 1.0, curve: Curves.easeOut),
              ),
            ),
            child: child,
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              _buildProfilePicture(user),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  user.username,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(User user) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: ClipOval(
        child: user.profileImagePath != null && user.profileImagePath!.isNotEmpty
            ? Image(
                image: FileImage(File(user.profileImagePath!)),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Icon(Icons.person, size: 40, color: Colors.grey[600]);
                },
              )
            : Icon(Icons.person, size: 40, color: Colors.grey[600]),
      ),
    );
  }
}
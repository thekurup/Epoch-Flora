import 'package:epoch/Screens/admin/addproduct.dart';
import 'package:epoch/Screens/admin/admin_product_list.dart';
import 'package:epoch/Screens/admin/add_category.dart'; // New import
import 'package:epoch/Screens/admin_auth/admin_login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your admin login page and add product page


class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Top leaf image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/leaftop.png',
                fit: BoxFit.cover,
              ),
            ),
            // Bottom leaf image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/leafbottom.png',
                fit: BoxFit.cover,
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton(context, 'Add Product', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AddProduct()),
                    );
                  }),
                  SizedBox(height: 20),
                  _buildButton(context, 'Add Category', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AddCategory()),
                    );
                  }),
                  SizedBox(height: 20),
                  _buildButton(context, 'Product List', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AdminProductList()),
                    );
                  }),
                  SizedBox(height: 20),
                  _buildButton(context, 'Users List', () {}),
                  SizedBox(height: 20),
                  _buildButton(context, 'Orders List', () {}),
                ],
              ),
            ),
            // Logout button
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: _buildLogoutButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 250,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFF013A09),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminLogin()),
        );
      },
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFFB00600),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyNoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Notice', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Information We Collect',
              'We collect personal information such as your name, email, phone number, and address to provide and improve our services.',
            ),
            _buildSection(
              'How We Use Your Information',
              'We use your information to manage your account, process orders, and send you important updates about our services.',
            ),
            _buildSection(
              'Data Security',
              'We implement security measures to protect your personal information, but no method of transmission over the internet is 100% secure.',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to access, correct, or delete your personal information. Contact us to exercise these rights.',
            ),
            _buildSection(
              'Changes to Privacy Policy',
              'We may update our privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            _buildSection(
              'Contact Us',
              'If you have any questions about our privacy policy, please contact us at iamarjunkurup@gmail.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
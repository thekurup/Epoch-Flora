// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:epoch/Screens/user/plant_store.dart';
import 'package:google_fonts/google_fonts.dart';

// Define the ProductDetailPage as a stateless widget
class ProductDetailPage extends StatelessWidget {
  // Declare a final variable to hold the plant data
  final Plant plant;

  // Constructor to initialize the ProductDetailPage with a plant
  // Example: ProductDetailPage(plant: monstera)
  const ProductDetailPage({Key? key, required this.plant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build the UI for the product detail page
    return Scaffold(
      // Use SafeArea to avoid system UI overlaps
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack widget to layer the image, back button, and favorite icon
            Stack(
              children: [
                // Display the plant image
                Image.asset(
                  // Convert plant name to lowercase and replace spaces with underscores for the image file name
                  // Example: 'monstera' becomes 'assets/images/monstera.jpg'
                  'assets/images/${plant.name.toLowerCase().replaceAll(' ', '_')}.jpg',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                // Position the back button in the top-left corner
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    // Navigate back when tapped
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                ),
                // Position the favorite icon in the top-right corner
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_border, color: Colors.black),
                  ),
                ),
              ],
            ),
            // Padding widget to add space around the plant details
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the plant name
                  // Example: "Monstera"
                  Text(
                    plant.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Display the plant category
                  // Example: "Indoor Plants"
                  Text(
                    plant.category,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Display the plant price
                  // Example: "₹ 800.00"
                  Text(
                    '₹ ${plant.price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            // Padding widget for the description section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "About" section title
                  Text(
                    'About',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Placeholder description text
                  Text(
                    'This is a placeholder description for ${plant.name}. '
                    'You can add more detailed information about the plant here, '
                    'including care instructions and interesting facts.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Expanded widget to push the button to the bottom
            Expanded(child: SizedBox()),
            // Padding widget for the "Add to Cart" button
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                // Show a snackbar when the button is pressed
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${plant.name} added to cart')),
                  );
                },
                // Button text
                child: Text(
                  'Add To Cart',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Button style
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
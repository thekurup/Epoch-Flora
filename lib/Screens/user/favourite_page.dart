// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:epoch/Screens/user/home.dart';
import 'package:epoch/Screens/user/product_detail_page.dart';
import 'dart:io';

// Define the FavouritePage widget as a StatefulWidget
// This means it can change its appearance based on user interactions
class FavouritePage extends StatefulWidget {
  @override
  _FavouritePageState createState() => _FavouritePageState();
}

// This is the state class for FavouritePage
// It contains the logic and data that can change over time
class _FavouritePageState extends State<FavouritePage> {
  // List to store favorite products
  // Think of this as a basket to hold all the favorite items
  List<Product> _favoriteProducts = [];

  @override
  // initState is called when this widget is inserted into the widget tree
  // It's like setting up the stage before the show starts
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  // This function loads the favorite products from the database
  // It's like fetching all the favorite items from a storage room
  void _loadFavoriteProducts() {
    setState(() {
      _favoriteProducts = UserDatabase.getFavoriteProducts();
    });
  }

  // This function toggles the favorite status of a product
  // It's like adding or removing an item from your favorites list
  void _toggleFavorite(Product product) async {
    await UserDatabase.toggleFavorite(product);
    _loadFavoriteProducts();
  }

  @override
  // The build method describes the part of the user interface represented by this widget
  // It's like drawing the blueprint of how the page should look
  Widget build(BuildContext context) {
    return Scaffold(
      // Updated AppBar to match the cart page style
      appBar: AppBar(
        centerTitle: true,
        title: Text('Your Favorites', style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),),
        backgroundColor: Colors.green,
        elevation: 0, // Removed shadow to blend with the gradient background
        // New: Updated leading property to change back icon color and navigation
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () {
            // New: Navigate to HomePage instead of popping the current route
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
      ),
      // New: Wrap the body in a Container with gradient background
      body: Container(
        // Added decoration to create a gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Colors adapt based on the current theme (light or dark mode)
            colors: Theme.of(context).brightness == Brightness.light
                ? [Color(0xFF1A1A2E), Color(0xFF3A3A5A)]
                : [Color(0xFF0A0A1E), Color(0xFF2A2A4A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 20,),
              // This expands to fill the remaining space with the list of favorites
              Expanded(
                // If there are no favorites, show a message. Otherwise, show the list
                child: _favoriteProducts.isEmpty
                    ? Center(
                        child: Text(
                          'No favorite plants yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[400], // Updated color for better visibility
                          ),
                        ),
                      )
                    : ListView.builder(
                        // This builds a scrollable list of favorite products
                        itemCount: _favoriteProducts.length,
                        itemBuilder: (context, index) {
                          final product = _favoriteProducts[index];
                          return FavoriteProductCard(
                            product: product,
                            onFavoriteToggle: () => _toggleFavorite(product),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // This adds a bottom navigation bar to the page
      bottomNavigationBar: FloatingNavBar(currentIndex: 1),
    );
  }
}

// This class defines how each favorite product card looks
class FavoriteProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteToggle;

  // Constructor for the FavoriteProductCard
  // It's like a recipe that says what information is needed to create this card
  const FavoriteProductCard({
    Key? key,
    required this.product,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  // This build method describes how the card should look
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // Updated: Changed card color to semi-transparent white for better visibility on gradient background
      color: Colors.white.withOpacity(0.1),
      child: InkWell(
        // When the card is tapped, navigate to the product detail page
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // This displays the product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(product.imagePath),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              // This displays the product details (name, category, price)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white, // Updated color for visibility on dark background
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400], // Updated color for better visibility
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.green, // Kept green for emphasis
                      ),
                    ),
                  ],
                ),
              ),
              // This is the favorite button
              IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
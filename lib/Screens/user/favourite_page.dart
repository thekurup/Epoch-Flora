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
      // The main content of the page
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // This creates the "My Favorites" title at the top of the page
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'My Favorites',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // This expands to fill the remaining space with the list of favorites
            Expanded(
              // If there are no favorites, show a message. Otherwise, show the list
              child: _favoriteProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No favorite plants yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey,
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
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.green,
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
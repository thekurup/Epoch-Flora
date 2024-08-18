import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'dart:io';

// This class represents the product detail page in our app
class ProductDetailPage extends StatefulWidget {
  // This is like passing a specific product to show details for
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

// This class contains all the logic and UI for the product detail page
class _ProductDetailPageState extends State<ProductDetailPage> {
  // This is like a flag to keep track of whether the product is a favorite
  late bool _isFavorite;
  // This keeps track of how many of this product the user wants to buy
  int _quantity = 1;

  @override
  // This function runs when the page is first created
  void initState() {
    super.initState();
    // Set the initial favorite status based on the product
    _isFavorite = widget.product.isFavorite;
  }

  // This function handles toggling the favorite status of the product
  void _toggleFavorite() async {
    // Update the favorite status in the database
    await UserDatabase.toggleFavorite(widget.product);
    // Update the UI to reflect the new favorite status
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  // This function increases the quantity by 1
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  // This function decreases the quantity by 1, but not below 1
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // This function adds the product to the cart
  void _addToCart() async {
    // Try to add the product to the cart
    bool success = await UserDatabase.addToCart(widget.product, quantity: _quantity);
    if (success) {
      // If successful, show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.name} added to cart')),
      );
    } else {
      // If it failed, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add ${widget.product.name} to cart')),
      );
    }
  }

  @override
  // This function builds what we see on the screen
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // This creates the top section with the product image and buttons
            Stack(
              children: [
                // Display the product image
                Image.file(
                  File(widget.product.imagePath),
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                // This adds a back button in the top left corner
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
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
                // This adds a favorite button in the top right corner
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // This section displays the product details
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the product name
                  Text(
                    widget.product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Display the product category
                  Text(
                    widget.product.category,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Display the product price
                  Text(
                    '₹${widget.product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            // This section displays the product description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // This creates an empty space that can expand to fill available space
            Expanded(child: SizedBox()),
            // This section contains the quantity selector and add to cart button
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // This creates the quantity selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        // Decrease quantity button
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: _decrementQuantity,
                        ),
                        // Display current quantity
                        Text(
                          _quantity.toString(),
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        // Increase quantity button
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _incrementQuantity,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // This creates the add to cart button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      child: Text(
                        'Add To Cart',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
          ],
        ),
      ),
    );
  }
}
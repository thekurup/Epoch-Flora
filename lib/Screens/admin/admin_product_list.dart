import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:epoch/database/user_database.dart';
import 'package:epoch/Screens/admin/edit_product.dart'; // This line imports the EditProduct screen

// This class represents the admin's product list page
class AdminProductList extends StatelessWidget {
  const AdminProductList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This creates the top bar of our page
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Product List',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,),
        ),
        backgroundColor:Colors.green,
        // This adds a back button to the app bar
         elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // This creates the main content of our page
      body: ValueListenableBuilder(
        // This line sets up a listener for changes in the products box
        valueListenable: Hive.box<Product>('products').listenable(),
        builder: (context, Box<Product> box, _) {
          // If there are no products, we show a message
          if (box.values.isEmpty) {
            return Center(child: Text('No products available'));
          }
          // If there are products, we create a scrollable list
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final product = box.values.elementAt(index);
              // For each product, we create a ProductListItem
              return ProductListItem(
                product: product,
                // This function is called when the delete button is pressed
                onDelete: () async {
                  await UserDatabase.deleteProduct(product.key);
                },
                // This function is called when the edit button is pressed
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProduct(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// This class represents each individual product item in the list
class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProductListItem({
    Key? key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This creates a container for each product item
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      // This creates a row to hold all elements of the product item
      child: Row(
        children: [
          // This displays the product image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(product.imagePath),
                fit: BoxFit.cover,
                // If the image fails to load, we show a placeholder icon
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported, size: 60);
                },
              ),
            ),
          ),
          SizedBox(width: 16),
          // This displays the product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  product.category,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '₹ ${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF013A09),
                  ),
                ),
              ],
            ),
          ),
          // New: This creates the edit and delete buttons on the right side
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Color(0xFF013A09)),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // This function shows a confirmation dialog when trying to delete a product
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        );
      },
    );
  }
}
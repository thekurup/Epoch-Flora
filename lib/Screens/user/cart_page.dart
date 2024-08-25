// Import necessary packages and files
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:epoch/Screens/user/address_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/Screens/user/home.dart';
import 'package:epoch/database/user_database.dart';
import 'dart:io';

// Define the main CartPage widget
// This is like creating a blueprint for our shopping cart page
class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

// This is where we define how our CartPage behaves
class _CartPageState extends State<CartPage> {
  // This list will store all items in our cart
  // Think of it as a digital shopping basket
  List<CartItem> _cartItems = [];
  // Set the delivery charge (like a shipping fee)
  double _deliveryCharge = 80;
  // Set the minimum amount for free delivery
  // It's like a "spend this much and get free shipping" offer
  double _freeDeliveryThreshold = 1200;

  @override
  // This function runs when the page is first created
  // It's like setting up the store before customers arrive
  void initState() {
    super.initState();
    _loadCartItems();
  }

  // This function loads all items in the cart
  void _loadCartItems() {
    setState(() {
      _cartItems = UserDatabase.getCartItems();
    });
  }

  // This function updates the quantity of an item in the cart
  void _updateQuantity(CartItem item, int change) {
    setState(() {
      item.quantity += change;
      if (item.quantity < 1) item.quantity = 1;
      UserDatabase.updateCartItem(item);
    });
  }

  // This function removes an item from the cart
  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
      UserDatabase.removeFromCart(item.product);
    });
  }

  // This function toggles whether an item is a favorite
  void _toggleFavorite(CartItem item) {
    setState(() {
      UserDatabase.toggleFavorite(item.product);
    });
  }

  // This calculates the total cost of items in the cart before delivery
  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  // This calculates the final total, including delivery if applicable
  // It's like the final number we see at checkout
  double get _total => _subtotal + (_subtotal >= _freeDeliveryThreshold ? 0 : _deliveryCharge);

  @override
  // This function builds what we see on the screen
  Widget build(BuildContext context) {
    return Scaffold(
      // This creates the top bar of our page
      appBar: AppBar(
        title: Text('Your Bag', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        // New: Added leading property for back navigation
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // New: Navigate to HomePage when back button is pressed
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
      ),
      // This is the main content of our page
      // If the cart is empty, we show one view; if it's not, we show another
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF3A3A5A)],
          ),
        ),
        child: _cartItems.isEmpty 
            ? EmptyCartView() 
            : FilledCartView(
                cartItems: _cartItems,
                updateQuantity: _updateQuantity,
                removeItem: _removeItem,
                toggleFavorite: _toggleFavorite,
                subtotal: _subtotal,
                total: _total,
                freeDeliveryThreshold: _freeDeliveryThreshold,
                deliveryCharge: _deliveryCharge,
              ),
      ),
      // This adds a navigation bar at the bottom of the screen
      bottomNavigationBar: FloatingNavBar(currentIndex: 2),
    );
  }
}

// ... (rest of the code remains unchanged)
// This class defines what we see when the cart is empty
class EmptyCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show a shopping cart icon
          // New: Updated icon color for better visibility on dark background
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          SizedBox(height: 20),
          // Display a message saying the cart is empty
          // New: Updated text color for better visibility on dark background
          Text( 
            'Your cart is empty!',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          // Add a fun message encouraging shopping
          // New: Updated text color for better visibility on dark background
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your cart is lonely! Pick some plants and make it bloom!',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[300]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          // Add a button to start shopping
          // New: Updated button color to green for consistency
          ElevatedButton(
            child: Text('Start Shopping', style: GoogleFonts.poppins(color: Colors.white)),
            onPressed: () {
              // When pressed, take the user to the HomePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// This class is shown when there are items in the cart. It includes:
// A scrollable list of cart items.
// Delivery information.
// A total section showing the cost breakdown.
// A checkout button.
class FilledCartView extends StatelessWidget {
  // These are all the pieces of information and functions this view needs
  final List<CartItem> cartItems;
  final Function(CartItem, int) updateQuantity;
  final Function(CartItem) removeItem;
  final Function(CartItem) toggleFavorite;
  final double subtotal;
  final double total;
  final double freeDeliveryThreshold;
  final double deliveryCharge;

  // This is like a recipe for creating this view, listing all the ingredients it needs
  const FilledCartView({
    Key? key,
    required this.cartItems,
    required this.updateQuantity,
    required this.removeItem,
    required this.toggleFavorite,
    required this.subtotal,
    required this.total,
    required this.freeDeliveryThreshold,
    required this.deliveryCharge,
  }) : super(key: key);

  @override
  // This function builds what we see on the screen
  Widget build(BuildContext context) {
    return Column(
      children: [
        // This creates a scrollable list of all items in the cart
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return CartItemTile(
                item: item,
                onQuantityChanged: updateQuantity,
                onRemove: removeItem,
                onFavoriteToggle: toggleFavorite,
              );
            },
          ),
        ),
        // This shows information about delivery
        DeliveryInfo(subtotal: subtotal, freeDeliveryThreshold: freeDeliveryThreshold),
        // This shows the total cost breakdown
        TotalSection(
          subtotal: subtotal, 
          total: total, 
          freeDeliveryThreshold: freeDeliveryThreshold,
          deliveryCharge: deliveryCharge,
        ),
        // This is the button to proceed to checkout
        CheckoutButton(total: total),
      ],
    );
  }
}

// This class represents each item in the cart. It shows:
// The product image.
// The product name and price.
// Buttons to adjust quantity, favorite, or remove the item.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final Function(CartItem, int) onQuantityChanged;
  final Function(CartItem) onRemove;
  final Function(CartItem) onFavoriteToggle;

  // This is like a recipe for creating each cart item, listing all the ingredients it needs
  const CartItemTile({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // New: Added Container with semi-transparent background for better visibility
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Display the product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(item.product.imagePath), width: 80, height: 80, fit: BoxFit.cover),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // New: Added Row to place favorite button next to product name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display the product name
                    Expanded(
                      child: Text(
                        item.product.name, 
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Favorite button
                    IconButton(
                      icon: Icon(
                        item.product.isFavorite ? Icons.favorite : Icons.favorite_border, 
                        color: Colors.red
                      ),
                      onPressed: () => onFavoriteToggle(item),
                    ),
                  ],
                ),
                // Display the product price
                Text('₹${item.product.price}', style: GoogleFonts.poppins(color: Colors.green)),
                // Buttons to adjust quantity and remove item
                Row(
                  children: [
                    IconButton(icon: Icon(Icons.remove, color: Colors.white), onPressed: () => onQuantityChanged(item, -1)),
                    Text('${item.quantity}', style: GoogleFonts.poppins(color: Colors.white)),
                    IconButton(icon: Icon(Icons.add, color: Colors.white), onPressed: () => onQuantityChanged(item, 1)),
                    Spacer(),
                    IconButton(icon: Icon(Icons.delete, color: Colors.white), onPressed: () => onRemove(item)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// This class shows information about delivery charges
class DeliveryInfo extends StatelessWidget {
  final double subtotal;
  final double freeDeliveryThreshold;

  // This is like a recipe for creating the delivery info section
  const DeliveryInfo({Key? key, required this.subtotal, required this.freeDeliveryThreshold}) : super(key: key);

  @override
  // This function builds what we see for the delivery info
  Widget build(BuildContext context) {
    // Calculate how much more the user needs to spend for free delivery
    final remainingForFreeDelivery = freeDeliveryThreshold - subtotal;
    // New: Added Container with semi-transparent background for better visibility
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white.withOpacity(0.1),
      child: Row(
        children: [
          // Show a truck icon to represent delivery
          Icon(Icons.local_shipping, color: Colors.green),
          SizedBox(width: 8),
          // Show a message about free delivery
          // New: Updated text color for better visibility on dark background
          Expanded(
            child: Text(
              remainingForFreeDelivery > 0
                ? 'Add ₹${remainingForFreeDelivery.toStringAsFixed(2)} more to get FREE delivery'
                : 'You have FREE delivery!',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// This class shows the total cost breakdown
class TotalSection extends StatelessWidget {
  final double subtotal;
  final double total;
  final double freeDeliveryThreshold;
  final double deliveryCharge;

  // This is like a recipe for creating the total section, listing all the ingredients it needs
  const TotalSection({
    Key? key,
    required this.subtotal,
    required this.total,
    required this.freeDeliveryThreshold,
    required this.deliveryCharge,
  }) : super(key: key);

  @override
  // This function builds what we see for the total section
  Widget build(BuildContext context) {
    // New: Added Container with semi-transparent background for better visibility
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white.withOpacity(0.1),
      child: Column(
        children: [
          // Show the subtotal (cost before delivery)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
              Text('₹${subtotal.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            ],
          ),
          SizedBox(height: 8),
          // Show the delivery charge (or FREE if applicable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
              Text(
                subtotal >= freeDeliveryThreshold ? 'FREE' : '₹${deliveryCharge.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16, 
                  color: subtotal >= freeDeliveryThreshold ? Colors.green : Colors.white
                ),
              ),
            ],
          ),
          // New: Added divider with custom color for better visibility
          Divider(height: 20, color: Colors.white.withOpacity(0.5)),
         // Show the total cost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Display "Total" text
              Text('Total', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              // Display total amount in green to make it stand out
              Text('₹${total.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
}

// This class defines the checkout button
class CheckoutButton extends StatelessWidget {
  final double total;

  // This is like a recipe for creating the checkout button, listing the ingredient it needs
  const CheckoutButton({Key? key, required this.total}) : super(key: key);

  @override
  // This function builds what we see for the checkout button
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      // New: Added Container with gradient decoration to match login button style
      child: Container(
        width: double.infinity,
        height: 50,
        // New: Added BoxDecoration for gradient and shadow effects
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF01320F), Color(0xFF22A547)],
            stops: <double>[0, 1],
          ),
          // New: Added box shadow for a raised effect
          boxShadow: [
            BoxShadow(
              color: Color(0x80000000),
              offset: Offset(0, 4),
              blurRadius: 8,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: ElevatedButton(
          // Show the total cost on the button
          child: Text(
            'Checkout ₹${total.toStringAsFixed(2)}',
            // New: Updated text style to match login button
            style: GoogleFonts.robotoCondensed(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFFFFFFFF),
            ),
          ),
          style: ElevatedButton.styleFrom(
            // New: Set background color to green for consistency
            backgroundColor: Colors.green,
            // New: Set button shape to match container's rounded corners
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          // This is where we handle what happens when the button is pressed
          onPressed: () {
            // Navigate to the AddressPage when the button is pressed
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddressPage()));
          },
        ),
      ),
    );
  }
}
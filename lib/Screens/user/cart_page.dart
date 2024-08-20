// Import necessary packages and files
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
        iconTheme: IconThemeData(color: Colors.black),
      ),
      // This is the main content of our page
      // If the cart is empty, we show one view; if it's not, we show another
      body: _cartItems.isEmpty 
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
      // This adds a navigation bar at the bottom of the screen
      bottomNavigationBar: FloatingNavBar(currentIndex: 2),
    );
  }
}

// This class defines what we see when the cart is empty
class EmptyCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show a shopping cart icon
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          // Display a message saying the cart is empty
          Text( 
            'Your cart is empty!',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Add a fun message encouraging shopping
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your cart is lonely! Pick some plants and make it bloom!',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          // Add a button to start shopping
          ElevatedButton(
            child: Text('Start Shopping', style: GoogleFonts.poppins(color: Colors.black)),
            onPressed: () {
              // When pressed, take the user to the HomePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}


// This below class is shown when there are items in the cart. It includes:
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
        // This section is commented out, but would allow applying a coupon
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


// This below  class represents each item in the cart. It shows:
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
  // This function builds what we see for each item
  Widget build(BuildContext context) {
    return ListTile(
      // Show the product image
      leading: Image.file(File(item.product.imagePath), width: 50, height: 50, fit: BoxFit.cover),
      // Show the product name
      title: Text(item.product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      // Show the product price
      subtitle: Text('₹${item.product.price}', style: GoogleFonts.poppins(color: Colors.green)),
      // This section allows changing quantity, favoriting, and removing the item
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Favorite button
          IconButton(
            icon: Icon(item.product.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            onPressed: () => onFavoriteToggle(item),
          ),
          // Decrease quantity button
          IconButton(icon: Icon(Icons.remove), onPressed: () => onQuantityChanged(item, -1)),
          // Show current quantity
          Text('${item.quantity}', style: GoogleFonts.poppins()),
          // Increase quantity button
          IconButton(icon: Icon(Icons.add), onPressed: () => onQuantityChanged(item, 1)),
          // Remove item button
          IconButton(icon: Icon(Icons.delete), onPressed: () => onRemove(item)),
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
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Show a truck icon to represent delivery
          Icon(Icons.local_shipping, color: Colors.green),
          SizedBox(width: 8),
          // Show a message about free delivery
          Expanded(
            child: Text(
              remainingForFreeDelivery > 0
                ? 'Add ₹${remainingForFreeDelivery.toStringAsFixed(2)} more to get FREE delivery'
                : 'You have FREE delivery!',
              style: GoogleFonts.poppins(fontSize: 14),
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
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Show the subtotal (cost before delivery)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: GoogleFonts.poppins(fontSize: 16)),
              Text('₹${subtotal.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
          SizedBox(height: 8),
          // Show the delivery charge (or FREE if applicable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery', style: GoogleFonts.poppins(fontSize: 16)),
              Text(
                subtotal >= freeDeliveryThreshold ? 'FREE' : '₹${deliveryCharge.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16, 
                  color: subtotal >= freeDeliveryThreshold ? Colors.green : null
                ),
              ),
            ],
          ),
          Divider(height: 20),
          // Show the total cost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
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
      child: ElevatedButton(
        // Show the total cost on the button
        child: Text('Checkout ₹${total.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 18,color: Colors.white),),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        // This is where we'd handle what happens
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder:(context) => AddressPage()),);
        },
      ),
    );
  }
}
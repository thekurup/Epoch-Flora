import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/Screens/user/home.dart';
import 'package:epoch/database/user_database.dart';
import 'dart:io';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];
  double _deliveryCharge = 80;
  double _freeDeliveryThreshold = 1200;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    setState(() {
      _cartItems = UserDatabase.getCartItems();
    });
  }

  void _updateQuantity(CartItem item, int change) {
    setState(() {
      item.quantity += change;
      if (item.quantity < 1) item.quantity = 1;
      UserDatabase.updateCartItem(item);
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
      UserDatabase.removeFromCart(item.product);
    });
  }

  void _toggleFavorite(CartItem item) {
    setState(() {
      UserDatabase.toggleFavorite(item.product);
    });
  }

  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  double get _total => _subtotal + (_subtotal >= _freeDeliveryThreshold ? 0 : _deliveryCharge);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Bag', style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
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
      bottomNavigationBar: FloatingNavBar(currentIndex: 2),
    );
  }
}

class EmptyCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Your cart is empty!',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your cart is lonely! Pick some plants and make it bloom!',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Start Shopping', style: GoogleFonts.poppins()),
            onPressed: () {
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

class FilledCartView extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(CartItem, int) updateQuantity;
  final Function(CartItem) removeItem;
  final Function(CartItem) toggleFavorite;
  final double subtotal;
  final double total;
  final double freeDeliveryThreshold;
  final double deliveryCharge;

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
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        DeliveryInfo(subtotal: subtotal, freeDeliveryThreshold: freeDeliveryThreshold),
        ApplyCoupon(),
        TotalSection(
          subtotal: subtotal, 
          total: total, 
          freeDeliveryThreshold: freeDeliveryThreshold,
          deliveryCharge: deliveryCharge,
        ),
        CheckoutButton(total: total),
      ],
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final Function(CartItem, int) onQuantityChanged;
  final Function(CartItem) onRemove;
  final Function(CartItem) onFavoriteToggle;

  const CartItemTile({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.file(File(item.product.imagePath), width: 50, height: 50, fit: BoxFit.cover),
      title: Text(item.product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      subtitle: Text('₹${item.product.price}', style: GoogleFonts.poppins(color: Colors.green)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(item.product.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            onPressed: () => onFavoriteToggle(item),
          ),
          IconButton(icon: Icon(Icons.remove), onPressed: () => onQuantityChanged(item, -1)),
          Text('${item.quantity}', style: GoogleFonts.poppins()),
          IconButton(icon: Icon(Icons.add), onPressed: () => onQuantityChanged(item, 1)),
          IconButton(icon: Icon(Icons.delete), onPressed: () => onRemove(item)),
        ],
      ),
    );
  }
}

class DeliveryInfo extends StatelessWidget {
  final double subtotal;
  final double freeDeliveryThreshold;

  const DeliveryInfo({Key? key, required this.subtotal, required this.freeDeliveryThreshold}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final remainingForFreeDelivery = freeDeliveryThreshold - subtotal;
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.local_shipping, color: Colors.green),
          SizedBox(width: 8),
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

class ApplyCoupon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Apply Coupon',
                border: InputBorder.none,
              ),
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}

class TotalSection extends StatelessWidget {
  final double subtotal;
  final double total;
  final double freeDeliveryThreshold;
  final double deliveryCharge;

  const TotalSection({
    Key? key,
    required this.subtotal,
    required this.total,
    required this.freeDeliveryThreshold,
    required this.deliveryCharge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: GoogleFonts.poppins(fontSize: 16)),
              Text('₹${subtotal.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
          SizedBox(height: 8),
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

class CheckoutButton extends StatelessWidget {
  final double total;

  const CheckoutButton({Key? key, required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        child: Text('Checkout ₹${total.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          // Implement checkout logic
        },
      ),
    );
  }
}
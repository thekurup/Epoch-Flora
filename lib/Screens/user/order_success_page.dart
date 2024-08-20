import 'package:epoch/Screens/user/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:epoch/database/user_database.dart';

class OrderSuccessPage extends StatefulWidget {
  final List<CartItem> orderedItems;
  final double totalPrice;
  final Address billingAddress;

  const OrderSuccessPage({
    Key? key,
    required this.orderedItems,
    required this.totalPrice,
    required this.billingAddress,
  }) : super(key: key);

  @override
  _OrderSuccessPageState createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> with TickerProviderStateMixin {

  
  late AnimationController _controller;
  // AnimationController: Controls the animation that plays when the page is displayed.

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // _controller: Sets up the animation to last for 3 seconds.
      duration: const Duration(seconds: 3),
      // _controller.forward(): Starts the animation.
      vsync: this,
    );

    // Start the animation
    _controller.forward();

    // Save order to database
    _saveOrder();

    // Clear cart
    UserDatabase.clearCart();

    // Redirect to home page after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false,
      );
    });
  }

// Saves each ordered item to the database
  void _saveOrder() async {
    try {
      for (var item in widget.orderedItems) {
        final order = Order(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productName: item.product.name,
          status: 'Order Placed',
          price: item.product.price,
          date: DateTime.now(),
          imageUrl: item.product.imagePath,
          quantity: item.quantity,
        );
        await UserDatabase.saveOrder(order);
        print('Saved order: ${order.id} - ${order.productName}');
      }
      print('All orders saved successfully. Total items: ${widget.orderedItems.length}, Total price: ${widget.totalPrice}');
    } catch (e) {
      print('Error saving orders: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
//   Cleans up the animation controller when the widget is removed from the widget tree.
// _controller.dispose(): Disposes of the animation controller to free up resources.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Order Placed Successfully!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Lottie.asset(
                  'assets/animations/order_success.json',
                  controller: _controller,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 30),
                Text(
                  'We are on the way to your ${widget.billingAddress.type}!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Thank you for your purchase',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Redirecting to home page...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
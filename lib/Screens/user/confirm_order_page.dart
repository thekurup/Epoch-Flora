import 'package:epoch/Screens/user/order_success_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'dart:io';

class ConfirmOrderPage extends StatefulWidget {
  final Address selectedAddress;

  const ConfirmOrderPage({Key? key, required this.selectedAddress}) : super(key: key);

  @override
  _ConfirmOrderPageState createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  bool isCashOnDelivery = false;
  List<CartItem> cartItems = [];
  double subtotal = 0;
  double totalPrice = 0;
  double deliveryCharge = 80;
  double freeDeliveryThreshold = 1200;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    setState(() {
      cartItems = UserDatabase.getCartItems();
      subtotal = UserDatabase.getCartTotal();
      totalPrice = subtotal + (subtotal >= freeDeliveryThreshold ? 0 : deliveryCharge);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Order', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF3A3A5A)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderSummary(),
                      SizedBox(height: 24),
                      _buildBillingAddress(),
                      SizedBox(height: 24),
                      _buildPaymentOption(),
                    ],
                  ),
                ),
              ),
            ),
            _buildPlaceOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16),
          ...cartItems.map((item) => _buildOrderItem(item)).toList(),
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1, height: 32),
          _buildPriceSummary(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(item.product.imagePath),
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('Quantity: ${item.quantity}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
          Text(
            '₹${(item.product.price * item.quantity).toStringAsFixed(2)}',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      children: [
        _buildPriceRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
        SizedBox(height: 10),
        _buildPriceRow(
          'Delivery',
          subtotal >= freeDeliveryThreshold ? 'FREE' : '₹${deliveryCharge.toStringAsFixed(2)}',
          icon: Icons.local_shipping,
          color: subtotal >= freeDeliveryThreshold ? Colors.greenAccent : Colors.white.withOpacity(0.7),
        ),
        Divider(color: Colors.white.withOpacity(0.2), thickness: 1, height: 32),
        _buildPriceRow(
          'Total',
          '₹${totalPrice.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {IconData? icon, Color? color, TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: color ?? Colors.white.withOpacity(0.7)),
                SizedBox(width: 8),
              ],
              Text(label, style: style ?? GoogleFonts.poppins(fontSize: 16, color: Colors.white.withOpacity(0.9))),
            ],
          ),
          Text(value, style: style ?? GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBillingAddress() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Billing Address',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(widget.selectedAddress.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4),
          Text(widget.selectedAddress.street, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8))),
          Text('${widget.selectedAddress.city}, ${widget.selectedAddress.state}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8))),
          Text('${widget.selectedAddress.zipCode}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8))),
          SizedBox(height: 8),
          Text('PH: ${widget.selectedAddress.phone}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildPaymentOption() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Option',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Checkbox(
                  value: isCashOnDelivery,
                  onChanged: (value) {
                    setState(() {
                      isCashOnDelivery = value ?? false;
                    });
                  },
                  activeColor: Colors.greenAccent,
                  checkColor: Colors.black,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              SizedBox(width: 12),
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/cash.jpg'),
                radius: 24,
              ),
              SizedBox(width: 16),
              Text('Cash On Delivery', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'In future updates, we will bring an online payment option.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: EdgeInsets.all(20),
      child: child,
    );
  }

  Widget _buildPlaceOrderButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () {
          if (isCashOnDelivery) {
            _placeOrder();
          } else {
            _showValidationMessage('Please choose a payment option to place your order.');
          }
        },
        child: Text(
          'Place Order',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  void _showValidationMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  message,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _placeOrder() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OrderSuccessPage(
          orderedItems: cartItems,
          totalPrice: totalPrice,
          billingAddress: widget.selectedAddress,
        ),
      ),
    );
  }
}
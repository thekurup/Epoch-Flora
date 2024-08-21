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
  bool isCashOnDelivery = true;
  List<CartItem> cartItems = [];
  double subtotal = 0;
  double totalPrice = 0;
  double deliveryCharge = 80; // Set the delivery charge
  double freeDeliveryThreshold = 1200; // Set the minimum amount for free delivery

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
        
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(),
                SizedBox(height: 20),
                _buildBillingAddress(),
                SizedBox(height: 20),
                _buildPaymentOption(),
                SizedBox(height: 20),
                _buildPlaceOrderButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 12),
            ...cartItems.map((item) => _buildOrderItem(item)).toList(),
            Divider(color: Colors.grey[300], thickness: 1),
            _buildPriceSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(item.product.imagePath),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Text('Quantity: ${item.quantity}', style: GoogleFonts.poppins(color: Colors.grey[600])),
              ],
            ),
          ),
          Text(
            '₹${(item.product.price * item.quantity).toStringAsFixed(2)}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      children: [
        _buildPriceRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
        SizedBox(height: 8),
        _buildPriceRow(
          'Delivery',
          subtotal >= freeDeliveryThreshold ? 'FREE' : '₹${deliveryCharge.toStringAsFixed(2)}',
          icon: Icons.local_shipping,
          color: subtotal >= freeDeliveryThreshold ? Colors.green : null,
        ),
        Divider(color: Colors.grey[300], thickness: 1),
        _buildPriceRow(
          'Total',
          '₹${totalPrice.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
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
                Icon(icon, size: 20, color: color ?? Colors.grey[600]),
                SizedBox(width: 8),
              ],
              Text(label, style: style ?? GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
          Text(value, style: style ?? GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildBillingAddress() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Address',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 12),
            Text(widget.selectedAddress.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            Text(widget.selectedAddress.street, style: GoogleFonts.poppins()),
            Text('${widget.selectedAddress.city}, ${widget.selectedAddress.state}', style: GoogleFonts.poppins()),
            Text('${widget.selectedAddress.zipCode}', style: GoogleFonts.poppins()),
            Text('PH: ${widget.selectedAddress.phone}', style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Checkbox(
              value: isCashOnDelivery,
              onChanged: (value) {
                setState(() {
                  isCashOnDelivery = value ?? true;
                });
              },
              activeColor: Colors.green,
            ),
            SizedBox(width: 8),
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/cash.jpg'),
              radius: 20,
            ),
            SizedBox(width: 12),
            Text('Cash On Delivery', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        onPressed: () {
          _placeOrder();
        },
        child: Text(
          'Place Order',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _placeOrder() {
    // Navigate to the OrderSuccessPage
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
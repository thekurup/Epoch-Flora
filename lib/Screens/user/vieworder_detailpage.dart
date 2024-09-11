import 'package:epoch/Screens/user/order_tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ViewOrderDetailPage extends StatefulWidget {
  final Order order;

  const ViewOrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _ViewOrderDetailPageState createState() => _ViewOrderDetailPageState();
}

class _ViewOrderDetailPageState extends State<ViewOrderDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(0.5, 0), end: Offset.zero).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(child: Text('View Order details',style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),)),
        backgroundColor: Colors.green,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
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
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductDetailsCard(),
                    SizedBox(height: 24),
                    _buildOrderDetailsCard(),
                    SizedBox(height: 24),
                    _buildPaymentMethodCard(),
                    SizedBox(height: 24),
                    _buildShippingAddressCard(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildTrackShipmentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsCard() {
    return _buildAnimatedCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(widget.order.imageUrl),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return Icon(Icons.error, size: 100, color: Colors.white);
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.productName,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  '₹${widget.order.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.green),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    double productTotal = widget.order.price * widget.order.quantity;
    double deliveryPrice = widget.order.deliveryPrice;
    double total = productTotal + deliveryPrice;

    return _buildAnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Order Date', DateFormat('dd-MMM-yyyy').format(widget.order.date)),
          _buildDetailRow('No of Item', '${widget.order.quantity} item${widget.order.quantity > 1 ? 's' : ''}'),
          _buildDetailRow('Delivery', deliveryPrice > 0 ? '₹${deliveryPrice.toStringAsFixed(2)}' : 'Free'),
          _buildDetailRow('Product Total', '₹${productTotal.toStringAsFixed(2)}'),
          _buildDetailRow('Order total', '₹${total.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return _buildAnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text('Pay on Delivery', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildShippingAddressCard() {
    return FutureBuilder<Address?>(
      future: UserDatabase.getAddressByOrderId(widget.order.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading address', style: GoogleFonts.poppins(color: Colors.red));
        } else if (snapshot.hasData && snapshot.data != null) {
          Address address = snapshot.data!;
          return _buildAnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shipping Address', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 8),
                Text(address.name, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[300])),
                Text(address.street, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[300])),
                Text('${address.city}, ${address.state}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[300])),
                Text('${address.zipCode}, India', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[300])),
                Text('PH: ${address.phone}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[300])),
              ],
            ),
          );
        } else {
          return Text('No address found', style: GoogleFonts.poppins(color: Colors.grey[300]));
        }
      },
    );
  }

  Widget _buildTrackShipmentButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderTrackerPage(orderId: widget.order.id)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Track shipment', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[300])),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class CancelOrderPage extends StatefulWidget {
  @override
  _CancelOrderPageState createState() => _CancelOrderPageState();
}

class _CancelOrderPageState extends State<CancelOrderPage> {
  List<Order> canceledOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCanceledOrders();
  }

  Future<void> _loadCanceledOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch canceled orders from the database
      final loadedOrders = UserDatabase.getCanceledOrders();
      setState(() {
        canceledOrders = loadedOrders;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading canceled orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canceled Orders', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCanceledOrders,
              child: canceledOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: canceledOrders.length,
                      itemBuilder: (context, index) {
                        return CanceledOrderCard(
                          order: canceledOrders[index],
                          onOrderAgain: () => _orderAgain(canceledOrders[index]),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined, size: 100, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No Canceled Orders',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'You haven\'t canceled any orders yet.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _orderAgain(Order order) async {
    // Implement order again functionality
    // This could involve creating a new order based on the canceled one
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order Again functionality coming soon!')),
    );
  }
}

class CanceledOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onOrderAgain;

  const CanceledOrderCard({Key? key, required this.order, required this.onOrderAgain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double productTotal = order.price * order.quantity;
    double deliveryPrice = order.deliveryPrice;
    double total = productTotal + deliveryPrice;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(order.imageUrl),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Icon(Icons.error, size: 80);
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Canceled',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Product Price: ₹${order.price.toStringAsFixed(2)} x ${order.quantity}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Product Total: ₹${productTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (deliveryPrice > 0) ...[
                        SizedBox(height: 4),
                        Text(
                          'Delivery Price: ₹${deliveryPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                      SizedBox(height: 4),
                      Text(
                        'Total: ₹${total.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ordered on: ${DateFormat('MMM d, yyyy').format(order.date)}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onOrderAgain,
              child: Text('Order Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size(double.infinity, 40), // makes the button full width
              ),
            ),
          ],
        ),
      ),
    );
  }
}
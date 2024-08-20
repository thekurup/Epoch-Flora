import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:epoch/screens/user/cancel_order_page.dart';

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      print('Starting to load orders...'); // Debug print
      final loadedOrders = await UserDatabase.getOrders();
      print('Loaded ${loadedOrders.length} orders'); // Debug print
      setState(() {
        orders = loadedOrders;
        isLoading = false;
      });
      for (var order in orders) {
        print('Order: ${order.id} - ${order.productName} - ${order.status}'); // Debug print
      }
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showCancelConfirmation(Order order) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/cancel_order.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16),
              Text('Are you sure you want to cancel this order?'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _cancelOrder(order);
    }
  }

  // Updated: _cancelOrder method now refreshes the order list after cancellation
  Future<void> _cancelOrder(Order order) async {
    bool removed = await UserDatabase.removeOrder(order.id);

    if (removed) {
      await _loadOrders(); // Refresh the order list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order canceled successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel the order. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CancelOrderPage()),
              );
              _loadOrders(); // Refresh orders when returning from CancelOrderPage
            },
            tooltip: 'View Canceled Orders',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(child: Text('No orders yet', style: GoogleFonts.poppins(fontSize: 18)))
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(
                        order: orders[index],
                        onCancel: () => _showCancelConfirmation(orders[index]),
                      );
                    },
                  ),
                ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onCancel;

  const OrderCard({Key? key, required this.order, required this.onCancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double productTotal = order.price * order.quantity;
    double deliveryPrice = order.deliveryPrice ?? 0;  // Use 0 if deliveryPrice is null
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
                      print('Error loading image: $error'); // Debug print
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
                        order.status,
                        style: GoogleFonts.poppins(
                          color: Colors.green,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tracking functionality coming soon!')),
                      );
                    },
                    child: Text('Track'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCancel,
                    child: Text('Cancel order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AdminOrderDetailPage extends StatefulWidget {
  final Order order;

  const AdminOrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _AdminOrderDetailPageState createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  late String _selectedStatus;
  final List<String> _statusOptions = ['Order Placed', 'Order Confirmed', 'Shipped', 'Reached Nearby Hub', 'Out for Delivery', 'Delivered'];
  late Future<User?> _userFuture;
  late Future<Address?> _addressFuture;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    if (!_statusOptions.contains(_selectedStatus)) {
      _selectedStatus = _statusOptions.first;
    }
    _userFuture = UserDatabase.getUserByOrderId(widget.order.id);
    _addressFuture = UserDatabase.getAddressByOrderId(widget.order.id);
    
    // Debug print
    print('Order ID: ${widget.order.id}');
    print('User ID: ${widget.order.userId}');
    print('Address ID: ${widget.order.addressId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              SizedBox(height: 20),
              _buildOrderedItems(),
              SizedBox(height: 20),
              _buildShippingAddress(),
              SizedBox(height: 20),
              _buildDeliveryStatusDropdown(),
              SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${widget.order.id}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Order Date: ${DateFormat('MMM d, yyyy HH:mm').format(widget.order.date)}', style: GoogleFonts.poppins(fontSize: 16)),
                SizedBox(height: 8),
                Text('Customer Name: ${user?.username ?? 'Unknown'}', style: GoogleFonts.poppins(fontSize: 16)),
                SizedBox(height: 8),
                Text('User ID: ${widget.order.userId}', style: GoogleFonts.poppins(fontSize: 16)),  // Debug info
                if (snapshot.hasError)
                  Text('Error: ${snapshot.error}', style: GoogleFonts.poppins(color: Colors.red)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderedItems() {
    double totalPrice = widget.order.price * widget.order.quantity + widget.order.deliveryPrice;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ordered Items', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(widget.order.imageUrl),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return Icon(Icons.error, size: 50);
                  },
                ),
              ),
              title: Text(widget.order.productName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity: ${widget.order.quantity}', style: GoogleFonts.poppins()),
                  Text('Price: ₹${widget.order.price.toStringAsFixed(2)}', style: GoogleFonts.poppins()),
                  Text('Delivery Fee: ₹${widget.order.deliveryPrice.toStringAsFixed(2)}', style: GoogleFonts.poppins()),
                ],
              ),
              trailing: Text(
                'Total: ₹${totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddress() {
    return FutureBuilder<Address?>(
      future: _addressFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final address = snapshot.data;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shipping Address', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text(address?.name ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 16)),
                Text(address?.street ?? '', style: GoogleFonts.poppins(fontSize: 16)),
                Text('${address?.city ?? ''}, ${address?.state ?? ''}', style: GoogleFonts.poppins(fontSize: 16)),
                Text('${address?.zipCode ?? ''}, India', style: GoogleFonts.poppins(fontSize: 16)),
                Text('Ph: ${address?.phone ?? ''}', style: GoogleFonts.poppins(fontSize: 16)),
                SizedBox(height: 8),
                Text('Address ID: ${widget.order.addressId}', style: GoogleFonts.poppins(fontSize: 16)),  // Debug info
                if (snapshot.hasError)
                  Text('Error: ${snapshot.error}', style: GoogleFonts.poppins(color: Colors.red)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeliveryStatusDropdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Status', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                }
              },
              items: _statusOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.poppins()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          try {
            await UserDatabase.updateOrderStatus(widget.order.id, _selectedStatus);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order status updated successfully')),
            );
            Navigator.pop(context, true); // Return true to indicate successful update
          } catch (e) {
            print('Error updating order status: $e'); // Debug print
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update order status: ${e.toString()}')),
            );
          }
        },
        child: Text('Save', style: GoogleFonts.poppins(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
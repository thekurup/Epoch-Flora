// ignore_for_file: prefer_const_constructors

import 'package:epoch/Screens/user/vieworder_detailpage.dart';
import 'package:epoch/Screens/user/my_orders_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:intl/intl.dart';

class OrderTrackerPage extends StatefulWidget {
  final String orderId;

  const OrderTrackerPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderTrackerPageState createState() => _OrderTrackerPageState();
}

class _OrderTrackerPageState extends State<OrderTrackerPage> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _heartbeatController;
  late Animation<double> _progressAnimation;
  Order? _order;
  String _currentStatus = '';

  final List<String> _statusList = [
    // List of order statuses to be displayed and tracked.
    'Order Placed',
    'Order Confirmed',
    'Shipped',
    'Reached Nearby Hub',
    'Out for Delivery',
    'Delivered'
  ];

  final List<IconData> _statusIcons = [
    //  list store Corresponding icons for each order status.
    Icons.receipt_long,
    Icons.check_circle,
    Icons.local_shipping,
    Icons.hub,
    Icons.delivery_dining,
    Icons.home,
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _heartbeatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(_progressController);
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    // Load the order details from the database and update the current status and progress.
    final order = await UserDatabase.getOrderById(widget.orderId);
    if (order != null) {
      setState(() {
        _order = order;
        _currentStatus = order.status;
      });
      _updateProgress();
    }
  }

  void _updateProgress() {
    // _updateProgress: Calculate the progress based on the current status 
    // and animate the progress bar accordingly.
    if (_order != null) {
      final currentStatusIndex = _statusList.indexOf(_currentStatus);
      final progress = (currentStatusIndex + 1) / _statusList.length;
      _progressController.animateTo(progress);
    }
  }

  @override
  void dispose() {
    // Dispose of the animation controllers to free up resources
    //  when the widget is removed from the widget tree.
    _progressController.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Order Tracker', style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyOrdersPage()),
            );
          },
        ),
      ),
      body: Container(
        // Body: Set up the body with a background gradient. If the order is not loaded
        //  yet, show a loading indicator; otherwise, display the order tracker and order info.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF3A3A5A)],
          ),
        ),
        child: _order == null
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildOrderTracker(),
                        _buildOrderInfo(),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderTracker() {
    // _buildOrderTracker: Build the order tracker section that shows
    // the progress of the order through different statuses using a custom painter 
    // and animated builder.
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You can track your order\'s journey here and stay updated on its arrival at your doorstep! 🌱🚚',
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[300]),
          ),
          SizedBox(height: 30),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ProgressLinePainter(
                  progress: _progressAnimation.value,
                  statusList: _statusList,
                  currentStatus: _currentStatus,
                ),
                child: Column(
                  children: List.generate(_statusList.length, (index) {
                    final status = _statusList[index];
                    final isCompleted = _progressAnimation.value >= (index + 1) / _statusList.length;
                    final isCurrentStatus = _currentStatus == status;
                    return _buildStatusStep(
                      status: status,
                      isCompleted: isCompleted,
                      isCurrentStatus: isCurrentStatus,
                      isLastStep: index == _statusList.length - 1,
                      icon: _statusIcons[index],
                      index: index,
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep({
    // _buildStatusStep: A widget that represents each step in the order tracking process. 
    // It checks if the step is completed or is the current status,
    //  and also retrieves the timestamp for the status.
    required String status,
    required bool isCompleted,
    required bool isCurrentStatus,
    required bool isLastStep,
    required IconData icon,
    required int index,
  }) {
    // New: Get the timestamp for this status
    final timestamp = _order!.getStatusTimestamp(status);

    return Row(
      children: [
        Column(
          children: [
            AnimatedBuilder(
              animation: _heartbeatController,
              builder: (context, child) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrentStatus ? Color(0xFF00AAFF) : Colors.grey[700],
                    boxShadow: [
                      BoxShadow(
                        color: isCurrentStatus
                            ? Color(0xFF00AAFF).withOpacity(0.5)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: isCurrentStatus ? 15 * _heartbeatController.value : 5,
                        spreadRadius: isCurrentStatus ? 5 * _heartbeatController.value : 1,
                      )
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: isCompleted || isCurrentStatus ? Colors.white : Colors.grey[400],
                    size: 24,
                  ),
                );
              },
            ),
            if (!isLastStep)
              Container(
                width: 2,
                height: 30,
                color: Colors.grey[700],
              ),
          ],
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: isCurrentStatus ? 18 : 16,
                  fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted || isCurrentStatus ? Colors.white : Colors.grey[400],
                ),
              ),
              if (isCurrentStatus)
                Text(
                  'Your order is ${status.toLowerCase()}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFF00AAFF)),
                ),
              // New: Display timestamp only if it exists
              if (timestamp != null)
                Text(
                  DateFormat('dd/MM/yyyy, HH:mm').format(timestamp),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Info',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              if (_order != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewOrderDetailPage(order: _order!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order details not available')),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF00AAFF)),
                  SizedBox(width: 10),
                  Text(
                    'View order details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Color(0xFF00AAFF), size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressLinePainter extends CustomPainter {
  final double progress;
  final List<String> statusList;
  final String currentStatus;

  ProgressLinePainter({required this.progress, required this.statusList, required this.currentStatus});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final completedPaint = Paint()
      ..color = Color(0xFF00AAFF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final double stepHeight = size.height / (statusList.length - 1);

    for (int i = 0; i < statusList.length - 1; i++) {
      final start = Offset(20, stepHeight * i + 20);
      final end = Offset(20, stepHeight * (i + 1) + 20);

      if (progress > i / (statusList.length - 1)) {
        final completedEnd = Offset(20, stepHeight * i + 20 + (stepHeight * (progress - i / (statusList.length - 1))));
        canvas.drawLine(start, completedEnd, completedPaint);
        canvas.drawLine(completedEnd, end, paint);
      } else {
        canvas.drawLine(start, end, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
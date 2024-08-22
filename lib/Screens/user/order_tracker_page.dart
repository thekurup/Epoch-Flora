import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    'Order Placed',
    'Order Confirmed',
    'Shipped',
    'Reached Nearby Hub',
    'Out for Delivery',
    'Delivered'
  ];

  final List<String> _iconPaths = [
    'assets/icons/seed.svg',
    'assets/icons/sprout.svg',
    'assets/icons/small_plant.svg',
    'assets/icons/nearby_hub.svg',
    'assets/icons/blooming_plant.svg',
    'assets/icons/grown_plant.svg',
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
    if (_order != null) {
      final currentStatusIndex = _statusList.indexOf(_currentStatus);
      final progress = (currentStatusIndex + 1) / _statusList.length;
      _progressController.animateTo(progress);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Tracker', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _order == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildOrderTracker(),
                  _buildOrderInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderTracker() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please check your order status to get the item delivered to your home',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
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
                    final isCompleted = _progressAnimation.value >= (index + 1) / _statusList.length;
                    final isCurrentStatus = _currentStatus == _statusList[index];
                    return _buildStatusStep(
                      status: _statusList[index],
                      isCompleted: isCompleted,
                      isCurrentStatus: isCurrentStatus,
                      isLastStep: index == _statusList.length - 1,
                      date: _order!.date,
                      iconPath: _iconPaths[index],
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
    required String status,
    required bool isCompleted,
    required bool isCurrentStatus,
    required bool isLastStep,
    required DateTime date,
    required String iconPath,
    required int index,
  }) {
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
                    gradient: isCompleted || isCurrentStatus
                        ? LinearGradient(
                            colors: [Colors.green.shade300, Colors.green.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isCompleted || isCurrentStatus ? null : Colors.grey[300],
                    boxShadow: isCurrentStatus
                        ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 10 * _heartbeatController.value,
                              spreadRadius: 2 * _heartbeatController.value,
                            )
                          ]
                        : [],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      iconPath,
                      color: isCompleted || isCurrentStatus ? Colors.white : Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
            if (!isLastStep)
              Container(
                width: 2,
                height: 30,
                color: Colors.transparent,
              ),
          ],
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 300),
                style: GoogleFonts.poppins(
                  fontSize: isCurrentStatus ? 18 : 16,
                  fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted || isCurrentStatus ? Colors.green.shade700 : Colors.grey[600],
                ),
                child: Text(status),
              ),
              if (isCurrentStatus)
                Text(
                  'Your order is ${status.toLowerCase()}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.green.shade600),
                ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: isCompleted || isCurrentStatus ? 1.0 : 0.0,
                child: Text(
                  DateFormat('dd/MM/yyyy, HH:mm').format(date),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
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
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              // TODO: Implement navigation to Order Detail page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('View Order Details coming soon!')),
              );
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade600),
                  SizedBox(width: 10),
                  Text(
                    'View order details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Colors.green.shade600, size: 16),
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
      ..color = Colors.grey[300]!
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final completedPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue.shade300, Colors.blue.shade700],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
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
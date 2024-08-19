import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:epoch/Screens/user/add_address.dart';
// TODO: Uncomment when ConfirmOrderPage is implemented
// import 'package:epoch/Screens/user/confirm_order_page.dart';

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> with SingleTickerProviderStateMixin {
  Address? selectedAddress;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAddressSelected(Address address) {
    setState(() {
      selectedAddress = address;
      if (selectedAddress != null) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        
        title: Text('Select Address', 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/delivery.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AddressSection(
                              title: 'Home Address',
                              addresses: UserDatabase.getAddressesByType('Home'),
                              icon: Icons.home,
                              onAddressSelected: _onAddressSelected,
                              selectedAddress: selectedAddress,
                            ),
                            SizedBox(height: 20),
                            AddressSection(
                              title: 'Work Address',
                              addresses: UserDatabase.getAddressesByType('Work'),
                              icon: Icons.work,
                              onAddressSelected: _onAddressSelected,
                              selectedAddress: selectedAddress,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AddAddressButton(
                      onAddressAdded: () {
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 80,
                  child: ScaleTransition(
                    scale: _animation,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        // TODO: Navigate to ConfirmOrderPage
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => ConfirmOrderPage(selectedAddress: selectedAddress!)),
                        // );
                      },
                      label: Text('Next', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      icon: Icon(Icons.arrow_forward),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddressSection extends StatelessWidget {
  final String title;
  final List<Address> addresses;
  final IconData icon;
  final Function(Address) onAddressSelected;
  final Address? selectedAddress;

  const AddressSection({
    Key? key,
    required this.title,
    required this.addresses,
    required this.icon,
    required this.onAddressSelected,
    required this.selectedAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16),
          addresses.isEmpty
              ? Text('No address added', style: GoogleFonts.poppins(color: Colors.grey))
              : Container(
                  height: 200, // Fixed height for two address cards
                  child: ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      return AddressCard(
                        address: addresses[index],
                        isSelected: addresses[index] == selectedAddress,
                        onTap: () => onAddressSelected(addresses[index]),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onTap;

  const AddressCard({
    Key? key,
    required this.address,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 95, // Fixed height to ensure two cards fit in the 200-pixel container
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(address.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            Text(address.phone, style: GoogleFonts.poppins(fontSize: 12)),
            Text('${address.street}, ${address.city}', style: GoogleFonts.poppins(fontSize: 12)),
            Text('${address.state} ${address.zipCode}', style: GoogleFonts.poppins(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class AddAddressButton extends StatelessWidget {
  final VoidCallback onAddressAdded;

  const AddAddressButton({Key? key, required this.onAddressAdded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAddressPage()),
          ).then((_) {
            onAddressAdded();
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Add New Address',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
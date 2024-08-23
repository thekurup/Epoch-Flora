import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:epoch/Screens/user/add_address.dart';
import 'package:epoch/Screens/user/edit_address.dart';
import 'package:epoch/Screens/user/confirm_order_page.dart';

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> with SingleTickerProviderStateMixin {
  Address? selectedAddress;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Address> homeAddresses = [];
  List<Address> workAddresses = [];

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
    _loadAddresses();
  }

  void _loadAddresses() {
    setState(() {
      homeAddresses = UserDatabase.getAddressesByType('Home');
      workAddresses = UserDatabase.getAddressesByType('Work');
    });
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

  void _onEditAddress(Address address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAddressPage(address: address)),
    );
    if (result == true) {
      _loadAddresses();
    }
  }

  void _onDeleteAddress(Address address) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Address'),
          content: Text('Are you sure you want to delete this address?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    
    if (confirmDelete == true) {
      setState(() {
        UserDatabase.deleteAddress(address);
        _loadAddresses();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Address', 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF3A3A5A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      AddressSection(
                        title: 'Home Address',
                        addresses: homeAddresses,
                        icon: Icons.home,
                        onAddressSelected: _onAddressSelected,
                        selectedAddress: selectedAddress,
                        onEditAddress: _onEditAddress,
                        onDeleteAddress: _onDeleteAddress,
                      ),
                      SizedBox(height: 20),
                      AddressSection(
                        title: 'Work Address',
                        addresses: workAddresses,
                        icon: Icons.work,
                        onAddressSelected: _onAddressSelected,
                        selectedAddress: selectedAddress,
                        onEditAddress: _onEditAddress,
                        onDeleteAddress: _onDeleteAddress,
                      ),
                    ],
                  ),
                ),
              ),
              AddAddressButton(
                onAddressAdded: () {
                  _loadAddresses();
                },
              ),
              SizedBox(height: 80), // Space for the "Next" button
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton.extended(
          onPressed: () {
            if (selectedAddress != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfirmOrderPage(selectedAddress: selectedAddress!)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select an address before proceeding.')),
              );
            }
          },
          label: Text('Next', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          icon: Icon(Icons.arrow_forward),
          backgroundColor: Colors.green,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class AddressSection extends StatelessWidget {
  final String title;
  final List<Address> addresses;
  final IconData icon;
  final Function(Address) onAddressSelected;
  final Address? selectedAddress;
  final Function(Address) onEditAddress;
  final Function(Address) onDeleteAddress;

  const AddressSection({
    Key? key,
    required this.title,
    required this.addresses,
    required this.icon,
    required this.onAddressSelected,
    required this.selectedAddress,
    required this.onEditAddress,
    required this.onDeleteAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: addresses.isEmpty
                  ? Center(child: Text('No address added', style: GoogleFonts.poppins(color: Colors.grey[400])))
                  : ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        return AddressCardWithIcons(
                          address: addresses[index],
                          isSelected: addresses[index] == selectedAddress,
                          onTap: () => onAddressSelected(addresses[index]),
                          onEdit: () => onEditAddress(addresses[index]),
                          onDelete: () => onDeleteAddress(addresses[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressCardWithIcons extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCardWithIcons({
    Key? key,
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    address.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green.shade300 : Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[300]),
                  ),
                  Text(
                    '${address.street}, ${address.city}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[300]),
                  ),
                  Text(
                    '${address.state} ${address.zipCode}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(height: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
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
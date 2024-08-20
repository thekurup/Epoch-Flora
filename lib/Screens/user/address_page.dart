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
  // with SingleTickerProviderStateMixin: Allows the use of animation controllers
  Address? selectedAddress;
  // Stores the currently selected address.
  late AnimationController _controller;
  // Defines an animation controller for animations.
  late Animation<double> _animation;
  // Defines the animation used with the controller.
  List<Address> homeAddresses = [];
  // Holds the list of home addresses.
  List<Address> workAddresses = [];
  // Holds the list of work addresses.

  @override
  void initState() {
    // Initializes the state when the widget is created
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Creates an animation controller that lasts for 300 milliseconds.
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadAddresses();
  }

  void _loadAddresses() {
    // Method to load addresses from the database.
    setState(() {
      homeAddresses = UserDatabase.getAddressesByType('Home');
      workAddresses = UserDatabase.getAddressesByType('Work');
    });
    // Updates the state with the loaded addresses, triggering a UI rebuild.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  // Disposes of the animation controller to free up resources.


  void _onAddressSelected(Address address) {
    // void _onAddressSelected(Address address): Called when an address is selected.
    setState(() {
      selectedAddress = address;
      if (selectedAddress != null) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      // Updates the state with the selected address and animates the change.
    });
  }

  void _onEditAddress(Address address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAddressPage(address: address)),
    );
    // void _onEditAddress(Address address) async: Navigates to the edit address page and waits for the result.

// if (result == true): If the address was successfully updated, reload the address list.
    if (result == true) {
      // Address was successfully updated, refresh the address list
      _loadAddresses();
    }
  }

// void _onDeleteAddress(Address address) async: Shows a confirmation dialog for deleting an address.
  void _onDeleteAddress(Address address) async {
    // Show a confirmation dialog

    // await showDialog(...): Displays a dialog asking for confirmation.
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
    
// if (confirmDelete == true): If confirmed, deletes the address and reloads the list.
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Select Address', 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
              // Show a snackbar or dialog prompting the user to select an address
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
          color: Colors.white.withOpacity(0.7),
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
            Expanded(
              child: addresses.isEmpty
                  ? Center(child: Text('No address added', style: GoogleFonts.poppins(color: Colors.grey)))
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
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
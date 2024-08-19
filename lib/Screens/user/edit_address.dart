import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';

class EditAddressPage extends StatefulWidget {
  final Address address;

  const EditAddressPage({Key? key, required this.address}) : super(key: key);

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late String _addressType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address.name);
    _phoneController = TextEditingController(text: widget.address.phone);
    _streetController = TextEditingController(text: widget.address.street);
    _cityController = TextEditingController(text: widget.address.city);
    _stateController = TextEditingController(text: widget.address.state);
    _zipCodeController = TextEditingController(text: widget.address.zipCode);
    _addressType = widget.address.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Address',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Color(0xFFF0F4F0),  // Light green-gray background
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextFormField(_nameController, 'Full Name'),
                    SizedBox(height: 16),
                    _buildTextFormField(_phoneController, 'Phone Number'),
                    SizedBox(height: 16),
                    _buildTextFormField(_streetController, 'Address Line 1'),
                    SizedBox(height: 16),
                    _buildTextFormField(_cityController, 'City'),
                    SizedBox(height: 16),
                    _buildTextFormField(_stateController, 'State'),
                    SizedBox(height: 16),
                    _buildTextFormField(_zipCodeController, 'Postal Code'),
                    SizedBox(height: 24),
                    Text('Address Type', 
                        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Home', style: GoogleFonts.poppins(color: Colors.black87)),
                            value: 'Home',
                            groupValue: _addressType,
                            onChanged: (value) {
                              setState(() {
                                _addressType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Work', style: GoogleFonts.poppins(color: Colors.black87)),
                            value: 'Work',
                            groupValue: _addressType,
                            onChanged: (value) {
                              setState(() {
                                _addressType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _saveAddress,
                      child: Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: GoogleFonts.poppins(color: Colors.black87),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      // Update the existing address object
      widget.address.name = _nameController.text;
      widget.address.phone = _phoneController.text;
      widget.address.street = _streetController.text;
      widget.address.city = _cityController.text;
      widget.address.state = _stateController.text;
      widget.address.zipCode = _zipCodeController.text;
      widget.address.type = _addressType;

      bool success = await UserDatabase.updateAddress(widget.address);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address updated successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update address. Please try again.')),
        );
      }
    }
  }
}
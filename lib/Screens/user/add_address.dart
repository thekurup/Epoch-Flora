import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';

class AddAddressPage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _street = '';
  String _city = '';
  String _state = '';
  String _zipCode = '';
  String _addressType = 'Home';
  bool _isBillingAddress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Address', 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Name should only contain alphabets';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Phone number should be 10 digits';
                    }
                    return null;
                  },
                  onSaved: (value) => _phone = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Street Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a street address';
                    }
                    return null;
                  },
                  onSaved: (value) => _street = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'City'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a city';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'City should only contain alphabets';
                    }
                    return null;
                  },
                  onSaved: (value) => _city = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'State'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a state';
                    }
                    return null;
                  },
                  onSaved: (value) => _state = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'ZIP Code'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a ZIP code';
                    }
                    if (!RegExp(r'^\d{5}(\d{1})?$').hasMatch(value)) {
                      return 'ZIP code should be 5 or 6 digits';
                    }
                    return null;
                  },
                  onSaved: (value) => _zipCode = value!,
                ),
                SizedBox(height: 20),
                Text('Address Type', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Radio(
                      value: 'Home',
                      groupValue: _addressType,
                      onChanged: (value) {
                        setState(() {
                          _addressType = value.toString();
                        });
                      },
                    ),
                    Text('Home'),
                    Radio(
                      value: 'Work',
                      groupValue: _addressType,
                      onChanged: (value) {
                        setState(() {
                          _addressType = value.toString();
                        });
                      },
                    ),
                    Text('Work'),
                  ],
                ),
                // CheckboxListTile(
                //   title: Text('Set as Billing Address'),
                //   value: _isBillingAddress,
                //   onChanged: (value) {
                //     setState(() {
                //       _isBillingAddress = value!;
                //     });
                //   },
                // ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('Save Address'),
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Create a new address object using the Address class from user_database.dart
      Address newAddress = Address(
        _name,
        _phone,
        _street,
        _city,
        _state,
        _zipCode,
        _addressType,
        _isBillingAddress,
      );
      // Add the address to the database
      UserDatabase.addAddress(newAddress);
      // Navigate back to the AddressPage
      Navigator.pop(context);
    }
  }
}
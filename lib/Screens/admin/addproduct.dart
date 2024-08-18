// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:epoch/database/user_database.dart';

// This class represents the 'Add Product' page in our app
class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

// This class contains the state (data) and behavior for our 'Add Product' page
class _AddProductState extends State<AddProduct> {
  // This is like creating a unique ID for our form
  final _formKey = GlobalKey<FormState>();
  
  // These are like creating empty boxes to store text that the user will type
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  // This is like creating an empty box to store the category the user will select
  String? _selectedCategory;
  // This is like creating an empty box to store the image the user will pick
  File? _image;
  
  // This is like getting a tool ready to pick images from the device
  final ImagePicker _picker = ImagePicker();

  // This is like creating a list of options for the user to choose from
  List<String> _categories = ['Indoor Plant', 'Outdoor Plant', 'Flowering Plant'];

  // This is like a flag to check if the user has tried to submit the form
  bool _formSubmitted = false;
  // This keeps track of how many characters are in the description
  int _descriptionCharCount = 0;
  // This sets the maximum number of characters allowed in the description
  final int _maxCharCount = 100;

  @override
  void initState() {
    super.initState();
    // This is like setting up a listener to count characters as the user types
    _descriptionController.addListener(_updateDescriptionCharCount);
  }

  @override
  void dispose() {
    // This is like cleaning up after ourselves when we're done
    _descriptionController.removeListener(_updateDescriptionCharCount);
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // This function updates the character count for the description
  void _updateDescriptionCharCount() {
    setState(() {
      _descriptionCharCount = _descriptionController.text.length;
    });
  }

  // This function handles picking an image from the device's gallery
  Future<void> _pickImage() async {
    try {
      // This is like asking the device to open the photo gallery
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // If a photo was picked, we update our _image variable
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      // If something goes wrong, we print the error 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  @override
  // This function builds the user interface for our 'Add Product' page
  Widget build(BuildContext context) {
    return Scaffold(
      // This creates the top bar of our page
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.green,
      ),
      // This creates the main content of our page
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // These are the different input fields and buttons on our page
              _buildTextField('Name', _nameController, 'Enter Name'),
              SizedBox(height: 16),
              _buildDescriptionField(),
              SizedBox(height: 16),
              _buildTextField('Price', _priceController, 'Enter Price'),
              SizedBox(height: 16),
              _buildCategoryDropdown(),
              SizedBox(height: 16),
              _buildImagePicker(),
              SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // This function builds a text input field
  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // This is the label above the input field
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        // This is the actual input field
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
            errorStyle: TextStyle(color: Colors.red),
          ),
          maxLines: maxLines,
          // This checks if the input is valid when the user submits the form
          validator: (value) {
            if (_formSubmitted && (value == null || value.isEmpty)) {
              return 'Please enter ${label.toLowerCase()}';
            }
            if (label == 'Name') {
              // This checks if the name contains only letters and spaces
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
                return 'Product name should only contain characters';
              }
              // This checks if the name is at least 3 characters long
              if (value.trim().length < 3) {
                return 'Product name must contain at least 3 characters';
              }
            }
            if (label == 'Price') {
              // This checks if the price is a valid number
              if (double.tryParse(value!) == null) {
                return 'Please enter a valid number';
              }
              // This checks if the price is greater than 0
              if (double.parse(value) <= 0) {
                return 'Price must be greater than 0';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  // This function builds the description input field
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Stack(
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter description',
                border: OutlineInputBorder(),
                errorStyle: TextStyle(color: Colors.red),
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 30),
              ),
              maxLines: 3,
              validator: (value) {
                if (_formSubmitted && (value == null || value.isEmpty)) {
                  return 'Please enter description';
                }
                return null;
              },
              // This limits the number of characters the user can enter
              inputFormatters: [
                LengthLimitingTextInputFormatter(_maxCharCount),
              ],
            ),
            // This shows the remaining character count
            Positioned(
              right: 10,
              bottom: 10,
              child: Text(
                '${_maxCharCount - _descriptionCharCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: (_maxCharCount - _descriptionCharCount) < 50 ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // This function builds the category dropdown
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          hint: Text('Select Category'),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_formSubmitted && value == null) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  // This function builds the image picker
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.cover)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Click to browse', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
          ),
        ),
        if (_formSubmitted && _image == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select a product image.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // This function builds the save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _validateAndSaveProduct,
        child: Text('Save'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // This function validates the form and saves the product if everything is correct
  void _validateAndSaveProduct() {
    setState(() {
      _formSubmitted = true;
    });

    if (_formKey.currentState!.validate() && _image != null) {
      _saveProduct();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly, select a category, and select an image')),
      );
    }
  }

  // This function saves the product to the database
  Future<void> _saveProduct() async {
    try {
      String? imagePath;
      if (_image != null) {
        // This saves the picked image to the app's documents directory
        final directory = await getApplicationDocumentsDirectory();
        final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.png';
        final savedImage = await _image!.copy('${directory.path}/$fileName');
        imagePath = savedImage.path;
      }

      // This creates a new Product object with the entered information
      final product = Product(
        _nameController.text,
        _descriptionController.text,
        double.parse(_priceController.text),
        _selectedCategory!,
        imagePath ?? '',
      );

      // This adds the product to the database
      final success = await UserDatabase.addProduct(product);

      if (success) {
        // If the product was saved successfully, we show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product saved successfully')),
        );
        
        // This refreshes the page by creating a new instance of AddProduct
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AddProduct()),
        );
      } else {
        // If the product couldn't be saved, we show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save product')),
        );
      }
    } catch (e) {
      // If an error occurs, we print it and show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while saving the product')),
      );
    }
  }
}
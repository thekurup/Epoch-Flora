// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:epoch/database/user_database.dart';

// This class represents the 'Edit Product' page in our app
class EditProduct extends StatefulWidget {
  // This is like passing a specific product to edit, like handing someone a form with pre-filled information
  final Product product;

  const EditProduct({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

// This class contains all the logic and UI for editing a product
class _EditProductState extends State<EditProduct> {
  // This is like a unique ID for our form
  final _formKey = GlobalKey<FormState>();
  
  // These are like boxes to store the text that the user will type
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  
  // This is like a box to store the category the user will select
  String? _selectedCategory;
  // This is like a box to store the image the user will pick
  File? _image;
  
  // This is like a tool to pick images from the device
  final ImagePicker _picker = ImagePicker();

  // New: This is now a dynamic list that will be populated from the database
  List<String> _categories = [];

  // This is like a flag to check if the user has tried to submit the form
  bool _formSubmitted = false;
  // This keeps track of how many characters are in the description
  int _descriptionCharCount = 0;
  // This sets the maximum number of characters allowed in the description
  final int _maxCharCount = 500;

  @override
  // This function runs when the page is first created
  void initState() {
    super.initState();
    // These lines are like filling out a form with existing information
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _selectedCategory = widget.product.category;
    _image = File(widget.product.imagePath);
    // This sets up a listener to count characters as the user types in the description
    _descriptionController.addListener(_updateDescriptionCharCount);
    _updateDescriptionCharCount();
    // New: Load categories from the database
    _loadCategories();
  }

  // New: This function loads categories from the database
  void _loadCategories() {
    final categories = UserDatabase.getAllCategories();
    setState(() {
      _categories = categories.map((category) => category.name).toList();
      // If the product's category is not in the list, add it
      if (!_categories.contains(_selectedCategory)) {
        _categories.add(_selectedCategory!);
      }
    });
  }

  @override
  // This function runs when the page is closed
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
      // If something goes wrong, we print the error and show a message to the user
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  @override
  // This function builds the user interface for our 'Edit Product' page
  Widget build(BuildContext context) {
    return Scaffold(
      // This creates the top bar of our page
      appBar: AppBar(
        title: Text('Edit Product'),
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
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
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
  // Updated: Now uses the dynamic _categories list
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
        onPressed: _validateAndUpdateProduct,
        child: Text('Update'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // This function validates the form and updates the product if everything is correct
  // Updated: Now checks for a selected category
  void _validateAndUpdateProduct() {
    setState(() {
      _formSubmitted = true;
    });

    if (_formKey.currentState!.validate() && _image != null && _selectedCategory != null) {
      _updateProduct();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly, select a category, and select an image')),
      );
    }
  }

  // This function updates the product in the database
  // Updated: Now includes the selected category when creating the updated product
  Future<void> _updateProduct() async {
    try {
      String imagePath = widget.product.imagePath;
      // If a new image was selected, we save it and get its new path
      if (_image != null && _image!.path != widget.product.imagePath) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.png';
        final savedImage = await _image!.copy('${directory.path}/$fileName');
        imagePath = savedImage.path;
      }

      // Create a new Product instance with updated values
      final updatedProduct = Product(
        _nameController.text,
        _descriptionController.text,
        double.parse(_priceController.text),
        _selectedCategory!,
        imagePath,
        isFavorite: widget.product.isFavorite,
      );

      // Use the updateProduct method from UserDatabase, passing both the key and the updated product
      final success = await UserDatabase.updateProduct(widget.product.key, updatedProduct);

      if (success) {
        // If the update was successful, we show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')),
        );
        
        // Navigate back to the product list page after a short delay
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // This will return to the product list page
        });
      } else {
        // If the update failed, we show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product')),
        );
      }
    } catch (e) {
      // If an error occurs, we print it and show an error message
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while updating the product')),
      );
    }
  }
}
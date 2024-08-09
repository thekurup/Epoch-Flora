import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:epoch/database/user_database.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for text fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  // Selected category and image file
  String _selectedCategory = 'Indoor Plant';
  File? _image;
  
  // ImagePicker instance for image selection
  final ImagePicker _picker = ImagePicker();

  // List of available categories
  List<String> _categories = ['Indoor Plant', 'Outdoor Plant', 'Flowering Plant'];

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Name', _nameController, 'Enter Name'),
              SizedBox(height: 16),
              _buildTextField('Description', _descriptionController, 'Enter description', maxLines: 3),
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

  // Helper method to build text fields
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
          ),
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (label == 'Price' && double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Helper method to build the category dropdown
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Helper method to build the image picker
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
      ],
    );
  }

  // Helper method to build the save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProduct,
        child: Text('Save'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Method to handle saving the product
  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Save the image to local storage and get the path
        String? imagePath;
        if (_image != null) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.png';
          final savedImage = await _image!.copy('${directory.path}/$fileName');
          imagePath = savedImage.path;
        }

        // Create a new Product object
        final product = Product(
          _nameController.text,
          _descriptionController.text,
          double.parse(_priceController.text),
          _selectedCategory,
          imagePath ?? '',
        );

        // Save the product to the database
        final success = await UserDatabase.addProduct(product);

        if (success) {
          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product saved successfully')),
          );
          
          // Clear the form
          _nameController.clear();
          _descriptionController.clear();
          _priceController.clear();
          setState(() {
            _selectedCategory = 'Indoor Plant';
            _image = null;
          });
        } else {
          // Show an error message if saving failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save product')),
          );
        }
      } catch (e) {
        // Print the error to the console for debugging
        print('Error saving product: $e');
        // Show an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while saving the product')),
        );
      }
    }
  }
}
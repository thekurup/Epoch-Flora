import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:epoch/database/user_database.dart';

class EditProduct extends StatefulWidget {
  final Product product;

  const EditProduct({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  
  String? _selectedCategory;
  File? _image;
  
  final ImagePicker _picker = ImagePicker();

  List<String> _categories = ['Indoor Plant', 'Outdoor Plant', 'Flowering Plant'];

  bool _formSubmitted = false;
  int _descriptionCharCount = 0;
  final int _maxCharCount = 500;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _selectedCategory = widget.product.category;
    _image = File(widget.product.imagePath);
    _descriptionController.addListener(_updateDescriptionCharCount);
    _updateDescriptionCharCount();
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateDescriptionCharCount);
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateDescriptionCharCount() {
    setState(() {
      _descriptionCharCount = _descriptionController.text.length;
    });
  }

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
        title: Text('Edit Product'),
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
          validator: (value) {
            if (_formSubmitted && (value == null || value.isEmpty)) {
              return 'Please enter ${label.toLowerCase()}';
            }
            if (label == 'Name') {
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
                return 'Product name should only contain characters';
              }
              if (value.trim().length < 3) {
                return 'Product name must contain at least 3 characters';
              }
            }
            if (label == 'Price') {
              if (double.tryParse(value!) == null) {
                return 'Please enter a valid number';
              }
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
              inputFormatters: [
                LengthLimitingTextInputFormatter(_maxCharCount),
              ],
            ),
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

  void _validateAndUpdateProduct() {
    setState(() {
      _formSubmitted = true;
    });

    if (_formKey.currentState!.validate() && _image != null) {
      _updateProduct();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly and select an image')),
      );
    }
  }

  Future<void> _updateProduct() async {
    try {
      String imagePath = widget.product.imagePath;
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
      );

      // Use the updateProduct method from UserDatabase, passing both the key and the updated product
      final success = await UserDatabase.updateProduct(widget.product.key, updatedProduct);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')),
        );
        
        // Navigate back to the product list page after a short delay
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // This will return to the product list page
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product')),
        );
      }
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while updating the product')),
      );
    }
  }
}
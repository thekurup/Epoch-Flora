import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  // form key Used to manage form state and validation.
  final _formKey = GlobalKey<FormState>();
  // _categoryNameController: Controls the text input for category names
  final _categoryNameController = TextEditingController();
  // _categories: Holds a list of existing categories.
  List<Category> _categories = [];
  // _editingIndex: Tracks which category is being edited.
  int? _editingIndex;
  // _editingError: Holds any validation error messages.
  String? _editingError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
// Loads existing categories from the database.
  void _loadCategories() {
    setState(() {
      _categories = UserDatabase.getAllCategories();
    });
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

// _saveCategory: Validates and saves the new category.

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      bool success = await UserDatabase.addCategory(_categoryNameController.text);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category added successfully')),
        );
        _categoryNameController.clear();
        _loadCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add category. It may already exist or be invalid.')),
        );
      }
    }
  }
// _startEditing: Prepares to edit a category by setting the index and text.

  void _startEditing(int index) {
    setState(() {
      _editingIndex = index;
      _categoryNameController.text = _categories[index].name;
      _editingError = null;
    });
  }
// _cancelEditing: Cancels editing and clears errors.
  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _editingError = null;
    });
  }
// _saveEditedCategory: Validates and saves the edited category.
  Future<void> _saveEditedCategory(int index) async {
    if (_validateCategoryName(_categoryNameController.text)) {
      bool success = await UserDatabase.updateCategory(index, _categoryNameController.text);
      if (success) {
        setState(() {
          _editingIndex = null;
          _editingError = null;
        });
        _loadCategories();
      } else {
        setState(() {
          _editingError = 'Failed to update category. It may already exist.';
        });
      }
    }
  }
// _validateCategoryName: Checks if the category name is valid and unique.
  bool _validateCategoryName(String name) {
    if (name.isEmpty) {
      setState(() => _editingError = 'Please enter a category name');
      return false;
    }
    if (name.length <= 3) {
      setState(() => _editingError = 'Category name must be greater than 3 letters');
      return false;
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      setState(() => _editingError = 'Only characters are allowed');
      return false;
    }
    if (_categories.any((category) => category.name.toLowerCase() == name.toLowerCase() && _categories.indexOf(category) != _editingIndex)) {
      setState(() => _editingError = 'This category name already exists');
      return false;
    }
    setState(() => _editingError = null);
    return true;
  }
// _categoryHasProducts: Checks if the category has any associated products.
  bool _categoryHasProducts(String categoryName) {
    final products = UserDatabase.getProductsByCategory(categoryName);
    return products.isNotEmpty;
  }
// _deleteCategory: Deletes a category if it's safe to do so (i.e., no products are in it).
  void _deleteCategory(int index) async {
    final categoryName = _categories[index].name;
    
    if (_categoryHasProducts(categoryName)) {
      _showErrorDialog("You can't delete this category because it contains products. Please delete the products in this category first.");
      return;
    }
    
//  THis section is for _showConfirmationDialog and _showErrorDialog messages
    bool? confirmDelete = await _showConfirmationDialog('Are you sure you want to delete this category?');
    if (confirmDelete == true) {
      bool success = await UserDatabase.deleteCategory(index);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category deleted successfully')),
        );
        _loadCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete category')),
        );
      }
    }
  }

  Future<bool?> _showConfirmationDialog(String message) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, size: 50, color: Colors.amber),
                SizedBox(height: 20),
                Text(
                  message,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      child: Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton(
                      child: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  message,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('OK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        title: Text('Manage Categories', style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,)),
        backgroundColor: Colors.green,
         elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Top leaf image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/leaftop.png',
                fit: BoxFit.cover,
              ),
            ),
            // Bottom leaf image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/leafbottom.png',
                fit: BoxFit.cover,
              ),
            ),
            // Main content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              width: 300,
                              child: TextFormField(
                                controller: _categoryNameController,
                                decoration: InputDecoration(
                                  labelText: 'Category Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a category name';
                                  }
                                  if (value.length <= 3) {
                                    return 'Category name must be greater than 3 letters';
                                  }
                                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                                    return 'Only characters are allowed';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: _saveCategory,
                                child: Text('Save Category',style: TextStyle(color: Colors.white),),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF013A09),
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Existing Categories',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: ListTile(
                                title: _editingIndex == index
                                    ? TextField(
                                        controller: _categoryNameController,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          errorText: _editingError,
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) => _validateCategoryName(value),
                                      )
                                    : Text(_categories[index].name, style: GoogleFonts.poppins()),
                                trailing: _editingIndex == index
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.check, color: Colors.green),
                                            onPressed: () => _saveEditedCategory(index),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close, color: Colors.red),
                                            onPressed: _cancelEditing,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _startEditing(index),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteCategory(index),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
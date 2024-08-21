// Import necessary packages
import 'package:hive/hive.dart';  // Hive is a lightweight and fast database
import 'package:crypto/crypto.dart';  // Used for password hashing
import 'dart:convert';  // Provides encoding and decoding for JSON, UTF-8, and more
import 'package:shared_preferences/shared_preferences.dart';  // Used for storing current user

// This line is needed for Hive to generate TypeAdapters
part 'user_database.g.dart';

// User class: Represents a user in our app
@HiveType(typeId: 0)  // This tells Hive how to store User objects
class User extends HiveObject {
  @HiveField(0)  // This is like labeling a box to store the username
  late String username;

  @HiveField(1)  // This is like labeling a box to store the email
  late String email;

  @HiveField(2)  // This is like labeling a box to store the hashed password
  late String hashedPassword;

  @HiveField(3)  // This is like labeling a box to store the profile image path
  String? profileImagePath;

  // Constructor: This is like filling out a form to create a new user
  User(this.username, this.email, this.hashedPassword, {this.profileImagePath});
}

// Product class: Represents a product in our app
@HiveType(typeId: 1)  // This tells Hive how to store Product objects
class Product extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late double price;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late String imagePath;

  @HiveField(5)
  late bool isFavorite;

  // Constructor: This is like creating a new product listing
  Product(this.name, this.description, this.price, this.category, this.imagePath, {this.isFavorite = false});
}

// CartItem class: Represents an item in the shopping cart
@HiveType(typeId: 2)  // This tells Hive how to store CartItem objects
class CartItem extends HiveObject {
  @HiveField(0)
  late Product product;

  @HiveField(1)
  late int quantity;

  // Constructor: This is like adding a product to your shopping cart
  CartItem(this.product, this.quantity);
}

// Category class to represent product categories
@HiveType(typeId: 3)  // This tells Hive how to store Category objects
class Category extends HiveObject {
  @HiveField(0)
  late String name;

  // Constructor: This is like creating a new category
  Category(this.name);
}

// Address class to represent user addresses
@HiveType(typeId: 4)  // This tells Hive how to store Address objects
class Address extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String phone;

  @HiveField(2)
  late String street;

  @HiveField(3)
  late String city;

  @HiveField(4)
  late String state;

  @HiveField(5)
  late String zipCode;

  @HiveField(6)
  late String type;  // 'Home' or 'Work'

  @HiveField(7)
  late bool isBillingAddress;

  // Constructor: This is like filling out an address form
  Address(this.name, this.phone, this.street, this.city, this.state, this.zipCode, this.type, this.isBillingAddress);
}

// Order class to represent user orders
@HiveType(typeId: 5)  // This tells Hive how to store Order objects
class Order extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String productName;

  @HiveField(2)
  late String status;

  @HiveField(3)
  late double price;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late String imageUrl;

  @HiveField(6)
  late int quantity;

  @HiveField(7)  // Field for delivery price
  late double deliveryPrice;

  @HiveField(8)  // New: Field to store the user ID who placed the order
  late String userId;

  @HiveField(9)  // New: Field to store the address ID used for shipping
  late String addressId;

  // Constructor: This is like creating a new order
  Order({
    required this.id,
    required this.productName,
    required this.status,
    required this.price,
    required this.date,
    required this.imageUrl,
    required this.quantity,
    required this.deliveryPrice,
    required this.userId,    // New: Added userId to constructor
    required this.addressId, // New: Added addressId to constructor
  });
}

// These are the possible results when a user tries to log in
enum LoginResult {
  success,
  invalidUsername,
  invalidPassword,
}

// UserDatabase class: Handles all database operations for users, products, cart, categories, and orders
class UserDatabase {
  // These are like labels for different sections in our database
  static const String _userBoxName = 'users';
  static const String _productBoxName = 'products';
  static const String _cartBoxName = 'cart';
  static const String _categoryBoxName = 'categories';
  static const String _currentUserKey = 'currentUser';  // Key for storing current user
  static const String _addressBoxName = 'addresses';  // Key for storing addresses
  static const String _orderBoxName = 'orders';  // Key for storing orders

  // Initialize the database: This is like setting up different drawers to store information
  static Future<void> initialize() async {
    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox<Product>(_productBoxName);
    await Hive.openBox<CartItem>(_cartBoxName);
    await Hive.openBox<Category>(_categoryBoxName);
    await Hive.openBox<Address>(_addressBoxName);
    await Hive.openBox<Order>(_orderBoxName);
  }

  // Hash the password: This scrambles the password so it's not stored as plain text
  // It's like using a secret code to protect the password
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);  // Convert the password to bytes
    var digest = sha256.convert(bytes);  // Apply the SHA-256 hashing algorithm
    return digest.toString();  // Return the hashed password as a string
  }

  // Register a new user: It's like creating a new account on a website
  static Future<bool> registerUser(String username, String email, String password) async {
    final box = Hive.box<User>(_userBoxName);  // Open the 'users' box

    // Check if the username already exists
    if (box.values.cast<User>().any((user) => user.username == username)) {
      return false;  // Username already taken
    }

    // Create a new user with the hashed password
    final hashedPassword = _hashPassword(password);
    final newUser = User(username, email, hashedPassword);
    await box.add(newUser);  // Add the new user to the database
    
    return true;  // Registration successful
  }

  // Login a user: It's like checking if you entered the correct username and password on a website
  static Future<LoginResult> loginUser(String username, String password) async {
    final box = Hive.box<User>(_userBoxName);  // Open the 'users' box

    // Find the user with the given username
    final user = box.values.cast<User>().firstWhere(
      (user) => user.username == username,
      orElse: () => User('', '', ''),  // Return an empty user if not found
    );

    // If no user is found, return invalid username
    if (user.username.isEmpty) {
      return LoginResult.invalidUsername;
    }

    // Check if the password is correct
    final hashedPassword = _hashPassword(password);
    if (user.hashedPassword == hashedPassword) {
      await setCurrentUser(username);  // Set the current user
      return LoginResult.success;
    } else {
      return LoginResult.invalidPassword;
    }
  }

  // Get a user: It's like looking up someone's profile in a phonebook
  static Future<User?> getUser(String username) async {
    final box = Hive.box<User>(_userBoxName);  // Open the 'users' box
    final users = box.values.cast<User>().where(
      (user) => user.username == username,
    );
    
    if (users.isEmpty) {
      return null;  // User not found
    }
    
    return users.first;  // Return the found user
  }

  // Get all users: It's like getting a list of all profiles in a phonebook
  static Future<List<User>> getAllUsers() async {
    final box = Hive.box<User>(_userBoxName);  // Open the 'users' box
    return box.values.toList();  // Return all users as a list
  }

  // Update a user: It's like editing your profile on a social media site
  static Future<bool> updateUser(User updatedUser) async {
    final box = Hive.box<User>(_userBoxName);  // Open the 'users' box
    final existingUser = await getUser(updatedUser.username);
    
    if (existingUser == null) {
      return false;  // User not found
    }

    // Update the user's information
    existingUser.email = updatedUser.email;
    existingUser.hashedPassword = updatedUser.hashedPassword;
    existingUser.profileImagePath = updatedUser.profileImagePath;
    await existingUser.save();  // Save the changes
    return true;  // Update successful
  }

  // Delete a user: It's like closing your account on a website
  static Future<bool> deleteUser(String username) async {
    final box = Hive.box<User>(_userBoxName);  // Open the 'users' box
    final user = await getUser(username);
    
    if (user == null) {
      return false;  // User not found
    }

    await user.delete();  // Delete the user
    return true;  // Deletion successful
  }

  // Get the current user
  static Future<User?> getCurrentUser() async {
    final String? currentUsername = await _getCurrentUsername();
    if (currentUsername != null) {
      return getUser(currentUsername);
    }
    return null;
  }

  // Helper method to get the current username
  static Future<String?> _getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Set the current user
  static Future<void> setCurrentUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, username);
  }

  // Clear the current user (used for logout)
  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Logout user
  static Future<void> logoutUser() async {
    await clearCurrentUser();
  }

  // Product-related methods

  // Add a product: It's like adding a new item to an online store
  static Future<bool> addProduct(Product product) async {
    final box = Hive.box<Product>(_productBoxName);  // Open the 'products' box
    await box.add(product);  // Add the new product
    return true;  // Addition successful
  }

  // Get all products: It's like getting a list of all items in a store
  static List<Product> getAllProducts() {
    final box = Hive.box<Product>(_productBoxName);  // Open the 'products' box
    return box.values.toList();  // Return all products as a list
  }

  // Get products by category: It's like filtering items in an online store by category
  static List<Product> getProductsByCategory(String category) {
    final box = Hive.box<Product>(_productBoxName);  // Open the 'products' box
    return box.values.where((product) => product.category == category).toList();  // Return filtered products
  }

  // Update a product: It's like editing the details of an item in an online store
  static Future<bool> updateProduct(dynamic productKey, Product updatedProduct) async {
    final box = Hive.box<Product>(_productBoxName);  // Open the 'products' box
    
    if (box.containsKey(productKey)) {
      // Get the existing product
      final existingProduct = box.get(productKey);
      
      // Update the existing product's fields
      existingProduct!.name = updatedProduct.name;
      existingProduct.description = updatedProduct.description;
      existingProduct.price = updatedProduct.price;
      existingProduct.category = updatedProduct.category;
      existingProduct.imagePath = updatedProduct.imagePath;
      existingProduct.isFavorite = updatedProduct.isFavorite;
      
      // Save the updated product
      await existingProduct.save();
      return true;  // Update successful
    }
    return false;  // Product not found
  }

  // Delete a product: It's like removing an item from an online store
  static Future<bool> deleteProduct(dynamic productKey) async {
    final box = Hive.box<Product>(_productBoxName);  // Open the 'products' box
    await box.delete(productKey);  // Delete the product
    return true;  // Deletion successful
  }

  // Favorite-related methods

  // Toggle favorite status: It's like clicking a heart icon to favorite or unfavorite an item
  static Future<void> toggleFavorite(Product product) async {
    final box = Hive.box<Product>(_productBoxName);  // Open the 'products' box
    product.isFavorite = !product.isFavorite;  // Flip the favorite status
    await product.save();  // Save the changes
  }

  // Get favorite products: It's like viewing your list of favorite items
  static List<Product> getFavoriteProducts() {
    final box = Hive.box<Product>(_productBoxName);  // Open the 'products' box
    return box.values.where((product) => product.isFavorite).toList();  // Return only favorite products
  }

  // Cart-related methods

 // Add to cart: It's like clicking "Add to Cart" on an online store
  static Future<bool> addToCart(Product product, {int quantity = 1}) async {
    final box = Hive.box<CartItem>(_cartBoxName);  // Open the 'cart' box
    final existingItem = box.values.firstWhere(
      (item) => item.product.name == product.name,
      orElse: () => CartItem(product, 0),  // Create a new cart item if not found
    );

    if (existingItem.quantity == 0) {
      await box.add(CartItem(product, quantity));  // Add new item to cart
    } else {
      existingItem.quantity += quantity;  // Increase quantity of existing item
      await existingItem.save();  // Save the changes
    }
    return true;  // Addition to cart successful
  }

  // Get cart items: It's like viewing your shopping cart
  static List<CartItem> getCartItems() {
    final box = Hive.box<CartItem>(_cartBoxName);  // Open the 'cart' box
    return box.values.toList();  // Return all items in the cart
  }

  // Update cart item: It's like changing the quantity of an item in your cart
  static Future<void> updateCartItem(CartItem item) async {
    await item.save();  // Save the changes to the cart item
  }

  // Remove from cart: It's like clicking "Remove" on an item in your cart
  static Future<bool> removeFromCart(Product product) async {
    final box = Hive.box<CartItem>(_cartBoxName);  // Open the 'cart' box
    try {
      final itemToRemove = box.values.firstWhere(
        (item) => item.product.name == product.name,
      );
      await itemToRemove.delete();  // Remove the item from the cart
      return true;  // Removal successful
    } catch (e) {
      // Item not found in the cart
      print('Product ${product.name} not found in the cart');
      return false;  // Removal failed
    }
  }

  // Clear cart: It's like clicking "Empty Cart" in an online store
  static Future<void> clearCart() async {
    final box = Hive.box<CartItem>(_cartBoxName);  // Open the 'cart' box
    await box.clear();  // Remove all items from the cart
  }

  // Get cart total: It's like seeing the total price at checkout
  static double getCartTotal() {
    final cartItems = getCartItems();  // Get all items in the cart
    return cartItems.fold(0, (total, item) => total + (item.product.price * item.quantity));  // Calculate total price
  }

  // Category-related methods

  // Add a new category: It's like creating a new section in an online store
  static Future<bool> addCategory(String categoryName) async {
    final box = Hive.box<Category>(_categoryBoxName);  // Open the 'categories' box
    
    // Check if the category already exists
    if (box.values.any((category) => category.name.toLowerCase() == categoryName.toLowerCase())) {
      return false;  // Category already exists
    }

    // Validate category name
    if (!_isValidCategoryName(categoryName)) {
      return false;  // Invalid category name
    }

    await box.add(Category(categoryName));  // Add the new category
    return true;  // Category added successfully
  }

  // Update an existing category: It's like renaming a section in an online store
  static Future<bool> updateCategory(int index, String newCategoryName) async {
    final box = Hive.box<Category>(_categoryBoxName);  // Open the 'categories' box
    
    // Check if the new category name already exists (excluding the current category)
    if (box.values.where((category) => box.keyAt(box.values.toList().indexOf(category)) != index)
        .any((category) => category.name.toLowerCase() == newCategoryName.toLowerCase())) {
      return false;  // Category name already exists
    }

    // Validate new category name
    if (!_isValidCategoryName(newCategoryName)) {
      return false;  // Invalid category name
    }

    final category = box.getAt(index);
    if (category != null) {
      category.name = newCategoryName;
      await category.save();  // Save the changes
      return true;  // Category updated successfully
    }
    return false;  // Category not found
  }

  // Delete a category: It's like removing a section from an online store
  static Future<bool> deleteCategory(int index) async {
    final box = Hive.box<Category>(_categoryBoxName);  // Open the 'categories' box
    await box.deleteAt(index);  // Delete the category
    return true;  // Category deleted successfully
  }

  // Get all categories: It's like viewing all sections in an online store
  static List<Category> getAllCategories() {
    final box = Hive.box<Category>(_categoryBoxName);  // Open the 'categories' box
    return box.values.toList();  // Return all categories as a list
  }

  // Validate category name: It's like checking if a section name is appropriate for the store
  static bool _isValidCategoryName(String name) {
    return name.length > 3 && RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  // Address-related methods

  // Add an address for the current user
  static Future<bool> addAddress(Address address) async {
    final box = Hive.box<Address>(_addressBoxName);  // Open the 'addresses' box
    await box.add(address);  // Add the new address
    return true;  // Address added successfully
  }

  // Get all addresses for the current user
  static List<Address> getAddresses() {
    final box = Hive.box<Address>(_addressBoxName);  // Open the 'addresses' box
    return box.values.toList();  // Return all addresses as a list
  }

  // Update an existing address
  static Future<bool> updateAddress(Address updatedAddress) async {
    await updatedAddress.save();  // Save the changes to the address
    return true;  // Address updated successfully
  }

  // Delete an address
  static Future<bool> deleteAddress(Address address) async {
    await address.delete();  // Delete the address
    return true;  // Address deleted successfully
  }

  // Get addresses by type (Home or Work)
  static List<Address> getAddressesByType(String type) {
    final box = Hive.box<Address>(_addressBoxName);  // Open the 'addresses' box
    return box.values.where((address) => address.type == type).toList();  // Return filtered addresses
  }

  // Get the billing address
  static Address? getBillingAddress() {
    final box = Hive.box<Address>(_addressBoxName);  // Open the 'addresses' box
    try {
      return box.values.firstWhere(
        (address) => address.isBillingAddress,
      );  // Return the billing address
    } catch (e) {
      return null;  // Return null if no billing address is found
    }
  }

  // Set an address as the billing address
  static Future<bool> setBillingAddress(Address address) async {
    final box = Hive.box<Address>(_addressBoxName);  // Open the 'addresses' box
    for (var addr in box.values) {
      addr.isBillingAddress = (addr == address);
      await addr.save();  // Save the changes
    }
    return true;  // Billing address set successfully
  }

  // Order-related methods

  // Save an order
  static Future<void> saveOrder(Order order) async {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    await box.add(order);  // Add the new order
  }

  // Get all orders for the current user
  // Updated: Now excludes canceled orders
  static Future<List<Order>> getOrders() async {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    // New: Filter out canceled orders
    return box.values.where((order) => order.status != 'Canceled').toList().reversed.toList();
  }

  // Get order by ID
  static Future<Order?> getOrderById(String orderId) async {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    try {
      return box.values.firstWhere((order) => order.id == orderId);
    } catch (e) {
      // If no order is found, return null
      return null;
    }
  }

  // Update order status
  static Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    final order = await getOrderById(orderId);
    if (order != null) {
      order.status = newStatus;
      await order.save();  // Save the changes
      return true;  // Update successful
    }
    return false;  // Order not found
  }

  // Delete an order
  static Future<bool> deleteOrder(String orderId) async {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    final order = await getOrderById(orderId);
    if (order != null) {
      await order.delete();  // Delete the order
      return true;  // Deletion successful
    }
    return false;  // Order not found
  }

  // Get orders by status
  static List<Order> getOrdersByStatus(String status) {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    return box.values.where((order) => order.status == status).toList();
  }

  // Get total number of orders
  static int getTotalOrderCount() {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    return box.length;
  }

  // Get total revenue from all orders
  static double getTotalRevenue() {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    return box.values.fold(0, (total, order) => total + (order.price * order.quantity));
  }

  // Updated: Remove an order (now updates status to 'Canceled' instead of deleting)
  // This method updates an order's status to 'Canceled' in the database
  static Future<bool> removeOrder(String orderId) async {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    
    // Find the order with the given ID
    final orderToUpdate = box.values.cast<Order?>().firstWhere(
      (order) => order?.id == orderId,
      orElse: () => null,
    );

    // If the order is found, update its status to 'Canceled'
    if (orderToUpdate != null) {
      orderToUpdate.status = 'Canceled';  // Update the status instead of deleting
      await orderToUpdate.save();  // Save the changes
      return true;  // Update successful
    }
    
    return false;  // Order not found
  }

  // New: Get canceled orders
  // This method retrieves all orders with 'Canceled' status
  static List<Order> getCanceledOrders() {
    final box = Hive.box<Order>(_orderBoxName);  // Open the 'orders' box
    return box.values.where((order) => order.status == 'Canceled').toList();
  }

  // Updated: Method to get a user by order ID
  static Future<User?> getUserByOrderId(String orderId) async {
    final orderBox = Hive.box<Order>(_orderBoxName);
    final userBox = Hive.box<User>(_userBoxName);

    try {
      // Find the order
      final order = orderBox.values.firstWhere((order) => order.id == orderId);
      print('Found order: ${order.id}, userId: ${order.userId}');  // Debug print
      
      // Find the user associated with this order
      final user = userBox.values.firstWhere((user) => user.key.toString() == order.userId);
      print('Found user: ${user.username}');  // Debug print
      
      return user;
    } catch (e) {
      print('Error getting user by order ID: $e');
      return null;
    }
  }

  // Updated: Method to get an address by order ID
  static Future<Address?> getAddressByOrderId(String orderId) async {
    final orderBox = Hive.box<Order>(_orderBoxName);
    final addressBox = Hive.box<Address>(_addressBoxName);

    try {
      // Find the order
      final order = orderBox.values.firstWhere((order) => order.id == orderId);
      print('Found order: ${order.id}, addressId: ${order.addressId}');  // Debug print
      
      // Find the address associated with this order
      final address = addressBox.values.firstWhere((address) => address.key.toString() == order.addressId);
      print('Found address: ${address.name}');  // Debug print
      
      return address;
    } catch (e) {
      print('Error getting address by order ID: $e');
      return null;
    }
  }
}
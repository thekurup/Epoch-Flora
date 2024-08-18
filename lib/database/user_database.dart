// Import necessary packages
import 'package:hive/hive.dart';  // Hive is a lightweight and fast database
import 'package:crypto/crypto.dart';  // Used for password hashing
import 'dart:convert';  // Provides encoding and decoding for JSON, UTF-8, and more

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

  // Constructor: This is like filling out a form to create a new user
  User(this.username, this.email, this.hashedPassword);
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

// These are the possible results when a user tries to log in
enum LoginResult {
  success,
  invalidUsername,
  invalidPassword,
}

// UserDatabase class: Handles all database operations for users, products, and cart
class UserDatabase {
  // These are like labels for different sections in our database
  static const String _userBoxName = 'users';
  static const String _productBoxName = 'products';
  static const String _cartBoxName = 'cart';

  // Initialize the database: This is like setting up different drawers to store information
  static Future<void> initialize() async {
    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox<Product>(_productBoxName);
    await Hive.openBox<CartItem>(_cartBoxName);
  }

  // User-related methods

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
}
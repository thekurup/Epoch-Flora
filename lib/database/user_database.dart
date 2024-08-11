import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

part 'user_database.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String hashedPassword;

  User(this.username, this.email, this.hashedPassword);
}

@HiveType(typeId: 1)
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

  Product(this.name, this.description, this.price, this.category, this.imagePath);
}

enum LoginResult {
  success,
  invalidUsername,
  invalidPassword,
}

class UserDatabase {
  static const String _userBoxName = 'users';
  static const String _productBoxName = 'products';

  static Future<void> initialize() async {
    await Hive.openBox<User>(_userBoxName);
    await Hive.openBox<Product>(_productBoxName);
  }

  // User-related methods

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> registerUser(String username, String email, String password) async {
    final box = Hive.box<User>(_userBoxName);

    if (box.values.cast<User>().any((user) => user.username == username)) {
      return false;
    }

    final hashedPassword = _hashPassword(password);
    final newUser = User(username, email, hashedPassword);
    await box.add(newUser);
    
    return true;
  }

  static Future<LoginResult> loginUser(String username, String password) async {
    final box = Hive.box<User>(_userBoxName);

    final user = box.values.cast<User>().firstWhere(
      (user) => user.username == username,
      orElse: () => User('', '', ''),
    );

    if (user.username.isEmpty) {
      return LoginResult.invalidUsername;
    }

    final hashedPassword = _hashPassword(password);
    if (user.hashedPassword == hashedPassword) {
      return LoginResult.success;
    } else {
      return LoginResult.invalidPassword;
    }
  }

  static Future<User?> getUser(String username) async {
    final box = Hive.box<User>(_userBoxName);
    final users = box.values.cast<User>().where(
      (user) => user.username == username,
    );
    
    if (users.isEmpty) {
      return null;
    }
    
    return users.first;
  }

  static Future<bool> updateUser(User updatedUser) async {
    final box = Hive.box<User>(_userBoxName);
    final existingUser = await getUser(updatedUser.username);
    
    if (existingUser == null) {
      return false;
    }

    existingUser.email = updatedUser.email;
    existingUser.hashedPassword = updatedUser.hashedPassword;
    await existingUser.save();
    return true;
  }

  static Future<bool> deleteUser(String username) async {
    final box = Hive.box<User>(_userBoxName);
    final user = await getUser(username);
    
    if (user == null) {
      return false;
    }

    await user.delete();
    return true;
  }

  // Product-related methods

  static Future<bool> addProduct(Product product) async {
    final box = Hive.box<Product>(_productBoxName);
    await box.add(product);
    return true;
  }

  static List<Product> getAllProducts() {
    final box = Hive.box<Product>(_productBoxName);
    return box.values.toList();
  }

  static List<Product> getProductsByCategory(String category) {
    final box = Hive.box<Product>(_productBoxName);
    return box.values.where((product) => product.category == category).toList();
  }

  static Future<bool> updateProduct(dynamic productKey, Product updatedProduct) async {
    final box = Hive.box<Product>(_productBoxName);
    
    if (box.containsKey(productKey)) {
      // Get the existing product
      final existingProduct = box.get(productKey);
      
      // Update the existing product's fields
      existingProduct!.name = updatedProduct.name;
      existingProduct.description = updatedProduct.description;
      existingProduct.price = updatedProduct.price;
      existingProduct.category = updatedProduct.category;
      existingProduct.imagePath = updatedProduct.imagePath;
      
      // Save the updated product
      await existingProduct.save();
      return true;
    }
    return false;
  }

  static Future<bool> deleteProduct(dynamic productKey) async {
    final box = Hive.box<Product>(_productBoxName);
    await box.delete(productKey);
    return true;
  }
}
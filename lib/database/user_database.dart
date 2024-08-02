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

enum LoginResult {
  success,
  invalidUsername,
  invalidPassword,
}

class UserDatabase {
  static const String _boxName = 'users';

  static Future<void> initialize() async {
    await Hive.openBox<User>(_boxName);
  }
// password hasing for security for that i use sha256 maths function
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // The below  method registers a new user:

  static Future<bool> registerUser(String username, String email, String password) async {
    final box = Hive.box<User>(_boxName);

    if (box.values.cast<User>().any((user) => user.username == username)) {
      return false; 
      //  checks if the username already exists
    }

    final hashedPassword = _hashPassword(password);
    final newUser = User(username, email, hashedPassword);
    // If not, it hashes the password and creates a new User
    await box.add(newUser);
    // It adds the user to the database
    
    return true;
    // It returns true if successful, false if the username exists
  }
  // The below method handles user login:

  
  static Future<LoginResult> loginUser(String username, String password) async {
    
    //  This method tries to log in a user.
  //   It takes a username and password and returns a LoginResult 
  //   (which we defined earlier as success, invalidUsername, or invalidPassword).

//   Let's say we have these users in our database:
    // Username: "riya", Password: "riya24"

    // Now, let's go through the method step by step:

    final box = Hive.box<User>(_boxName);
    // This opens our  database where we store user information.

    final user = box.values.cast<User>().firstWhere(
      (user) => user.username == username,
      orElse: () => User('', '', ''),
      // This looks for a user with the given username. 
      // If found, it returns that user. If not found, 
      // it returns a dummy user with empty strings.
    );

    if (user.username.isEmpty) {
      return LoginResult.invalidUsername;
    }

//     If the username is empty (meaning we got our dummy user), we return invalidUsername.
// Example : If we try to log in with username "riya" (which doesn't exist):

// We get a dummy user with empty username
// We return LoginResult.invalidUsername

    final hashedPassword = _hashPassword(password);
    if (user.hashedPassword == hashedPassword) {
      return LoginResult.success;
    } else {
      return LoginResult.invalidPassword;
    }
// If we found a user, we hash the provided password and
// compare it with the stored hashed password. If they match, login is successful. If not, the password is wrong.
// Example : If we try to log in with username "riya" and password "riya24":

// and in user name finding time riya  user record find
// then We hash password "riya24" and if it matches riya  stored hashed password
// We return LoginResult.success
  }

//  This below method retrieves a user by username:

// It searches the database for a matching username
// It returns the user if found, null otherwise
  static Future<User?> getUser(String username) async {
    final box = Hive.box<User>(_boxName);
    final users = box.values.cast<User>().where(
      (user) => user.username == username,
    );
    
    if (users.isEmpty) {
      return null;
    }
    
    return users.first;
  }

  // This below method tries to update an existing user's information. 
  // It returns true if the update was successful, and false if the user wasn't found.

  static Future<bool> updateUser(User updatedUser) async {
    final box = Hive.box<User>(_boxName);
    final existingUser = await getUser(updatedUser.username);
    // This opens our user database and tries to find a user with the username 
    
    if (existingUser == null) {
      return false; // User not found
    }
    // If we couldn't find a user with that username, 
    // we return false to indicate the update failed.

    existingUser.email = updatedUser.email;
    existingUser.hashedPassword = updatedUser.hashedPassword;
    await existingUser.save();
    return true;
    // If we found the user, we update their email and
    //  hashed password, save the changes, and return true to indicate success.
  }

  
// This below method deletes a user:
// It finds the user by username
// If found, it deletes the user and returns true
// If not found, it returns false
  static Future<bool> deleteUser(String username) async {
    final box = Hive.box<User>(_boxName);
    final user = await getUser(username);
    
    if (user == null) {
      return false; // User not found
    }

    await user.delete();
    return true;
  }
}
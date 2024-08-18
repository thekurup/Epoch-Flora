// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_database.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

// This class helps Hive understand how to save and load User objects
class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;  // This is like a unique ID for the User class

  @override
  // This method reads a User object from the database
  // It's like unpacking a box containing user information
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();  // Read how many fields the User has
    final fields = <int, dynamic>{
      // Read each field and store it in a map
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Create and return a new User object with the read data
    // New: Added profileImagePath to the User constructor
    return User(
      fields[0] as String,  // username
      fields[1] as String,  // email
      fields[2] as String,  // hashedPassword
      profileImagePath: fields[3] as String?,  // New: Read profileImagePath
    );
  }

  @override
  // This method writes a User object to the database
  // It's like packing a box with user information
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(4)  // New: Write that User now has 4 fields
      ..writeByte(0)
      ..write(obj.username)  // Write username
      ..writeByte(1)
      ..write(obj.email)  // Write email
      ..writeByte(2)
      ..write(obj.hashedPassword)  // Write hashedPassword
      ..writeByte(3)
      ..write(obj.profileImagePath);  // New: Write profileImagePath
  }

  @override
  // These methods help Hive compare UserAdapter objects
  // They're like checking if two robot assistants are the same
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// This class helps Hive understand how to save and load Product objects
class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;  // This is like a unique ID for the Product class

  @override
  // This method reads a Product object from the database
  // It's like unpacking a box containing product information
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();  // Read how many fields the Product has
    final fields = <int, dynamic>{
      // Read each field and store it in a map
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Create and return a new Product object with the read data
    return Product(
      fields[0] as String,  // name
      fields[1] as String,  // description
      fields[2] as double,  // price
      fields[3] as String,  // category
      fields[4] as String,  // imagePath
    )..isFavorite = fields[5] as bool;  // isFavorite
  }

  @override
  // This method writes a Product object to the database
  // It's like packing a box with product information
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(6)  // Write that Product has 6 fields
      ..writeByte(0)
      ..write(obj.name)  // Write name
      ..writeByte(1)
      ..write(obj.description)  // Write description
      ..writeByte(2)
      ..write(obj.price)  // Write price
      ..writeByte(3)
      ..write(obj.category)  // Write category
      ..writeByte(4)
      ..write(obj.imagePath)  // Write imagePath
      ..writeByte(5)
      ..write(obj.isFavorite);  // Write isFavorite
  }

  @override
  // These methods help Hive compare ProductAdapter objects
  // They're like checking if two robot assistants are the same
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// This class helps Hive understand how to save and load CartItem objects
class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 2;  // This is like a unique ID for the CartItem class

  @override
  // This method reads a CartItem object from the database
  // It's like unpacking a box containing cart item information
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();  // Read how many fields the CartItem has
    final fields = <int, dynamic>{
      // Read each field and store it in a map
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Create and return a new CartItem object with the read data
    return CartItem(
      fields[0] as Product,  // product
      fields[1] as int,  // quantity
    );
  }

  @override
  // This method writes a CartItem object to the database
  // It's like packing a box with cart item information
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(2)  // Write that CartItem has 2 fields
      ..writeByte(0)
      ..write(obj.product)  // Write product
      ..writeByte(1)
      ..write(obj.quantity);  // Write quantity
  }

  @override
  // These methods help Hive compare CartItemAdapter objects
  // They're like checking if two robot assistants are the same
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// This class helps Hive understand how to save and load Category objects
class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 3;  // This is like a unique ID for the Category class

  @override
  // This method reads a Category object from the database
  // It's like unpacking a box containing category information
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();  // Read how many fields the Category has
    final fields = <int, dynamic>{
      // Read each field and store it in a map
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Create and return a new Category object with the read data
    return Category(
      fields[0] as String,  // name
    );
  }

  @override
  // This method writes a Category object to the database
  // It's like packing a box with category information
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(1)  // Write that Category has 1 field
      ..writeByte(0)
      ..write(obj.name);  // Write name
  }

  @override
  // These methods help Hive compare CategoryAdapter objects
  // They're like checking if two robot assistants are the same
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:epoch/Screens/splash_screen.dart';
import 'package:epoch/database/user_database.dart';
import 'package:epoch/Screens/user/plant_store.dart';
import 'package:epoch/Screens/user/latest_product.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register the UserAdapter
  Hive.registerAdapter(UserAdapter());
  
  // Register the ProductAdapter
  Hive.registerAdapter(ProductAdapter());
  
  // Register the CartItemAdapter
  Hive.registerAdapter(CartItemAdapter());
  
  // Register the CategoryAdapter
  Hive.registerAdapter(CategoryAdapter());
  
  // Register the AddressAdapter
  Hive.registerAdapter(AddressAdapter());

  // Register the OrderAdapter
  Hive.registerAdapter(OrderAdapter());
  
  // Initialize the UserDatabase
  await UserDatabase.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlantStore()),
        // Add any other providers you might need for the latest products page
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Epoch Flora",
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: {
        '/latest_products': (context) => LatestProductsPage(products: UserDatabase.getAllProducts()),
      },
    );
  }
}
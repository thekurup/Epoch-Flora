// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:epoch/splash_screen.dart';
import 'package:epoch/user_database.dart';
import 'package:epoch/plant_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register the UserAdapter
  Hive.registerAdapter(UserAdapter());
  
  // Initialize the UserDatabase
  await UserDatabase.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => PlantStore(),
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
      // You can add routes here if needed
      // routes: {
      //   '/home': (context) => HomeScreen(),
      // },
    );
  }
}
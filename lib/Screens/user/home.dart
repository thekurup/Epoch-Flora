import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/Screens/userauth/login.dart';
import 'package:epoch/Screens/user/product_detail_page.dart';
import 'package:epoch/Screens/user/favourite_page.dart';
import 'package:epoch/Screens/user/cart_page.dart';
import 'package:epoch/Screens/user/search_page.dart';
import 'package:epoch/Screens/user/profile_page.dart';
import 'package:epoch/database/user_database.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<Product> _allProducts = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    // Initialize TabController with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load all products from the database
  Future<void> _loadProducts() async {
    final products = UserDatabase.getAllProducts();
    setState(() {
      _allProducts = products;
    });
  }

  // Method to refresh product list (call this after adding a new product)
  void refreshProductList() {
    setState(() {
      _loadProducts();
    });
  }

  // Logout method
  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Cover photo, title, and tab bar
              Container(
                height: MediaQuery.of(context).size.height * 0.30,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/coverphoto.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Padding(
                        padding: EdgeInsets.fromLTRB(22, 40, 22, 10),
                        child: Text(
                          'Plant Collections',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Tab Bar
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabs: [
                          Tab(text: 'Indoor Plant'),
                          Tab(text: 'Outdoor Plant'),
                          Tab(text: 'Flowering Plant'),
                        ],
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.7),
                        indicatorColor: Colors.white,
                        indicatorWeight: 3,
                      ),
                    ],
                  ),
                ),
              ),
              // Main content area with TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ProductList(category: 'Indoor Plant'),
                    ProductList(category: 'Outdoor Plant'),
                    ProductList(category: 'Flowering Plant'),
                  ],
                ),
              ),
            ],
          ),
          // Logout button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(currentIndex: 0),
    );
  }
}

// Widget to display the list of products for each category
class ProductList extends StatelessWidget {
  final String category;

  const ProductList({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = UserDatabase.getProductsByCategory(category);
    
    // Debug prints
    print('Category: $category');
    print('Number of products: ${products.length}');
    
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        // Debug print for each product
        print('Product ${index + 1}: ${product.name}, Category: ${product.category}');
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ProductCard(product: product),
        );
      },
    );
  }
}

// Widget to display each product card
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: Image.file(
                File(product.imagePath),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Favorite icon
            Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.favorite_border,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for the bottom navigation bar
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;

  FloatingNavBar({required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FavouritePage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CartPage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchPage()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF013A09),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.7),
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favourite'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
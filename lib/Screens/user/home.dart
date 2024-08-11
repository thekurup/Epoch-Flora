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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = UserDatabase.getAllProducts();
    setState(() {
      _allProducts = products;
    });
  }

  void _toggleFavorite(Product product) async {
    await UserDatabase.toggleFavorite(product);
    setState(() {
      // Trigger a rebuild
    });
  }

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
                    ProductList(category: 'Indoor Plant', onFavoriteToggle: _toggleFavorite),
                    ProductList(category: 'Outdoor Plant', onFavoriteToggle: _toggleFavorite),
                    ProductList(category: 'Flowering Plant', onFavoriteToggle: _toggleFavorite),
                  ],
                ),
              ),
              // Latest Products Section
              LatestProductsSection(onFavoriteToggle: _toggleFavorite),
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

class ProductList extends StatelessWidget {
  final String category;
  final Function(Product) onFavoriteToggle;

  const ProductList({Key? key, required this.category, required this.onFavoriteToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = UserDatabase.getProductsByCategory(category);
    
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ProductCard(
            product: product,
            onFavoriteToggle: () => onFavoriteToggle(product),
          ),
        );
      },
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onFavoriteToggle;

  const ProductCard({Key? key, required this.product, required this.onFavoriteToggle}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sizeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1), weight: 50),
    ]).animate(_controller);
    _colorAnimation = ColorTween(
      begin: Colors.grey[400],
      end: Colors.red,
    ).animate(_controller);

    if (widget.product.isFavorite) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: widget.product),
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
                File(widget.product.imagePath),
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
                      widget.product.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.product.category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${widget.product.price.toStringAsFixed(2)}',
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
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.product.isFavorite ? _controller.reverse() : _controller.forward();
                  });
                  widget.onFavoriteToggle();
                },
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _sizeAnimation.value,
                      child: Icon(
                        widget.product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _colorAnimation.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LatestProductsSection extends StatelessWidget {
  final Function(Product) onFavoriteToggle;

  const LatestProductsSection({Key? key, required this.onFavoriteToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the latest products (assuming the most recent are at the end of the list)
    final latestProducts = UserDatabase.getAllProducts().reversed.take(5).toList();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Plants',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all products page
                },
                child: Text(
                  'Show All',
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Latest products list
          Container(
            height: 150, // Adjust this value as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: latestProducts.length,
              itemBuilder: (context, index) {
                final product = latestProducts[index];
                return LatestProductCard(
                  product: product,
                  onFavoriteToggle: () => onFavoriteToggle(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LatestProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteToggle;

  const LatestProductCard({Key? key, required this.product, required this.onFavoriteToggle}) : super(key: key);

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
        width: 120,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(product.imagePath),
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      product.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: product.isFavorite ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Product name
            Text(
              product.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Product price
            Text(
              '₹${product.price.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

// You can add any additional widgets or functions here if needed for the home.dart file

// For example, you might want to add a function to refresh the product list:

void refreshProductList() {
  // Implementation to refresh the product list
  // This could involve calling setState() in the parent widget
  // or using a state management solution to update the UI
}

// If you have any global constants or utility functions specific to the home page,
// you can define them here:

const String APP_TITLE = 'Plant Shop';
const String CURRENCY_SYMBOL = '₹';

String formatPrice(double price) {
  return '$CURRENCY_SYMBOL${price.toStringAsFixed(2)}';
}

// If you're using any custom themes or styles consistently across the home page,
// you could define them here:

final headerStyle = GoogleFonts.poppins(
  fontWeight: FontWeight.w700,
  fontSize: 24,
  color: Colors.black,
);

final subHeaderStyle = GoogleFonts.poppins(
  fontWeight: FontWeight.w500,
  fontSize: 18,
  color: Colors.black87,
);

// This marks the end of the home.dart file
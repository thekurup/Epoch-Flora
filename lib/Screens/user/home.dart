import 'package:epoch/Screens/user/latest_product.dart';
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

// This class represents the main home page of our app
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// This class contains all the logic and UI for our home page
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // This list will store all our products, like items on a shelf
  List<Product> _allProducts = [];
  // This controller helps manage our tab bar, like a remote control for TV channels
  late TabController _tabController;
  // New: This list will store all our categories
  List<Category> _categories = [];

  @override
  // This function runs when the page is first created, like setting up a store before opening
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  // New: This function loads all categories from the database
  void _loadCategories() {
    setState(() {
      _categories = UserDatabase.getAllCategories();
      // Initialize the tab controller with the number of categories, or 1 if there are no categories
      _tabController = TabController(length: _categories.isEmpty ? 1 : _categories.length, vsync: this);
    });
  }

  @override
  // This function runs when the page is closed, like cleaning up after the store closes
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // This function loads all our products, like stocking the shelves in our store
  Future<void> _loadProducts() async {
    final products = UserDatabase.getAllProducts();
    setState(() {
      _allProducts = products;
    });
  }

  // This function handles toggling a product as favorite, like adding or removing a star sticker
  void _toggleFavorite(Product product) async {
    await UserDatabase.toggleFavorite(product);
    setState(() {
      // This triggers a rebuild, like refreshing the display in our store
    });
  }

  // This function handles logging out, like closing the store and going home
  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation', style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          )),
          content: Text('Are you sure you want to log out?', style: GoogleFonts.poppins(
            fontSize: 16,
          )),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.poppins(
                color: Colors.grey[600],
              )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout', style: GoogleFonts.poppins(
                color: Colors.red,
              )),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  // This function builds what we see on the screen, like arranging items in our store
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // This section creates the cover photo, title, and tab bar at the top
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
                      // This displays the title of our app
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
                      // This creates our tab bar, like section labels in our store
                      _categories.isEmpty
                          ? Center(
                              child: Text(
                                'No categories available',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              tabs: _categories.map((Category category) {
                                return Tab(text: category.name);
                              }).toList(),
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
              // This section displays our main content based on the selected tab
              Expanded(
                child: _categories.isEmpty
                    ? Center(
                        child: Text(
                          'No products available',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: _categories.map((Category category) {
                          return ProductList(category: category.name, onFavoriteToggle: _toggleFavorite);
                        }).toList(),
                      ),
              ),
              // This section displays our latest products
              LatestProductsSection(onFavoriteToggle: _toggleFavorite),
            ],
          ),
          // This adds a logout button to the top right corner
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
      // This adds a navigation bar at the bottom of the screen
      bottomNavigationBar: FloatingNavBar(currentIndex: 0),
    );
  }
}

// ... (rest of the code remains the same)
// This class represents a list of products for a specific category
class ProductList extends StatelessWidget {
  final String category;
  final Function(Product) onFavoriteToggle;

  const ProductList({Key? key, required this.category, required this.onFavoriteToggle}) : super(key: key);

  @override
  // This function builds the list of products for a category
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

// This class represents a card displaying a single product
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onFavoriteToggle;

  const ProductCard({Key? key, required this.product, required this.onFavoriteToggle}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

// This class manages the state and animation for our product card
class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  // These control the animation for our favorite button
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  // This function sets up our animations when the card is created
  void initState() {
    super.initState();

    // Controller controls the timing and progress of the animation.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // _sizeAnimation: Makes the button grow slightly larger and then back to normal size.
    _sizeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1), weight: 50),
    ]).animate(_controller);

    // _colorAnimation: Changes the button's color from grey to red.
    _colorAnimation = ColorTween(
      begin: Colors.grey[400],
      end: Colors.red,
    ).animate(_controller);

    if (widget.product.isFavorite) {
      _controller.value = 1.0;
    }
  }

  @override
  // This function cleans up our animations when the card is removed
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  // This function builds what we see for each product card
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // When tapped, navigate to the product detail page
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
            // This displays the product image
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
            // This displays the product details
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
            // This creates the animated favorite button
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

// This class represents the section displaying our latest products
class LatestProductsSection extends StatelessWidget {
  final Function(Product) onFavoriteToggle;

  const LatestProductsSection({Key? key, required this.onFavoriteToggle}) : super(key: key);

  @override
  // This function builds the latest products section
  Widget build(BuildContext context) {
    // Get the latest 5 products, like showcasing new arrivals in a store
    final latestProducts = UserDatabase.getAllProducts().reversed.take(5).toList();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // This creates the section header
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
                  // Fetch the latest 5 products
                        final latestProducts = UserDatabase.getAllProducts().reversed.take(5).toList();
                        
                        // Navigate to the LatestProductsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LatestProductsPage(products: latestProducts),
                          ),
                        );
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
          // This creates a horizontal scrollable list of latest products
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

// This class represents a card for displaying a latest product
class LatestProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteToggle;

  const LatestProductCard({Key? key, required this.product, required this.onFavoriteToggle}) : super(key: key);

  @override
  // This function builds what we see for each latest product card
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // When tapped, navigate to the product detail page
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
            // This displays the product image with a favorite button
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
            // This displays the product name
            Text(
              product.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,  // This cuts off text that's too long and adds ...
            ),
            // This displays the product price
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

// This class represents the navigation bar at the bottom of the screen
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;

  FloatingNavBar({required this.currentIndex});

  // This function handles tapping on a navigation item
  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;  // If we're already on this page, do nothing

    // This is like choosing which room of the house to go to
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
  // This function builds the navigation bar
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

// This function would refresh the list of products, like restocking the shelves
void refreshProductList() {
  // Implementation to refresh the product list
  // This could involve calling setState() in the parent widget
  // or using a state management solution to update the UI
}

// If you have any global constants or utility functions specific to the home page,
// you can define them here:

// These are like signs we put up in our store
const String APP_TITLE = 'Plant Shop';
const String CURRENCY_SYMBOL = '₹';

// This function formats the price with our currency symbol, like putting price tags on items
String formatPrice(double price) {
  return '$CURRENCY_SYMBOL${price.toStringAsFixed(2)}';
}

// If you're using any custom themes or styles consistently across the home page,
// you could define them here:

// These are like design templates for our store signs
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
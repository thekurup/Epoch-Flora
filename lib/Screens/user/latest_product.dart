import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/database/user_database.dart';
import 'package:epoch/Screens/user/product_detail_page.dart';
import 'package:epoch/Screens/user/home.dart';

class LatestProductsPage extends StatefulWidget {
  final List<Product> products;

  const LatestProductsPage({Key? key, required this.products}) : super(key: key);

  @override
  _LatestProductsPageState createState() => _LatestProductsPageState();
}

class _LatestProductsPageState extends State<LatestProductsPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterSlideAnimation;
  int currentIndex = 0;
  bool isFilterExpanded = false;
  String selectedCategory = '';
  RangeValues _currentPriceRange = RangeValues(0, 5000);
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85, initialPage: currentIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _filterSlideAnimation = Tween<double>(begin: -1, end: 0).animate(
      CurvedAnimation(parent: _filterAnimationController, curve: Curves.easeInOut),
    );

    filteredProducts = widget.products;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          currentIndex = _pageController.page?.round() ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void toggleFilter() {
    setState(() {
      isFilterExpanded = !isFilterExpanded;
      if (isFilterExpanded) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    });
  }

  void applyFilter() {
    setState(() {
      filteredProducts = widget.products.where((product) {
        bool categoryMatch = selectedCategory.isEmpty || product.category == selectedCategory;
        bool priceMatch = product.price >= _currentPriceRange.start && product.price <= _currentPriceRange.end;
        return categoryMatch && priceMatch;
      }).toList();
    });
    toggleFilter();
  }

  void resetFilter() {
    setState(() {
      selectedCategory = '';
      _currentPriceRange = RangeValues(0, 5000);
      filteredProducts = widget.products;
    });
    toggleFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A2E), Color(0xFF3A3A5A)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Latest Products',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.filter_list, color: Colors.white),
                          onPressed: toggleFilter,
                        ).shake(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: filteredProducts.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = (_pageController.page! - index).abs();
                              value = (1 - (value.clamp(0.0, 1.0))).abs();
                            }
                            return Center(
                              child: SizedBox(
                                height: Curves.easeInOut.transform(value) * 400,
                                width: Curves.easeInOut.transform(value) * 350,
                                child: child,
                              ),
                            );
                          },
                          child: Card3D(
                            product: product,
                            onTap: () => goToProductDetail(product),
                            animationController: _animationController,
                            onFavoriteToggle: () => toggleFavorite(product),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      filteredProducts.isNotEmpty
                          ? '${currentIndex + 1} of ${filteredProducts.length}'
                          : '',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _filterSlideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _filterSlideAnimation.value * MediaQuery.of(context).size.height),
                child: child,
              );
            },
            child: FilterSection(
              selectedCategory: selectedCategory,
              currentPriceRange: _currentPriceRange,
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
              onPriceRangeChanged: (range) {
                setState(() {
                  _currentPriceRange = range;
                });
              },
              onApplyFilter: applyFilter,
              onResetFilter: resetFilter,
            ),
          ),
        ],
      ),
    );
  }

  void goToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  void toggleFavorite(Product product) {
    setState(() {
      UserDatabase.toggleFavorite(product);
    });
  }
}

class FilterSection extends StatelessWidget {
  final String selectedCategory;
  final RangeValues currentPriceRange;
  final Function(String) onCategorySelected;
  final Function(RangeValues) onPriceRangeChanged;
  final VoidCallback onApplyFilter;
  final VoidCallback onResetFilter;

  const FilterSection({
    Key? key,
    required this.selectedCategory,
    required this.currentPriceRange,
    required this.onCategorySelected,
    required this.onPriceRangeChanged,
    required this.onApplyFilter,
    required this.onResetFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Filter Products',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CategoryFilter(
                    selectedCategory: selectedCategory,
                    onCategorySelected: onCategorySelected,
                  ),
                  PriceFilter(
                    currentPriceRange: currentPriceRange,
                    onPriceRangeChanged: onPriceRangeChanged,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onResetFilter,
                  child: Text('Reset', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: onApplyFilter,
                  child: Text('Apply Filter', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Category> categories = UserDatabase.getAllCategories();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Categories',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: categories.map((category) {
            return GestureDetector(
              onTap: () => onCategorySelected(category.name),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selectedCategory == category.name ? Colors.blue[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  category.name,
                  style: GoogleFonts.poppins(
                    color: selectedCategory == category.name ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PriceFilter extends StatelessWidget {
  final RangeValues currentPriceRange;
  final Function(RangeValues) onPriceRangeChanged;

  const PriceFilter({
    Key? key,
    required this.currentPriceRange,
    required this.onPriceRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Price Range',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        RangeSlider(
          values: currentPriceRange,
          min: 0,
          max: 5000,
          divisions: 10,
          activeColor: Colors.blue[700],
          inactiveColor: Colors.grey[300],
          labels: RangeLabels(
            '₹${currentPriceRange.start.round()}',
            '₹${currentPriceRange.end.round()}',
          ),
          onChanged: onPriceRangeChanged,
        ),
        Text(
          '₹${currentPriceRange.start.round()} - ₹${currentPriceRange.end.round()}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class Card3D extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final AnimationController animationController;
  final VoidCallback onFavoriteToggle;

  const Card3D({
    Key? key, 
    required this.product, 
    required this.onTap,
    required this.animationController,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.2)],
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'product_${product.name}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.file(
                              File(product.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: onFavoriteToggle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  product.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// Add this extension to add the shake animation to the filter button
extension ShakeWidget on Widget {
  Widget shake({
    double amount = 0.7,
    Duration duration = const Duration(milliseconds: 500),
    bool infinite = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            sin(value * pi * 2) * amount,
            0,
          ),
          child: child,
        );
      },
      child: this,
    );
  }
}

// Don't forget to update your main.dart file to include the necessary packages and run the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserDatabase.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latest Products',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LatestProductsPage(products: UserDatabase.getAllProducts()),
    );
  }
}
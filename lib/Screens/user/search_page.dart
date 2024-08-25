import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:epoch/database/user_database.dart';
import 'package:epoch/Screens/user/product_detail_page.dart';
import 'package:epoch/Screens/user/home.dart';
import 'dart:io';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  List<String> _suggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final searchText = _searchController.text.trim();
    setState(() {
      _isSearching = searchText.isNotEmpty;
      if (_isSearching) {
        _suggestions = UserDatabase.getAllProducts()
            .where((product) => product.name.toLowerCase().startsWith(searchText.toLowerCase()))
            .map((product) => product.name)
            .toList();
      } else {
        _suggestions = [];
      }
    });
  }

  void _performSearch(String searchText) {
    setState(() {
      _searchResults = UserDatabase.getAllProducts()
          .where((product) => product.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Plants', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF3A3A5A)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search for plants...',
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                onSubmitted: _performSearch,
              ),
            ),
            if (_suggestions.isNotEmpty)
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_suggestions[index], style: TextStyle(color: Colors.white)),
                      onTap: () {
                        _searchController.text = _suggestions[index];
                        _performSearch(_suggestions[index]);
                      },
                    );
                  },
                ),
              ),
            Expanded(
              child: _isSearching
                  ? _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/animations/no_results.json',
                                width: 200,
                                height: 200,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'No plants found, please try another search.',
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final product = _searchResults[index];
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: Colors.white.withOpacity(0.1),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(product.imagePath),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return Icon(Icons.error, size: 50, color: Colors.red);
                                    },
                                  ),
                                ),
                                title: Text(product.name, style: GoogleFonts.poppins(color: Colors.white)),
                                subtitle: Text(product.category, style: GoogleFonts.poppins(color: Colors.white70)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(product: product),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )
                  : Center(
                      child: Lottie.asset(
                        'assets/animations/plant_search.json',
                        width: 200,
                        height: 200,
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingNavBar(currentIndex: 3),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
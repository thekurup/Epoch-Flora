// Import necessary packages and other Dart files
// ignore_for_file: use_key_in_widget_constructors

import 'package:epoch/Screens/userauth/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:epoch/Screens/user/plant_store.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:epoch/Screens/user/product_detail_page.dart';

// Define the main HomePage widget as a StatefulWidget
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// Define the state for the HomePage
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // Declare a TabController to manage the tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the TabController when the widget is removed
    _tabController.dispose();
    super.dispose();
  }

  // Function to handle logout
  void _logout() {
    // Navigate to the LoginPage and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the main UI of the HomePage
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Container for the cover photo and title
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
                    children: [
                      // Display the title "Plant Collections"
                      TitleSection(),
                      // Display the tab bar for different plant categories
                      TabBarSection(tabController: _tabController),
                    ],
                  ),
                ),
              ),
              // Expanded area for the main content
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // TabBarView to display different plant lists based on the selected tab
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            ProductList(category: 'Indoor Plants'),
                            ProductList(category: 'Outdoor Plants'),
                            ProductList(category: 'Flowering Plants'),
                          ],
                        ),
                      ),
                      // Section to display the latest plants
                      LatestPlantsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Positioned logout button in the top-right corner
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
      // Add the bottom navigation bar
      bottomNavigationBar: FloatingNavBar(),
    );
  }
}

// Widget to display the title "Plant Collections"
class TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22, 60, 22, 10),
      alignment: Alignment.bottomLeft,
      child: Text(
        'Plant Collections',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Widget to create the tab bar for different plant categories
class TabBarSection extends StatelessWidget {
  final TabController tabController;

  const TabBarSection({Key? key, required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabs: [
          Tab(text: 'Indoor Plants'),
          Tab(text: 'Outdoor Plants'),
          Tab(text: 'Flowering Plants'),
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
    );
  }
}

// Widget to display the list of products for each category
class ProductList extends StatelessWidget {
  final String category;

  const ProductList({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Consumer to access the PlantStore data
    return Consumer<PlantStore>(
      builder: (context, plantStore, child) {
        // Get the plants for the current category
        final plants = plantStore.getPlantsByCategory(category);
        // Create a scrollable list of plant cards
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: PlantCard(plant: plant),
            );
          },
        );
      },
    );
  }
}

// Widget to create a card for each plant
class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({Key? key, required this.plant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make the card tappable to navigate to the product detail page
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(plant: plant),
          ),
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Display the plant image
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
              child: Image.asset(
                _getPlantImage(plant.name),
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            // Display plant details (name, category, price)
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      plant.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      plant.category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹ ${plant.price}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Add a favorite icon button
            Container(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.favorite_border, color: Colors.black, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get the correct image asset for each plant
  String _getPlantImage(String plantName) {
    switch (plantName.toLowerCase()) {
      case 'monstera':
        return 'assets/images/monstera.jpg';
      case 'peperomia':
        return 'assets/images/peperomia.jpg';
      case 'rubber fig':
        return 'assets/images/rubber_fig.jpg';
      case 'peace lilly':
        return 'assets/images/peace_lilly.jpg';
      case 'palm tree':
        return 'assets/images/palm_tree.jpg';
      case 'fern':
        return 'assets/images/fern.jpg';
      case 'aloevera':
        return 'assets/images/aloevera.jpg';
      case 'grasspot':
        return 'assets/images/grasspot.jpg';
      case 'crocous':
        return 'assets/images/crocous.jpg';
      case 'daisy flower':
        return 'assets/images/daisy_flower.jpg';
      default:
        return 'assets/images/plant_default.jpg';
    }
  }
}

// Widget to display the latest plants section
class LatestPlantsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display the section title and "Show All" button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Latest Plant's",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all latest plants screen
                },
                child: Text(
                  'Show All >',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Create a horizontal scrollable list of latest plant images
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/plant_${index + 1}.jpg'),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

// Widget to create the bottom navigation bar
class FloatingNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF013A09),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.7),
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
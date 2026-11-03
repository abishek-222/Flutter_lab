
import 'package:flutter/material.dart';

import 'models/product.dart';
import 'widgets/product_card.dart';

void main() {
  runApp(const ProductFilterApp());
}

// Root application
class ProductFilterApp extends StatelessWidget {
  const ProductFilterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Finder',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const ProductSearchPage(),
    );
  }
}

// Main interactive screen
class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() =>
      _ProductSearchPageState();
}

class _ProductSearchPageState
    extends State<ProductSearchPage> {

  // Search controller
  final TextEditingController searchController =
      TextEditingController();

  // Search input
  String searchQuery = '';

  // Selected category
  String selectedCategory = 'All';

  // Price range
  RangeValues selectedPriceRange =
      const RangeValues(0, 50000);

  // Stock availability
  bool onlyInStock = false;

  // Categories
  final List<String> categories = [
    'All',
    'Electronics',
    'Fashion',
    'Accessories',
    'Home',
  ];

  // Predefined products
  final List<Product> products = const [

    Product(
      name: 'Wireless Headphones',
      category: 'Electronics',
      price: 2499,
      inStock: true,
      description: 'High quality wireless audio',
      emoji: '🎧',
    ),

    Product(
      name: 'Smart Watch',
      category: 'Electronics',
      price: 3499,
      inStock: true,
      description: 'Smart fitness tracking watch',
      emoji: '⌚',
    ),

    Product(
      name: 'Laptop',
      category: 'Electronics',
      price: 45000,
      inStock: false,
      description: 'High performance laptop',
      emoji: '💻',
    ),

    Product(
      name: 'Running Shoes',
      category: 'Fashion',
      price: 1999,
      inStock: true,
      description: 'Comfortable sports shoes',
      emoji: '👟',
    ),

    Product(
      name: 'Denim Jacket',
      category: 'Fashion',
      price: 2199,
      inStock: false,
      description: 'Stylish casual jacket',
      emoji: '🧥',
    ),

    Product(
      name: 'Backpack',
      category: 'Accessories',
      price: 1299,
      inStock: true,
      description: 'Lightweight travel backpack',
      emoji: '🎒',
    ),

    Product(
      name: 'Sunglasses',
      category: 'Accessories',
      price: 899,
      inStock: true,
      description: 'UV protected sunglasses',
      emoji: '🕶️',
    ),

    Product(
      name: 'Modern Chair',
      category: 'Home',
      price: 4599,
      inStock: true,
      description: 'Comfortable office chair',
      emoji: '🪑',
    ),

    Product(
      name: 'Table Lamp',
      category: 'Home',
      price: 799,
      inStock: false,
      description: 'Modern LED table lamp',
      emoji: '💡',
    ),

    Product(
      name: 'Camera',
      category: 'Electronics',
      price: 25999,
      inStock: true,
      description: 'Digital photography camera',
      emoji: '📷',
    ),
  ];

  // Filter products based on all selected inputs
  List<Product> get filteredProducts {

    return products.where((product) {

      // Search filter
      final matchesSearch =
          product.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      // Category filter
      final matchesCategory =
          selectedCategory == 'All' ||
          product.category == selectedCategory;

      // Price filter
      final matchesPrice =
          product.price >= selectedPriceRange.start &&
          product.price <= selectedPriceRange.end;

      // Stock filter
      final matchesStock =
          !onlyInStock || product.inStock;

      return matchesSearch &&
          matchesCategory &&
          matchesPrice &&
          matchesStock;

    }).toList();
  }

  // Clear all filters and search text
  void clearFilters() {

    searchController.clear();

    setState(() {
      searchQuery = '';
      selectedCategory = 'All';
      selectedPriceRange =
          const RangeValues(0, 50000);
      onlyInStock = false;
    });
  }

  // Dispose search controller
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // App bar
      appBar: AppBar(
        title: const Text(
          'Product Finder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),

          child: Column(
            children: [

              // Search field
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,

                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },

                  decoration: InputDecoration(
                    hintText: 'Search products by name...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Filter panel
              Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                elevation: 2,
                color: Colors.white,

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Filter heading and clear button
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Products',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          TextButton.icon(
                            onPressed: clearFilters,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Clear Filters'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Category dropdown
                      const Text(
                        'Select Category',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        isExpanded: true,

                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),

                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),

                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      // Price range slider
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Price Range',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          Text(
                            '₹${selectedPriceRange.start.round()} - ₹${selectedPriceRange.end.round()}',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      RangeSlider(
                        values: selectedPriceRange,
                        min: 0,
                        max: 50000,
                        divisions: 100,
                        activeColor: Colors.indigo,

                        labels: RangeLabels(
                          '₹${selectedPriceRange.start.round()}',
                          '₹${selectedPriceRange.end.round()}',
                        ),

                        onChanged: (values) {
                          setState(() {
                            selectedPriceRange = values;
                          });
                        },
                      ),

                      // Stock checkbox
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,

                        title: const Text(
                          'Show only available products',
                          style: TextStyle(fontSize: 14),
                        ),

                        value: onlyInStock,
                        activeColor: Colors.indigo,

                        controlAffinity:
                            ListTileControlAffinity.leading,

                        onChanged: (value) {
                          setState(() {
                            onlyInStock = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Product count
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Row(
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '${filteredProducts.length} items found',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              // Dynamic product list
              Expanded(
                child: filteredProducts.isEmpty

                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),

                            SizedBox(height: 10),

                            Text(
                              'No products found!',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      )

                    : ListView.builder(
                        itemCount: filteredProducts.length,

                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: filteredProducts[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

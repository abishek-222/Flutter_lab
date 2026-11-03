
import 'package:flutter/material.dart';

import 'models/product.dart';
import 'widgets/product_card.dart';
import 'widgets/category_chip.dart';

void main() {
  runApp(const EcommerceApp());
}

// Main application
class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEasy',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const ProductCatalogPage(),
    );
  }
}

// Product catalog screen
class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() =>
      _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {

  int cartCount = 0;

  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> categories = [
    'All',
    'Electronics',
    'Fashion',
    'Accessories',
    'Home',
  ];

  // Product information
  final List<Product> products = const [

    Product(
      name: 'Wireless Headphones',
      category: 'Electronics',
      price: 2499,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600',
    ),

    Product(
      name: 'Smart Watch',
      category: 'Electronics',
      price: 3499,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600',
    ),

    Product(
      name: 'Running Shoes',
      category: 'Fashion',
      price: 1999,
      rating: 4.3,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    ),

    Product(
      name: 'Casual Backpack',
      category: 'Accessories',
      price: 1299,
      rating: 4.4,
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600',
    ),

    Product(
      name: 'Sunglasses',
      category: 'Accessories',
      price: 899,
      rating: 4.2,
      imageUrl:
          'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=600',
    ),

    Product(
      name: 'Modern Chair',
      category: 'Home',
      price: 4599,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1503602642458-232111445657?w=600',
    ),

    Product(
      name: 'Camera',
      category: 'Electronics',
      price: 25999,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600',
    ),

    Product(
      name: 'Denim Jacket',
      category: 'Fashion',
      price: 2199,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1543076447-215ad9ba6923?w=600',
    ),
  ];

  // Filter products based on search and category
  List<Product> get filteredProducts {
    return products.where((product) {

      final matchesCategory =
          selectedCategory == 'All' ||
          product.category == selectedCategory;

      final matchesSearch =
          product.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      return matchesCategory && matchesSearch;

    }).toList();
  }

  void addToCart() {
    setState(() {
      cartCount++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added to cart!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Application bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,

        title: const Text(
          'ShopEasy',
          style: TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.indigo,
                size: 27,
              ),
            ),
          ),
        ],
      ),

      // Responsive body
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1400,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Welcome banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3949AB),
                      Color(0xFF7986CB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Amazing Products!',
                      style: TextStyle(
                        fontSize: 23,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Find the best products at great prices.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },

                  decoration: InputDecoration(
                    hintText: 'Search products...',
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

              const SizedBox(height: 20),

              // Categories
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount: categories.length,

                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return CategoryChip(
                      title: category,
                      isSelected:
                          selectedCategory == category,
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Responsive product grid
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {

                    final width = constraints.maxWidth;

                    int columns;

                    if (width < 600) {
                      columns = 2;
                    } else if (width < 1000) {
                      columns = 3;
                    } else {
                      columns = 4;
                    }

                    final aspectRatio =
                        width < 600 ? 0.68 : 0.78;

                    final visibleProducts = filteredProducts;

                    if (visibleProducts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No products found!',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),

                      itemCount: visibleProducts.length,

                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: aspectRatio,
                      ),

                      itemBuilder: (context, index) {

                        final product =
                            visibleProducts[index];

                        return ProductCard(
                          product: product,
                          onAddToCart: addToCart,
                        );
                      },
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

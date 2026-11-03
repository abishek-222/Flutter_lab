
import 'package:flutter/material.dart';
import 'widgets/fruit_card.dart';

void main() {
  runApp(const FruitApp());
}

// Main application widget
class FruitApp extends StatelessWidget {
  const FruitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fruit Store',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const FruitHomePage(),
    );
  }
}

// Fruit details model
class Fruit {
  final String name;
  final String description;
  final String price;
  final String emoji;
  final Color color;

  const Fruit({
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
    required this.color,
  });
}

// Home screen
class FruitHomePage extends StatelessWidget {
  const FruitHomePage({super.key});

  // List of fruit items
  static const List<Fruit> fruits = [
    Fruit(
      name: 'Apple',
      description: 'Fresh and crunchy',
      price: '₹120',
      emoji: '🍎',
      color: Colors.red,
    ),
    Fruit(
      name: 'Banana',
      description: 'Rich in potassium',
      price: '₹60',
      emoji: '🍌',
      color: Colors.orange,
    ),
    Fruit(
      name: 'Orange',
      description: 'Rich in Vitamin C',
      price: '₹80',
      emoji: '🍊',
      color: Colors.deepOrange,
    ),
    Fruit(
      name: 'Grapes',
      description: 'Sweet and juicy',
      price: '₹100',
      emoji: '🍇',
      color: Colors.purple,
    ),
    Fruit(
      name: 'Watermelon',
      description: 'Refreshing summer fruit',
      price: '₹40',
      emoji: '🍉',
      color: Colors.green,
    ),
    Fruit(
      name: 'Mango',
      description: 'King of fruits',
      price: '₹150',
      emoji: '🥭',
      color: Colors.amber,
    ),
    Fruit(
      name: 'Pineapple',
      description: 'Sweet and tangy',
      price: '₹90',
      emoji: '🍍',
      color: Colors.yellow,
    ),
    Fruit(
      name: 'Strawberry',
      description: 'Fresh and delicious',
      price: '₹200',
      emoji: '🍓',
      color: Colors.pink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F3),

      // App bar
      appBar: AppBar(
        title: const Text(
          'Fruit Store',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Main page layout
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2E1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fresh Fruits 🍉',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF205C35),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Healthy choices for a healthy life!',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Available Fruits',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Scrollable fruit list
          Expanded(
            child: ListView.builder(
              itemCount: fruits.length,
              itemBuilder: (context, index) {
                final fruit = fruits[index];

                return FruitCard(
                  name: fruit.name,
                  description: fruit.description,
                  price: fruit.price,
                  emoji: fruit.emoji,
                  color: fruit.color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';

void main() {
  runApp(const MileageCalculatorApp());
}

// Root application
class MileageCalculatorApp extends StatelessWidget {
  const MileageCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Mileage Calculator',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const MileageCalculatorPage(),
    );
  }
}

// Stateful mileage calculator screen
class MileageCalculatorPage extends StatefulWidget {
  const MileageCalculatorPage({super.key});

  @override
  State<MileageCalculatorPage> createState() =>
      _MileageCalculatorPageState();
}

class _MileageCalculatorPageState
    extends State<MileageCalculatorPage> {

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Input controllers
  final TextEditingController vehicleController =
      TextEditingController();

  final TextEditingController distanceController =
      TextEditingController();

  final TextEditingController fuelController =
      TextEditingController();

  // Calculated mileage
  double? mileage;

  // Vehicle name for displaying result
  String vehicleName = '';

  // Validate numeric inputs
  String? validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a value';
    }

    final number = double.tryParse(value.trim());

    if (number == null || !number.isFinite) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return 'Value must be greater than zero';
    }

    return null;
  }

  // Calculate mileage
  void calculateMileage() {
    if (_formKey.currentState!.validate()) {

      final distance =
          double.parse(distanceController.text.trim());

      final fuel =
          double.parse(fuelController.text.trim());

      final result = distance / fuel;

      setState(() {
        mileage = result;
        vehicleName = vehicleController.text.trim();
      });
    } else {
      setState(() {
        mileage = null;
      });
    }
  }

  // Reset all inputs and results
  void resetCalculator() {
    _formKey.currentState!.reset();

    vehicleController.clear();
    distanceController.clear();
    fuelController.clear();

    setState(() {
      mileage = null;
      vehicleName = '';
    });
  }

  @override
  void dispose() {
    vehicleController.dispose();
    distanceController.dispose();
    fuelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),

      // App bar
      appBar: AppBar(
        title: const Text(
          'Car Mileage Calculator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 550,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Header
                const Icon(
                  Icons.directions_car,
                  size: 75,
                  color: Colors.teal,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Calculate Your Car Mileage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Enter your vehicle and fuel details '
                  'to calculate fuel efficiency.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 25),

                // Form
                Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'Vehicle Details',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Vehicle name
                          const Text('Vehicle Name'),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: vehicleController,

                            decoration: InputDecoration(
                              hintText: 'Example: Hyundai i20',
                              prefixIcon: const Icon(
                                Icons.directions_car,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter vehicle name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Distance travelled
                          const Text('Distance Travelled (km)'),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: distanceController,

                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),

                            decoration: InputDecoration(
                              hintText: 'Example: 450',
                              prefixIcon: const Icon(
                                Icons.route,
                              ),
                              suffixText: 'km',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),

                            validator: validatePositiveNumber,
                          ),

                          const SizedBox(height: 20),

                          // Fuel consumed
                          const Text('Fuel Consumed (Litres)'),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: fuelController,

                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),

                            decoration: InputDecoration(
                              hintText: 'Example: 30',
                              prefixIcon: const Icon(
                                Icons.local_gas_station,
                              ),
                              suffixText: 'L',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),

                            validator: validatePositiveNumber,
                          ),

                          const SizedBox(height: 25),

                          // Calculate button
                          SizedBox(
                            width: double.infinity,
                            height: 50,

                            child: ElevatedButton.icon(
                              onPressed: calculateMileage,

                              icon: const Icon(
                                Icons.calculate,
                                color: Colors.white,
                              ),

                              label: const Text(
                                'Calculate Mileage',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Reset button
                          SizedBox(
                            width: double.infinity,
                            height: 45,

                            child: OutlinedButton.icon(
                              onPressed: resetCalculator,

                              icon: const Icon(Icons.refresh),

                              label: const Text('Reset'),

                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Mileage result
                if (mileage != null)

                  Card(
                    color: const Color(0xFFDDF4ED),
                    elevation: 3,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(24),

                      child: Column(
                        children: [

                          const Icon(
                            Icons.speed,
                            color: Colors.teal,
                            size: 45,
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Mileage Result',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            vehicleName,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            '${mileage!.toStringAsFixed(2)} km/L',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Kilometres per litre',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                const Text(
                  'Formula: Mileage = Distance Travelled / Fuel Consumed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

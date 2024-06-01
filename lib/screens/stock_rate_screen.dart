import 'package:flutter/material.dart';

class StockRateScreen extends StatefulWidget {
  @override
  _StockRateScreenState createState() => _StockRateScreenState();
}

class _StockRateScreenState extends State<StockRateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPondType = 'Circular';
  String _selectedUnit = 'Meters';
  String _selectedFishType = 'Tilapia';
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();

  // Function to convert volume based on selected measurement unit
  double _convertVolume(double volume) {
    if (_selectedUnit == 'Feet') {
      // Convert from cubic feet to liters
      return volume * 28.317;
    }
    // Default to cubic meters
    return volume * 1000; // Convert from cubic meters to liters
  }

  void _calculateStockRate() {
    if (_formKey.currentState!.validate()) {
      double depth = double.parse(_depthController.text);
      double volume;

      if (_selectedPondType == 'Circular') {
        double diameter = double.parse(_diameterController.text);
        double radius = diameter / 2;
        volume = 3.14159 * radius * radius * depth; // Volume of a cylinder
      } else {
        double length = double.parse(_lengthController.text);
        double width = double.parse(_widthController.text);
        volume = length * width * depth; // Volume of a rectangular prism
      }

      // Convert volume based on selected measurement unit
      double volumeInLiters = _convertVolume(volume);

      double stockingDensity;
      double averageFishWeight;

      // Define stocking density and average fish weight based on selected fish type
      switch (_selectedFishType) {
        case 'Tilapia':
          stockingDensity = 25.0; // kg/m³
          averageFishWeight = 0.5; // kg per fish
          break;
        case 'Catfish':
          stockingDensity = 50.0; // kg/m³
          averageFishWeight = 1.0; // kg per fish
          break;
        case 'Carp':
          stockingDensity = 20.0; // kg/m³
          averageFishWeight = 0.75; // kg per fish
          break;
        default:
          stockingDensity = 25.0;
          averageFishWeight = 0.5;
      }

      double fishStockRate = volume * stockingDensity;
      int numberOfFish = (fishStockRate / averageFishWeight).round();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Calculation Results'),
            content: Text(
              'Pond Water Volume: ${volumeInLiters.toStringAsFixed(2)} Liters\n'
              'Fish Stock Rate: ${numberOfFish.toInt()} $_selectedFishType',
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Rate Calculation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPondType,
                decoration: InputDecoration(labelText: 'Type of Pond'),
                items: ['Circular', 'Square/Rectangle']
                    .map((pondType) => DropdownMenuItem(
                          value: pondType,
                          child: Text(pondType),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPondType = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: InputDecoration(labelText: 'Measurement Unit'),
                items: ['Meters', 'Feet']
                    .map((unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedFishType,
                decoration: InputDecoration(labelText: 'Type of Fish'),
                items: ['Tilapia', 'Catfish', 'Carp']
                    .map((fishType) => DropdownMenuItem(
                          value: fishType,
                          child: Text(fishType),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFishType = value!;
                  });
                },
              ),
              SizedBox(height: 10), // Added space here
              if (_selectedPondType == 'Circular')
                TextFormField(
                  controller: _diameterController,
                  decoration: InputDecoration(labelText: 'Diameter'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter diameter';
                    }
                    return null;
                  },
                ),
              if (_selectedPondType == 'Square/Rectangle')
                TextFormField(
                  controller: _lengthController,
                  decoration: InputDecoration(labelText: 'Length'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter length';
                    }
                    return null;
                  },
                ),
              if (_selectedPondType == 'Square/Rectangle')
                TextFormField(
                  controller: _widthController,
                  decoration: InputDecoration(labelText: 'Width'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter width';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: _depthController,
                decoration: InputDecoration(labelText: 'Water Depth'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter water depth';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateStockRate,
                child: Text('Calculate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

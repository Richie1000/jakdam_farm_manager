import 'package:flutter/material.dart';

class StockRateScreen extends StatefulWidget {
  @override
  _StockRateScreenState createState() => _StockRateScreenState();
}

class _StockRateScreenState extends State<StockRateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPondType = 'Rectangular';
  String _selectedUnit = 'Meters';
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _diameterController = TextEditingController();

  double _convertToFeet(double value) {
    return value * 3.28084; // Conversion factor from meters to feet
  }

  void _calculateWaterVolume() {
    if (_formKey.currentState!.validate()) {
      double length = double.parse(_lengthController.text);
      double width = double.parse(_widthController.text);
      double depth = double.parse(_depthController.text);

      // Convert values to feet if 'Meters' is selected
      if (_selectedUnit == 'Meters') {
        length = _convertToFeet(length);
        width = _convertToFeet(width);
        depth = _convertToFeet(depth);
      }

      // Calculate water volume in cubic feet
      double volume = length * width * depth;

      // Convert cubic feet to liters
      double volumeInLiters = volume * 28.32;

      // Final calculation and rounding off
      int finalResult = (volumeInLiters / 13.15).round();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Stocking Capacity'),
            content: Text(
                'The calculated volume is ${volumeInLiters.toStringAsFixed(2)} liters.\n'
                'Your pond can conveniently hold $finalResult fishes to 1kg average weight.'),
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

  void _calculateWaterVolumeCircular() {
    if (_formKey.currentState!.validate()) {
      double diameter = double.parse(_diameterController.text);
      double depth = double.parse(_depthController.text);

      // Convert values to feet if 'Meters' is selected
      if (_selectedUnit == 'Meters') {
        diameter = _convertToFeet(diameter);
        depth = _convertToFeet(depth);
      }

      // Calculate water volume for circular pond
      double volume = 3.14159 * ((diameter * 0.5) * (diameter * 0.5)) * depth;

      // Convert cubic feet to liters
      double volumeInLiters = volume * 28.32;

      // Final calculation and rounding off
      int finalResult = (volumeInLiters / 13.15).round();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Stocking Capacity'),
            content: Text(
                'The calculated volume is ${volumeInLiters.toStringAsFixed(2)} liters.\n'
                'Your pond can conveniently hold $finalResult fishes of 1kg average weight of fishes.'),
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

  void _calculation() {
    if (_selectedPondType == "Circular") {
      _calculateWaterVolumeCircular();
    } else {
      _calculateWaterVolume();
    }
  }

  void _clearFields() {
    _lengthController.clear();
    _widthController.clear();
    _depthController.clear();
    _diameterController.clear();
    setState(() {
      _selectedPondType = 'Rectangular';
      _selectedUnit = 'Meters';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Volume Calculation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPondType,
                decoration: InputDecoration(labelText: 'Pond Type'),
                items: ['Rectangular', 'Circular']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPondType = value!;
                  });
                },
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              if (_selectedPondType == 'Rectangular') ...[
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
                SizedBox(height: 20),
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
              ] else ...[
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
              ],
              SizedBox(height: 20),
              TextFormField(
                controller: _depthController,
                decoration: InputDecoration(labelText: 'Fill Depth'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fill depth';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _calculation,
                    child: Text('Calculate'),
                  ),
                  ElevatedButton(
                    onPressed: _clearFields,
                    child: Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as Math;

class ProductionBudgetScreen extends StatefulWidget {
  @override
  _ProductionBudgetScreenState createState() => _ProductionBudgetScreenState();
}

class _ProductionBudgetScreenState extends State<ProductionBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numberOfFishesController =
      TextEditingController();

  String _selectedUnit = 'Feet';
  String _selectedFishType = 'Catfish';
  double _length = 0;
  double _width = 0;
  double _depth = 0;
  double _waterVolume = 0;
  double _totalFeedRequired = 0;
  int _totalFeedBags = 0;
  bool _showDuration = false;
  int _duration = 6; // Default duration for Catfish
  String _lastCalculatedUnit =
      'Feet'; // Store the unit used in the last calculation

  void _calculateBudget() {
    if (_formKey.currentState!.validate()) {
      int numberOfFishes = int.parse(_numberOfFishesController.text);

      // Calculate the total pond volume based on the number of fishes
      _waterVolume =
          (numberOfFishes / 1000) * 12000; // Total water volume in liters

      // Variables for volume in cubic units
      double volumeInCubicFeet =
          _waterVolume / 28.3168; // Convert volume from liters to cubic feet
      double volumeInCubicMeters =
          _waterVolume / 1000; // Convert volume from liters to cubic meters

      if (_selectedUnit == 'Feet') {
        // Only recalculate if unit has changed or if it's the initial calculation
        _depth = 3; // Depth in feet

        // Calculate dimensions assuming the pond is a square
        _length = Math.sqrt(volumeInCubicFeet / _depth); // Length in feet
        _width = _length; // Width in feet, assuming a square pond
      } else {
        // Only recalculate if unit has changed or if it's the initial calculation
        _depth = 1; // Depth in meters

        // Calculate dimensions assuming the pond is a square
        _length = Math.sqrt(volumeInCubicMeters / _depth); // Length in meters
        _width = _length; // Width in meters, assuming a square pond
      }

      // Update total feed required and feed bags
      _totalFeedRequired = numberOfFishes.toDouble(); // Total feed in kg
      _totalFeedBags =
          (_totalFeedRequired / 15).ceil(); // Number of bags, 1 bag = 15 kg

      setState(() {
        _showDuration = true;
        _duration = _selectedFishType == 'Catfish'
            ? 6
            : 7; // Update duration based on selected fish type
        _lastCalculatedUnit = _selectedUnit; // Update the last calculated unit
      });
    }
  }

  void _clearFields() {
    _numberOfFishesController.clear();
    setState(() {
      _length = 0;
      _width = 0;
      _depth = 0;
      _waterVolume = 0;
      _totalFeedRequired = 0;
      _totalFeedBags = 0;
      _showDuration = false;
      _duration = _selectedFishType == 'Catfish'
          ? 6
          : 7; // Reset duration to default based on fish type
      _selectedUnit = _lastCalculatedUnit; // Reset to the last calculated unit
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Production Budget Calculation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _numberOfFishesController,
                decoration: InputDecoration(labelText: 'Number of Fishes'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of fishes';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: InputDecoration(labelText: 'Measurement Unit'),
                items: ['Feet', 'Meters']
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
              DropdownButtonFormField<String>(
                value: _selectedFishType,
                decoration: InputDecoration(labelText: 'Type of Fish'),
                items: ['Catfish', 'Tilapia']
                    .map((fish) => DropdownMenuItem(
                          value: fish,
                          child: Text(fish),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFishType = value!;
                    _duration = value == 'Catfish'
                        ? 6
                        : 7; // Update duration based on selected fish type
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calculateBudget,
                      child: Text('Calculate Budget'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clearFields,
                      child: Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .red, // Change the color to differentiate the button
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_length > 0 && _width > 0 && _depth > 0)
                Text(
                  'Pond Size: ${_length.toStringAsFixed(2)} x ${_width.toStringAsFixed(2)} x ${_depth.toStringAsFixed(2)} $_selectedUnit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              if (_waterVolume > 0)
                Text(
                  'Estimated Water Volume Requirement: ${_waterVolume.toStringAsFixed(2)} liters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              if (_totalFeedRequired > 0)
                Text(
                  'Total Feed Required: ${_totalFeedRequired.toStringAsFixed(2)} kg (${_totalFeedBags} bags)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              if (_showDuration)
                Text(
                  'Duration: $_duration months',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

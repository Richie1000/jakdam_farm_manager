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
  int _duration = 6;
  String _lastCalculatedUnit = 'Feet';

  void _calculateBudget() {
    if (_formKey.currentState!.validate()) {
      int numberOfFishes = int.parse(_numberOfFishesController.text);

      _waterVolume = (numberOfFishes / 1000) * 12000;

      double volumeInCubicFeet = _waterVolume / 28.3168;
      double volumeInCubicMeters = _waterVolume / 1000;

      if (_selectedUnit == 'Feet') {
        _depth = 3; // Depth in feet

        _length = Math.sqrt(volumeInCubicFeet / _depth);
        _width = _length;
      } else {
        _depth = 1;

        _length = Math.sqrt(volumeInCubicMeters / _depth);
        _width = _length;
      }

      _totalFeedRequired = numberOfFishes.toDouble();
      _totalFeedBags = (_totalFeedRequired / 15).ceil();

      setState(() {
        _showDuration = true;
        _duration = _selectedFishType == 'Catfish' ? 6 : 7;
        _lastCalculatedUnit = _selectedUnit;
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
      _duration = _selectedFishType == 'Catfish' ? 6 : 7;
      _selectedUnit = _lastCalculatedUnit;
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
                    _duration = value == 'Catfish' ? 6 : 7;
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
                        backgroundColor: Colors.red,
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

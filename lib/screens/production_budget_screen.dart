import 'package:flutter/material.dart';

class ProductionBudgetScreen extends StatefulWidget {
  @override
  _ProductionBudgetScreenState createState() => _ProductionBudgetScreenState();
}

class _ProductionBudgetScreenState extends State<ProductionBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numberOfFishesController =
      TextEditingController();

  String _selectedUnit = 'Feet';
  double _length = 0;
  double _width = 0;
  double _depth = 0;
  double _waterVolume = 0;
  double _totalFeedRequired = 0;
  int _totalFeedBags = 0;
  bool _showDuration = false;

  void _calculateBudget() {
    if (_formKey.currentState!.validate()) {
      int numberOfFishes = int.parse(_numberOfFishesController.text);

      // Calculate the total pond volume based on the number of fishes
      _waterVolume =
          (numberOfFishes / 1000) * 12960; // Total water volume in liters

      // Calculate dimensions assuming the depth for 1000 fishes is 3 feet (or 1 meter)
      if (_selectedUnit == 'Feet') {
        _depth = 3;
        _length = _waterVolume / (28.317 * _depth);
        _width = _length;
      } else {
        _depth = 1;
        _length = _waterVolume / (_depth * 1000);
        _width = _length;
      }

      // Estimate total feed required based on the example
      _totalFeedRequired =
          (numberOfFishes / 1000) * 905; // Scale the feed requirement
      _totalFeedBags = (_totalFeedRequired / 15).ceil(); // 1 bag = 15 kg

      setState(() {
        _showDuration = true;
      });
    }
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
              ElevatedButton(
                onPressed: _calculateBudget,
                child: Text('Calculate Budget'),
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
                  'Duration: 6 months',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

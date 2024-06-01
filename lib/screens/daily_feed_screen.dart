import 'package:flutter/material.dart';

class DailyFeedScreen extends StatefulWidget {
  @override
  _DailyFeedScreenState createState() => _DailyFeedScreenState();
}

class _DailyFeedScreenState extends State<DailyFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _weightController = TextEditingController();

  double _dailyFeedRatio = 0;
  String _feedSize = '';

  void _calculateFeed() {
    if (_formKey.currentState!.validate()) {
      final int quantity = int.parse(_quantityController.text);
      final double weight = double.parse(_weightController.text);

      // Logic to calculate daily feed ratio and feed size
      _dailyFeedRatio = _calculateDailyFeedRatio(quantity, weight);
      _feedSize = _getFeedSize(weight);

      setState(() {});
    }
  }

  void _clearFields() {
    _quantityController.clear();
    _weightController.clear();
    setState(() {
      _dailyFeedRatio = 0;
      _feedSize = '';
    });
  }

  double _calculateDailyFeedRatio(int quantity, double weight) {
    // New logic for feed ratio calculation
    // grams of feed per day = (number of fish * 85 g per fish) * 0.04
    return (quantity * weight) * 0.04;
  }

  String _getFeedSize(double weight) {
    // Example logic for determining feed size
    if (weight < 50) {
      return '0.5 mm';
    } else if (weight < 100) {
      return '1 mm';
    } else if (weight < 200) {
      return '1.5 mm';
    } else {
      return '2 mm';
    }
  }

  @override
  Widget build(BuildContext context) {
    double _dailyFeedRatioKg =
        _dailyFeedRatio / 1000; // Convert grams to kilograms

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Feed Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Fish Quantity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fish quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: 'Average Weight (grams)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter average weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _calculateFeed,
                    child: Text('Calculate'),
                  ),
                  ElevatedButton(
                    onPressed: _clearFields,
                    child: Text('Clear'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_dailyFeedRatio > 0) ...[
                Text("Daily Feed Ratio:"),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    ' ${_dailyFeedRatio.toStringAsFixed(2)} grams',
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(
                    ' ( ${_dailyFeedRatioKg.toStringAsFixed(2)} kilograms) Per Day',
                    style: TextStyle(color: Colors.green),
                  ),
                  //Text("  Per day")
                ]),
                SizedBox(
                  height: 20,
                ),
                Text('Feed Size: $_feedSize'),
                SizedBox(height: 20),
                Text(
                  'This is the daily feed requirement for your fish. The amount can be fed once or divided into multiple portions. Factors such as water quality, disease, weather, stress, and dissolved oxygen levels can influence feed consumption.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}

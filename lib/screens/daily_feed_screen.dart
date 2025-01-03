import 'package:flutter/material.dart';

class DailyFeedScreen extends StatefulWidget {
  const DailyFeedScreen({super.key});

  @override
  State<DailyFeedScreen> createState() => _DailyFeedScreenState();
}

class _DailyFeedScreenState extends State<DailyFeedScreen> {
  final TextEditingController _averageWeightController =
      TextEditingController();
  final TextEditingController _fishQuantityController = TextEditingController();

  void _calculateDailyFeedIntake() {
    setState(() {
      double averageWeight =
          double.tryParse(_averageWeightController.text) ?? 0.0;
      int fishQuantity = int.tryParse(_fishQuantityController.text) ?? 0;

      double dailyFeedIntake;
      if (averageWeight <= 400) {
        dailyFeedIntake = averageWeight * 0.025 * fishQuantity;
      } else {
        dailyFeedIntake = averageWeight * 0.015 * fishQuantity;
      }

      _showResultDialog(dailyFeedIntake);
    });
  }

  void _showResultDialog(double dailyFeedIntake) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Daily Feed Intake'),
          content: Text(
            'The total daily feed intake is ${dailyFeedIntake.toStringAsFixed(2)}g.\n\n'
            'NOTE: Fingerlings are fed between 2 and 5 percent of their body weight per day, divided into two or more feedings, '
            'while broodfish are fed 1 to 2 percent of their weight per day.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    setState(() {
      _averageWeightController.clear();
      _fishQuantityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Feed Intake'),
        //backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: const Center(
                child: Text(
                  'Calculate the Total Daily Feed Intake for Your Fish',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _averageWeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Average Weight of Fish (in grams)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _fishQuantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity of Fish',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _calculateDailyFeedIntake,
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.grey,
                  // ),
                  child: const Text('CALCULATE'),
                ),
                ElevatedButton(
                  onPressed: _clearFields,
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.grey,
                  // ),
                  child: const Text('CLEAR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FeedBudgetScreen extends StatefulWidget {
  const FeedBudgetScreen({super.key});

  @override
  State<FeedBudgetScreen> createState() => _FeedBudgetScreenState();
}

class _FeedBudgetScreenState extends State<FeedBudgetScreen> {
  final TextEditingController _fishQuantityController = TextEditingController();

  Map<String, dynamic> _quantitiesInKg = {
    '2MM': 0.0,
    '3MM': 0.0,
    '4MM': 0.0,
    '6MM': 0.0,
    '8MM': 0.0,
    'TOTAL': 0.0,
  };

  Map<String, dynamic> _quantitiesInBags = {
    '2MM': 0.0,
    '3MM': 0.0,
    '4MM': 0.0,
    '6MM': 0.0,
    '8MM': 0.0,
    'TOTAL': 0,
  };

  Map<String, double> _unitPrices = {
    '2MM': 310.0,
    '3MM': 310.0,
    '4MM': 290.0,
    '6MM': 280.0,
    '8MM': 280.0,
  };

  Map<String, double> _totalCosts = {
    '2MM': 0.0,
    '3MM': 0.0,
    '4MM': 0.0,
    '6MM': 0.0,
    '8MM': 0.0,
    'TOTAL': 0.0,
  };

  void _calculateFeedQuantities() {
    setState(() {
      double quantity = double.tryParse(_fishQuantityController.text) ?? 0.0;

      _quantitiesInKg['2MM'] = 0.0299 * quantity;
      _quantitiesInKg['3MM'] = 0.0597 * quantity;
      _quantitiesInKg['4MM'] = 0.1791 * quantity;
      _quantitiesInKg['6MM'] = 0.4179 * quantity;
      _quantitiesInKg['8MM'] = 0.3134 * quantity;

      _quantitiesInKg['TOTAL'] = _quantitiesInKg['2MM']! +
          _quantitiesInKg['3MM']! +
          _quantitiesInKg['4MM']! +
          _quantitiesInKg['6MM']! +
          _quantitiesInKg['8MM']!;

      _quantitiesInBags['2MM'] = _quantitiesInKg['2MM']! / 15;
      _quantitiesInBags['3MM'] = _quantitiesInKg['3MM']! / 15;
      _quantitiesInBags['4MM'] = _quantitiesInKg['4MM']! / 15;
      _quantitiesInBags['6MM'] = _quantitiesInKg['6MM']! / 15;
      _quantitiesInBags['8MM'] = _quantitiesInKg['8MM']! / 15;

      _quantitiesInBags['TOTAL'] =
          (_quantitiesInKg['TOTAL']! / 15).roundToDouble();

      _totalCosts['2MM'] = _quantitiesInBags['2MM']! * _unitPrices['2MM']!;
      _totalCosts['3MM'] = _quantitiesInBags['3MM']! * _unitPrices['3MM']!;
      _totalCosts['4MM'] = _quantitiesInBags['4MM']! * _unitPrices['4MM']!;
      _totalCosts['6MM'] = _quantitiesInBags['6MM']! * _unitPrices['6MM']!;
      _totalCosts['8MM'] = _quantitiesInBags['8MM']! * _unitPrices['8MM']!;

      _totalCosts['TOTAL'] = _totalCosts['2MM']! +
          _totalCosts['3MM']! +
          _totalCosts['4MM']! +
          _totalCosts['6MM']! +
          _totalCosts['8MM']!;
    });
  }

  void _clearFields() {
    setState(() {
      _fishQuantityController.clear();
      _quantitiesInKg.updateAll((key, value) => 0.0);
      _quantitiesInBags.updateAll((key, value) => 0.0);
      _totalCosts.updateAll((key, value) => 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Budget'),
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
                  'THIS PAGE CALCULATES THE TOTAL QUANTITY OF FEED AND INDIVIDUAL FEED SIZE QUANTITIES REQUIRED TO RAISE ANY GIVEN QUANTITY OF FISH',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: const Center(
                child: Text(
                  'Supply the number of fish stocked in the space provided!!',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Text(
                  'Fish Quantity:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _fishQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _calculateFeedQuantities,
                  child: const Text('CALCULATE'),
                ),
                ElevatedButton(
                  onPressed: _clearFields,
                  child: const Text('CLEAR'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Table(
              border: TableBorder.all(color: Colors.grey),
              // columnWidths: const {
              //   0: FlexColumnWidth(2),
              //   1: FlexColumnWidth(2),
              //   2: FlexColumnWidth(2),
              //   3: FlexColumnWidth(1.5),
              //   4: FlexColumnWidth(2),
              // },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text(
                            'FEED SIZE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text(
                            'QUANTITY IN KILOGRAMS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text(
                            'QUANTITY IN BAGS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text(
                            'UNIT PRICE (GHC)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text(
                            'TOTAL COST (GHC)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                for (String size in [
                  '2MM',
                  '3MM',
                  '4MM',
                  '6MM',
                  '8MM',
                  'TOTAL'
                ])
                  TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey[200],
                          child: Center(
                            child: Text(
                              size,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey[200],
                          child: Center(
                            child: Text(
                              _quantitiesInKg[size]!.toStringAsFixed(2),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey[200],
                          child: Center(
                            child: Text(
                              _quantitiesInBags[size]!.toStringAsFixed(2),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey[200],
                          child: Center(
                            child: Text(
                              size != 'TOTAL'
                                  ? _unitPrices[size]!.toStringAsFixed(0)
                                  : '',
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey[200],
                          child: Center(
                            child: Text(
                              _totalCosts[size]!.toStringAsFixed(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Note: this estimated feed is calculated with reference to growing the fishes to an average weight of 1kg (table size fish). Therefore, culturing your fishes to smoking size (500g) average weight will require half of the estimated amount of feed. Smoking size fishes have an average weight of 500 grams (3-4 months period), Table size fishes have an average weight of 1kg (6 months period).',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

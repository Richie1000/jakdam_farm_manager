import 'package:flutter/material.dart';

import 'stock_rate_screen.dart';
import 'treatment_dosage_screen.dart';
import 'auto_treatment_dosage_screen.dart';
import 'production_budget_screen.dart';

class PondCalculationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pond Calculations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: ListView(
          children: [
            PondCalculationCard(
              title: 'Pond Stocking Capacity Calculation',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StockRateScreen()),
                );
              },
            ),
          
          
            // PondCalculationCard(
            //   title: 'Auto Treatment Dosage',
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => AutoTreatmentDosageScreen()),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

class PondCalculationCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  PondCalculationCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

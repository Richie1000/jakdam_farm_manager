import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Import animate_do package

import 'daily_feed_screen.dart';
import 'feed_budget_screen.dart';

class FeedCalculationScreen extends StatelessWidget {
  const FeedCalculationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Calculations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: ListView(
          children: [
            FadeInUp(
              child: CustomCard(
                title: 'Daily Feed Intake',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DailyFeedScreen()),
                  );
                },
              ),
            ),
            // Remove any SizedBox or other widgets that add extra spacing
            FadeInUp(
              child: CustomCard(
                title: 'Total Production Feed Budget',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedBudgetScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  CustomCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
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

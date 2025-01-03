import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class FeedFormulaeScreen extends StatelessWidget {
  const FeedFormulaeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Feed Rate'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInUp(
              child: const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Original code commented for future implementation

/*
class FeedFormulaeScreen extends StatelessWidget {
  const FeedFormulaeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Feed Rate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: ListView(
          children: [
            FadeInUp( 
              child: CustomCard(
                title: 'Daily Feed Frequency',
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => DailyFeedScreen()),
                  // );
                },
              ),
            ),
            FadeInUp(
              child: CustomCard(
                title: 'Total Production Feed Budget',
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => FeedBudgetScreen()),
                  // );
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

  const CustomCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
*/

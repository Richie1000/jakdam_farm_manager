import 'package:flutter/material.dart';
import 'feed_record_screen.dart';
import 'expense_tracking_screen.dart';

class FarmDetailsScreen extends StatefulWidget {
  final String farmId;
  final String userId;

  const FarmDetailsScreen(
      {Key? key, required this.farmId, required this.userId})
      : super(key: key);

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Feed Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Expenses',
          ),
        ],
      ),
    );
  }
}

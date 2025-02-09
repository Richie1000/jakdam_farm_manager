import 'package:flutter/material.dart';
import 'feed_record_screen.dart';
import 'expense_tracking_screen.dart';
import 'stock_screen.dart';

class PondDetailsScreen extends StatefulWidget {
  final String pondId;
  final String userId;

  const PondDetailsScreen({
    Key? key,
    required this.pondId,
    required this.userId,
  }) : super(key: key);

  @override
  State<PondDetailsScreen> createState() => _PondDetailsScreenState();
}

class _PondDetailsScreenState extends State<PondDetailsScreen> {
  int _currentIndex = 0;

  // List of screens to display for each tab
  final List<Widget Function(String, String)> _screens = [
        (userId, pondId) => FeedRecordScreen(userId: userId, pondId: pondId),
        (userId, pondId) => ExpenseTrackingScreen(userId: userId, pondId: pondId),
        (userId, pondId) => StockScreen(userId: userId, pondId: pondId),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex](widget.userId, widget.pondId),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.iso),
            label: 'Stock',
          ),
        ],
      ),
    );
  }
}
